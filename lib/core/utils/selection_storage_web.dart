// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

const _keyPrefix = 'selections_';

/// Gets stored selections from sessionStorage.
Set<String> getStoredSelections(String electionId) {
  try {
    final key = '$_keyPrefix$electionId';
    final stored = html.window.sessionStorage[key];
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
    html.window.sessionStorage.remove(key);
  } else {
    html.window.sessionStorage[key] = jsonEncode(selections.toList());
  }
}

/// Clears selections from sessionStorage.
void clearStoredSelections(String electionId) {
  html.window.sessionStorage.remove('$_keyPrefix$electionId');
}

const _orderKeyPrefix = 'candidate_order_';

/// Gets stored candidate order from sessionStorage.
List<String>? getStoredCandidateOrder(String electionId) {
  try {
    final key = '$_orderKeyPrefix$electionId';
    final stored = html.window.sessionStorage[key];
    if (stored == null || stored.isEmpty) return null;

    final List<dynamic> decoded = jsonDecode(stored);
    return decoded.cast<String>();
  } catch (_) {
    return null;
  }
}

/// Saves candidate order to sessionStorage.
void saveStoredCandidateOrder(String electionId, List<String> order) {
  final key = '$_orderKeyPrefix$electionId';
  html.window.sessionStorage[key] = jsonEncode(order);
}
