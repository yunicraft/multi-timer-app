import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/back_button_handler.dart';
import 'package:flutter/material.dart';

// 모든 화면은 BackButtonHandler 로 감싸야 함.
// GlobalKey<ScaffoldState>()는 home 화면에서 드로어 열림을 제어하기 위해 사용.

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  observers: [],
  initialLocation: '/',
  routes: [
    // 스플래시 화면 (초기 화면)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // 온보딩 화면
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // 메인 앱 화면들
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return BackButtonHandler(
          scaffoldKey: GlobalKey<ScaffoldState>(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final scaffoldKey = GlobalKey<ScaffoldState>();
            return HomeScreen(scaffoldKey: scaffoldKey);
          },
        ),
      ],
    ),
  ],
);
