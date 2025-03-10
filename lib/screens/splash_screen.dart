import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:timefolio/utils/onboarding_util.dart';
// import '../utils/onboarding_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // 다음 화면으로 이동하는 함수
  void _navigateToNextScreen() async {
    // 3초 후 홈 화면으로 이동
    await Future.delayed(const Duration(seconds: 3));

    final hasSeenOnboarding = await OnboardingUtil.hasSeenOnboarding();
    final nextRoute = hasSeenOnboarding ? '/home' : '/onboarding';

    if (mounted) {
      context.go(nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E), // 어두운 배경색
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Timefolio',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700), // 황금색
              ),
            ),
          ],
        ),
      ),
    );
  }
}
