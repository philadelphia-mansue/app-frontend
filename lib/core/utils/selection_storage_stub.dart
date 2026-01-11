/// Stub implementation for non-web platforms.
/// Returns empty/null since sessionStorage is only available on web.
library;

Set<String> getStoredSelections(String electionId) => {};

void saveStoredSelections(String electionId, Set<String> selections) {}

void clearStoredSelections(String electionId) {}

/// Gets stored candidate order from sessionStorage.
List<String>? getStoredCandidateOrder(String electionId) => null;

/// Saves candidate order to sessionStorage.
void saveStoredCandidateOrder(String electionId, List<String> order) {}

/// Clears all stored selections and candidate order.
void clearAllStoredSelectionData() {}
