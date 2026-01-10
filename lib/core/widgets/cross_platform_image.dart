import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional imports for web
// ignore: avoid_web_libraries_in_flutter
import 'cross_platform_image_stub.dart'
    if (dart.library.html) 'cross_platform_image_web.dart' as platform_image;

/// A cross-platform network image widget that handles CORS issues on web.
/// On web, it uses HTML img elements which are not subject to CORS restrictions.
/// On other platforms, it uses standard Image.network.
class CrossPlatformImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;

  const CrossPlatformImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return platform_image.WebImage(
        imageUrl: imageUrl,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }

    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
    );
  }
}
