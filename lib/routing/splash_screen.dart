import 'package:flutter/material.dart';
import 'package:luckyui/luckyui.dart';
import '../core/constants/app_constants.dart';

/// Simple splash screen shown while checking authentication status.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LuckyHeading(text: AppConstants.appName),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
