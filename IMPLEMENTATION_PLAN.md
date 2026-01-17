# User Flow Analysis: Philadelphia Mansue Voting App

## Overview

This document describes the complete user journey through the voting app, including what happens on page refresh and when returning after extended periods (8+ hours).

---

## Normal User Flow

### Phase 1: Authentication
```
User opens app → /splash
     ↓
Router checks auth state → Not authenticated
     ↓
Redirect to /login (phone input)
     ↓
User enters phone number
     ↓
Pre-checks (both must pass):
  1. hasActiveElection() → Is there an active election?
  2. checkPhone(phone) → Is phone registered?
     ↓
Firebase sendOtp() → SMS sent
     ↓
User enters 6-digit OTP
     ↓
Firebase verifyOtp() → Firebase credential obtained
     ↓
exchangeTokenWithBackend() → Backend bearer token stored
     ↓
AuthStatus = authenticated
     ↓
Router redirects to /prevalidation
```

### Phase 2: Pre-Validation & Election Load
```
/prevalidation screen
     ↓
Shows voter QR code for physical prevalidation
     ↓
User taps "Continue to Voting" → Navigate to /start-voting
     ↓
/start-voting screen
     ↓
User taps "Vote Now"
     ↓
Loads election via GET /api/elections (ongoing election)
     ↓
Backend checks:
  - Is user prevalidated? (403 NOT_PREVALIDATED if not)
  - Is election active?
     ↓
If NOT prevalidated → Show warning toast, stay on page
     ↓
If prevalidated → Navigate to /candidates
```

### Phase 3: Voting
```
/candidates screen
     ↓
Candidates displayed (shuffled, order saved to sessionStorage)
     ↓
User selects candidates (selections saved to sessionStorage)
     ↓
User taps "Confirm" → Navigate to /confirmation
     ↓
/confirmation screen shows selections
     ↓
User taps "Submit Vote"
     ↓
POST /api/votes with selected candidates
     ↓
Backend validates:
  - Token valid
  - User prevalidated
  - Not already voted
  - Correct candidate count
  - No duplicate candidates
     ↓
Vote recorded → 201 response
     ↓
Local vote cache updated
     ↓
Navigate to /success
```

---

## Page Refresh Flow

### What Gets Preserved

| State | Preserved? | Storage Location |
|-------|------------|------------------|
| Bearer token | Yes | FlutterSecureStorage (localStorage on web) |
| Firebase auth | Yes | Firebase internal storage |
| URL location | Yes | Browser URL |
| Election ID | Yes | URL param + provider state |
| Candidate selections | Yes (web) | sessionStorage |
| Candidate order | Yes (web) | sessionStorage |
| Vote cache | Yes | FlutterSecureStorage |
| Election data | Re-fetched | API call on restore |

### Refresh Timeline (~10 seconds)

```
T+0s: Page refresh triggered
       ↓
T+0-1s: App Initialization
  - Flutter rebuilds from main.dart
  - Firebase.initializeApp()
  - GoRouter created with initial location /splash
       ↓
T+1-2s: Firebase Auth State Sync
  - currentUserIdProvider watches authStateChanges()
  - Firebase emits current user (if signed in)
  - authNotifierProvider listener fires (fireImmediately: true)
       ↓
T+2-4s: Session Restoration
  - tryRestoreSession(userId) called
  - Check for stored token in FlutterSecureStorage
  - If token exists: Validate with GET /api/voters/me
    - If 401: Token expired → Sign out, redirect to /login
    - If 200: Token valid → Restore session
  - If no token: Exchange Firebase token for new backend token
       ↓
T+4-5s: Router Redirect
  - RouterRefreshNotifier.notifyListeners()
  - GoRouter.redirect() evaluates current state
       ↓
T+5-8s: Election Loading (if needed)
  - Load election from API
  - Restore candidate order from sessionStorage
  - voteDeletedDetectorProvider compares local vs API hasVoted
       ↓
T+8-10s: Selection Restoration (web)
  - SelectionNotifier loads from sessionStorage
  - UI displays previous selections
       ↓
T+10s: Final State
  - User sees their previous state restored
  - If voted: /success screen
  - If not voted: /candidates with selections intact
```

### Refresh at Different Stages

| Page | After Refresh |
|------|---------------|
| /login | Back to /login, must re-enter phone |
| /prevalidation | Auth restored → stay on /prevalidation |
| /candidates | Auth + election restored → selections preserved |
| /confirmation | Auth + election restored → selections preserved |
| /success | Auth restored → stay on /success |

---

## Returning After 8 Hours

### Token Lifetimes

