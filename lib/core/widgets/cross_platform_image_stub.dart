import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms.
/// This should never be called on non-web platforms since CrossPlatformImage
/// uses Image.network directly for them.
class WebImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const WebImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback to Image.network on non-web platforms
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
