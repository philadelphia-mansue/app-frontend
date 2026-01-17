import 'dart:convert';
import 'package:web/web.dart' as html;

const _keyPrefix = 'selections_';

/// Gets stored selections from sessionStorage.
Set<String> getStoredSelections(String electionId) {
  try {
    final key = '$_keyPrefix$electionId';
    final stored = html.window.sessionStorage.getItem(key);
    if (stored == null || stored.isEmpty) return {};

    final List<dynamic> decoded = jsonDecode(stored);
    return decoded.cast<String>().toSet();
  } catch (_) {
    return {};
  }
}

/// Saves selections to sessionStorage.
void saveStoredSelections(String electionId, Set<String> selections) {
  final key = '$_keyPrefix$electionId';
  if (selections.isEmpty) {
    html.window.sessionStorage.removeItem(key);
  } else {
    html.window.sessionStorage.setItem(key, jsonEncode(selections.toList()));
  }
}

/// Clears selections from sessionStorage.
void clearStoredSelections(String electionId) {
  html.window.sessionStorage.removeItem('$_keyPrefix$electionId');
}

/// Clears all stored selections from sessionStorage.
/// Called on logout to prevent data leakage between users.
void clearAllStoredSelectionData() {
  final storage = html.window.sessionStorage;
  final keysToRemove = <String>[];

  // Find all keys with our prefix
  for (var i = 0; i < storage.length; i++) {
    final key = storage.key(i);
    if (key != null && key.startsWith(_keyPrefix)) {
      keysToRemove.add(key);
    }
  }

  // Remove them
  for (final key in keysToRemove) {
    storage.removeItem(key);
  }
}
