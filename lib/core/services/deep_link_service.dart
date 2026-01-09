import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Service for handling deep links from QR codes.
/// Parses URLs like: philadelphiamansue://vote?election=123
/// Or: https://domain.com/vote?election=123
abstract class DeepLinkService {
  /// Stream of incoming deep links (for when app is already running)
  Stream<Uri> get linkStream;

  /// Get the initial link that launched the app (cold start)
  Future<Uri?> getInitialLink();

  /// Parse election ID from a deep link URI
  /// Returns null if the URI doesn't contain an election parameter
  String? parseElectionId(Uri uri);
}

class DeepLinkServiceImpl implements DeepLinkService {
  final AppLinks _appLinks;

  DeepLinkServiceImpl({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  @override
  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  @override
  Future<Uri?> getInitialLink() async {
    try {
      final linkString = await _appLinks.getInitialLinkString();
      if (linkString == null) return null;
      final uri = Uri.tryParse(linkString);
      debugPrint('[DeepLink] Initial link: $uri');
      return uri;
    } catch (e) {
      debugPrint('[DeepLink] Error getting initial link: $e');
      return null;
    }
  }

  @override
  String? parseElectionId(Uri uri) {
    // Handle both:
    // - philadelphiamansue://vote?election=123
    // - https://domain.com/vote?election=123
    // - /vote?election=123

    final path = uri.path.replaceFirst(RegExp(r'^/'), ''); // Remove leading slash

    if (path == 'vote' || uri.host == 'vote') {
      final electionId = uri.queryParameters['election'];
      debugPrint('[DeepLink] Parsed election ID: $electionId from $uri');
      return electionId;
    }

    debugPrint('[DeepLink] No election ID found in $uri');
    return null;
  }
}
