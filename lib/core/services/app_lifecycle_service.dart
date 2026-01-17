import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

/// A widget that observes app lifecycle changes and refreshes the token on resume.
/// This ensures the user's authentication is still valid when returning to the app.
class AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleObserver({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[AppLifecycleObserver] Observer registered');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[AppLifecycleObserver] Observer removed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[AppLifecycleObserver] App lifecycle state changed: $state');
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  void _onAppResumed() {
    debugPrint('[AppLifecycleObserver] App resumed - refreshing token');
    ref.read(authNotifierProvider.notifier).refreshToken();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
