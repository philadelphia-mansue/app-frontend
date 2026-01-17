/// Stub implementation for non-web platforms.
/// Returns empty/null since sessionStorage is only available on web.
library;

Set<String> getStoredSelections(String electionId) => {};

void saveStoredSelections(String electionId, Set<String> selections) {}

void clearStoredSelections(String electionId) {}

/// Clears all stored selections.
void clearAllStoredSelectionData() {}
