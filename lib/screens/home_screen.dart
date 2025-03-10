import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/onboarding_util.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeScreen({super.key, this.scaffoldKey});

  // 온보딩 화면으로 이동하는 함수
  void _goToOnboarding(BuildContext context) {
    context.go('/onboarding');
  }

  // 온보딩 상태를 초기화하는 함수 (테스트용)
  void _resetOnboardingStatus(BuildContext context) async {
    await OnboardingUtil.resetOnboardingStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('온보딩 상태가 초기화되었습니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Timefolio"),
        actions: [
          // 온보딩 화면으로 이동하는 액션 버튼 (테스트용)
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '온보딩 화면 보기 (테스트용)',
            onPressed: () => _goToOnboarding(context),
          ),
          // 온보딩 상태 초기화 버튼 (테스트용)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '온보딩 상태 초기화 (테스트용)',
            onPressed: () => _resetOnboardingStatus(context),
          ),
        ],
      ),
      body: const Center(
        child: Text("Timefolio 홈 화면"),
      ),
    );
  }
}
