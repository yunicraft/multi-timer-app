import 'package:shared_preferences/shared_preferences.dart';

class OnboardingUtil {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  // 온보딩을 본 적이 있는지 확인
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  // 온보딩을 봤다고 표시
  static Future<void> markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  // 온보딩 상태 초기화 (테스트용)
  static Future<void> resetOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, false);
  }
}
