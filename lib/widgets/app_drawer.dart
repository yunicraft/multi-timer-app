import 'package:flutter/material.dart';
import 'package:timefolio/theme/app_colors.dart';
import 'package:timefolio/widgets/drawer_menu_item.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onOnboardingTap;
  final VoidCallback onShareTap;
  final VoidCallback onContactTap;
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onTermsOfServiceTap;
  final VoidCallback onVersionInfoTap;

  const AppDrawer({
    super.key,
    required this.onOnboardingTap,
    required this.onShareTap,
    required this.onContactTap,
    required this.onPrivacyPolicyTap,
    required this.onTermsOfServiceTap,
    required this.onVersionInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.darkSurface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.darkCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Timefolio',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '당신의 시간 자산, 제대로 투자하세요.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            DrawerMenuItem(
              icon: Icons.help_outline,
              title: '앱 사용 방법',
              onTap: onOnboardingTap,
            ),
            DrawerMenuItem(
              icon: Icons.share,
              title: '공유하고 포인트 받기',
              onTap: onShareTap,
            ),
            DrawerMenuItem(
              icon: Icons.email_outlined,
              title: '문의하기',
              onTap: onContactTap,
            ),
            const Divider(color: AppColors.outline),
            DrawerMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보 처리방침',
              onTap: onPrivacyPolicyTap,
            ),
            DrawerMenuItem(
              icon: Icons.description_outlined,
              title: '이용약관',
              onTap: onTermsOfServiceTap,
            ),
            DrawerMenuItem(
              icon: Icons.info_outline,
              title: '버전 정보',
              onTap: onVersionInfoTap,
            ),
          ],
        ),
      ),
    );
  }
}
