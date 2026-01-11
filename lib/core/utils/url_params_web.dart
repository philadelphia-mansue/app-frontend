import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as html;

/// Parses browser URL query params from multiple sources.
/// With hash routing, query params can be in two places:
/// 1. Main URL (before #): https://example.com/?election_id=xxx#/path
/// 2. Hash fragment (after #): https://example.com/#/path?election_id=xxx
Map<String, String> _getBrowserQueryParams() {
  try {
    final params = <String, String>{};

    // First, check main URL query params (before #)
    final search = html.window.location.search;
    if (search.isNotEmpty) {
      final queryString = search.startsWith('?') ? search.substring(1) : search;
      params.addAll(Uri.splitQueryString(queryString));
    }

    // Then, check hash fragment for query params (after #)
    // Hash format: #/path?param=value or #/path
    final hash = html.window.location.hash;
    if (hash.isNotEmpty) {
      final hashContent = hash.startsWith('#') ? hash.substring(1) : hash;
      final queryIndex = hashContent.indexOf('?');
      if (queryIndex != -1) {
        final hashQuery = hashContent.substring(queryIndex + 1);
        params.addAll(Uri.splitQueryString(hashQuery));
      }
    }

    debugPrint('[URLParams] Extracted params: $params (search=$search, hash=$hash)');
    return params;
  } catch (e) {
    debugPrint('[URLParams] Error extracting params: $e');
    return {};
  }
}

/// Gets election_id from browser URL query params.
String? getBrowserElectionId() {
  final electionId = _getBrowserQueryParams()['election_id'];
  debugPrint('[URLParams] getBrowserElectionId: $electionId');
  return electionId;
}

/// Gets phone number from browser URL query params.
String? getBrowserPhone() {
  return _getBrowserQueryParams()['phone'];
}

/// Gets magic token from browser URL query params.
String? getBrowserMagicToken() {
  return _getBrowserQueryParams()['magic_token'];
}
