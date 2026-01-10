import 'package:web/web.dart' as html;

/// Parses browser URL query params.
/// With hash routing, query params in the main URL (before #) are not
/// accessible via GoRouter, so we need to read them directly from window.location.
Map<String, String> _getBrowserQueryParams() {
  try {
    final search = html.window.location.search;
    if (search.isEmpty) return {};

    // Parse query string (remove leading ?)
    final queryString = search.startsWith('?') ? search.substring(1) : search;
    return Uri.splitQueryString(queryString);
  } catch (e) {
    return {};
  }
}

/// Gets election_id from browser URL query params.
String? getBrowserElectionId() {
  return _getBrowserQueryParams()['election_id'];
}

/// Gets phone number from browser URL query params.
String? getBrowserPhone() {
  return _getBrowserQueryParams()['phone'];
}

/// Gets magic token from browser URL query params.
String? getBrowserMagicToken() {
  return _getBrowserQueryParams()['magic_token'];
}
