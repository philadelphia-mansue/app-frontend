// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Web-specific image widget that uses HTML img elements.
/// HTML img tags are not subject to CORS restrictions for simple image loading,
/// unlike XMLHttpRequest which is used by Image.network on web.
class WebImage extends StatefulWidget {
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
  State<WebImage> createState() => _WebImageState();
}

class _WebImageState extends State<WebImage> {
  late String _viewType;
  bool _hasError = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'web-image-${widget.imageUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
  }

  @override
  void didUpdateWidget(WebImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _viewType = 'web-image-${widget.imageUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
      _hasError = false;
      _isLoaded = false;
      _registerView();
    }
  }

  void _registerView() {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final img = html.ImageElement()
          ..src = widget.imageUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = _boxFitToCss(widget.fit)
          ..style.display = 'block'
          ..style.pointerEvents = 'none';

        img.onLoad.listen((_) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        });

        img.onError.listen((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });

        return img;
      },
    );
  }

  String _boxFitToCss(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'scale-down';
      case BoxFit.fitHeight:
        return 'scale-down';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, 'Image failed to load', null);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: HtmlElementView(viewType: _viewType),
        ),
        if (!_isLoaded && !_hasError)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