| Token Type | Lifetime | Refresh Mechanism |
|------------|----------|-------------------|
| Firebase ID token | ~1 hour | Auto-refresh by Firebase SDK |
| Backend bearer token | Backend-defined | **None** - must re-login |

### What Happens

```
T+0s: User opens app (after 8 hours)
       ↓
T+0s: AppLifecycleObserver detects resume
       ↓
T+0.5s: Ping Request
  - GET /api/ping with stored bearer token
  - If 401 (expired): onUnauthorized → signOut()
  - If 200 (valid): Session still active
       ↓
T+1s: If Token Expired
  - AuthStatus = unauthenticated
  - Router redirects to /login
  - User must re-enter phone + OTP
       ↓
T+1s: If Token Valid
  - Session continues normally
  - User sees their previous state
```

### User Experience

**Token Expired:**
- Clean transition to login screen
- No error message shown
- User re-authenticates via phone + OTP
- After login, can resume voting if election still active

**Token Valid:**
- App resumes exactly where user left off
- If they had voted: /success screen
- If not voted: Previous selections still preserved

### Vote Deletion Detection

If admin deletes a user's vote while they're away:

```
App loads election from API
     ↓
API says: hasVoted = false
Local cache says: hasVoted = true
     ↓
Mismatch detected by voteDeletedDetectorProvider
     ↓
User is forcibly signed out
     ↓
User must re-authenticate to re-vote
```

---

## 401 Handling Flow

### AuthInterceptor Behavior

```dart
// Endpoints EXCLUDED from 401 handling (to prevent race conditions):
- /voters/login
- /voters/impersonate
- /voters/me

// All other endpoints: 401 triggers signOut()
```

### 401 Response Chain

```
API returns 401
     ↓
AuthInterceptor.onError catches it
     ↓
Is it an auth endpoint? Skip handling
     ↓
Is it a protected endpoint? Call onUnauthorized()
     ↓
onUnauthorized triggers authNotifier.signOut()
     ↓
signOut() clears:
  - Bearer token
  - Vote cache
  - Selection storage
  - Candidate order
     ↓
AuthStatus = unauthenticated
     ↓
Router redirects to /login
```

---

## State Management Summary

### Authentication States

| Status | Meaning |
|--------|---------|
| `initial` | App just started, checking auth |
| `loading` | Auth operation in progress |
| `otpSent` | OTP sent, waiting for verification |
| `authenticated` | User is logged in |
| `unauthenticated` | User is logged out |
| `impersonating` | Debug impersonation in progress |
| `error` | Auth error occurred |

### Election Load States

| Status | Meaning |
|--------|---------|
| `initial` | Not loaded yet |
| `loading` | API call in progress |
| `loaded` | Election data available |
| `noElection` | No active election (vote ended) |
| `error` | API error |

### Router Decision Tree

```
Not authenticated?
  └─ Redirect to /login

Authenticated but election not loaded?
  └─ Allow /prevalidation, /start-voting
  └─ Otherwise redirect to /prevalidation

Election loaded + hasVoted = true?
  └─ Redirect to /success

Election loaded + hasVoted = false?
  └─ Allow /candidates, /confirmation
  └─ Otherwise redirect to /candidates

No election exists?
  └─ Redirect to /vote-ended
```

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/routing/app_router.dart` | Central routing + redirect logic |
| `lib/features/auth/presentation/providers/auth_providers.dart` | Auth state + session restoration |
| `lib/features/elections/presentation/providers/election_providers.dart` | Election loading + candidate order |
| `lib/features/voting/presentation/providers/local_vote_providers.dart` | Vote cache + deletion detection |
| `lib/core/network/auth_interceptor.dart` | 401 handling |
| `lib/core/services/app_lifecycle_service.dart` | App resume → ping |
| `lib/core/utils/selection_storage_web.dart` | Web selection persistence |

---

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/` | Initial loading screen |
| Phone Auth | `/login` | Phone + OTP authentication |
| Prevalidation | `/prevalidation` | Displays user's QR code |
| Start Voting | `/start-voting` | "Vote Now" button, loads election |
| Candidates | `/candidates` | Select candidates |
| Confirmation | `/confirmation` | Review and confirm vote |
| Success | `/success` | Vote submitted confirmation |
| Vote Ended | `/vote-ended` | No active election message |

---

## Potential Issues to Monitor

1. **Token expiration timing** - Backend token TTL should be documented
2. **Network errors** - App doesn't sign out on network failure (only on 401)
3. **Race conditions** - Mutex (`_isRestoringSession`) prevents concurrent restores
4. **Vote deletion** - Forces re-auth, may confuse users
5. **sessionStorage limits** - Web only, lost if tab is closed
