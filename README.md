# Philadelphia Mansue

A Flutter-based mobile voting application that enables users to authenticate via phone number and cast votes in elections.

## Features

- **Phone Authentication** - Secure Firebase phone authentication with reCAPTCHA protection
- **Election Viewing** - Browse available elections and candidates
- **Candidate Selection** - Select candidates with real-time selection tracking
- **Vote Confirmation** - Review and confirm selections before submission
- **Multi-platform** - Supports iOS, Android, Web, macOS, Linux, and Windows

## Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Firebase (Auth, App Check)
- **Networking**: Dio
- **Architecture**: Clean Architecture with feature-based modules

## Project Structure

```
lib/
├── core/           # Shared utilities, services, and base classes
│   ├── constants/  # App-wide constants
│   ├── di/         # Dependency injection
│   ├── env/        # Environment configuration
│   ├── errors/     # Error handling
│   ├── network/    # API client and network utilities
│   ├── services/   # Shared services
│   └── widgets/    # Reusable widgets
├── features/       # Feature modules
│   ├── auth/       # Phone authentication
│   ├── candidates/ # Candidate display and selection
│   ├── confirmation/ # Vote confirmation
│   ├── elections/  # Election data management
│   ├── success/    # Success screens
│   └── voting/     # Voting logic
├── l10n/           # Localization files
└── mocks/          # Mock data for testing
```

Each feature follows Clean Architecture:
```
feature/
├── data/           # Data layer (models, datasources, repositories impl)
├── domain/         # Domain layer (entities, repositories, use cases)
└── presentation/   # Presentation layer (screens, widgets, providers)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.10 or higher
- Firebase project with Phone Authentication enabled

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd philadelphia_mansue
   ```

2. Copy the environment file and configure:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your Firebase and API credentials.

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Generate code (freezed models, riverpod providers):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Environment Variables

Create a `.env` file based on `.env.example`:

| Variable | Description |
|----------|-------------|
| `API_BASE_URL` | Backend API base URL |
| `FIREBASE_*` | Firebase configuration values |

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Development

### Code Generation

After modifying freezed models or riverpod providers:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Localization

Localization files are in `lib/l10n/`. After modifying:
```bash
flutter gen-l10n
```

## License

This project is proprietary and confidential.
