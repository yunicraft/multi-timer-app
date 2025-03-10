import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timefolio/theme/app_colors.dart';
import '../utils/onboarding_util.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 페이지에서는 온보딩을 완료하고 홈 화면으로 이동
      _completeOnboarding();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    // 온보딩을 건너뛰어도 완료로 표시
    _completeOnboarding();
  }

  // 온보딩 완료 처리
  void _completeOnboarding() async {
    // 온보딩을 봤다고 표시
    await OnboardingUtil.markOnboardingAsSeen();
    // 홈 화면으로 이동
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (제목과 건너뛰기 버튼)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'skip',
                      style: TextStyle(color: AppColors.gold),
                    ),
                  ),
                ],
              ),
            ),

            // 온보딩 콘텐츠 (페이지 뷰)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // 온보딩 페이지 1 (커스텀 구현)
                  _buildFirstOnboardingPage(),

                  // 온보딩 페이지 2
                  OnboardingPage(
                    title: '01 태스크 만들기',
                    description: '화면 상단의 + 버튼을 클릭해서\n수행할 일의 이름을 정해 보아요.',
                    imagePath: null,
                  ),

                  // 온보딩 페이지 3
                  OnboardingPage(
                    title: '01 태스크 만들기',
                    description: '원하는 태스크 명칭을 입력하고 저장해요.',
                    imagePath: null,
                  ),

                  // 온보딩 페이지 4
                  OnboardingPage(
                    title: '01 태스크 만들기',
                    description: '태스크 순서를 바꾸고 싶다면\n태스크 명칭을 꾹 눌러서 옮겨 주세요.',
                    imagePath: null,
                  ),

                  // 온보딩 페이지 5
                  OnboardingPage(
                    title: '02 타이머 사용하기',
                    description:
                        '태스크 명칭을 터치하면 색상이\n바뀌면서 타이머가 시작되어요.\n\n타이머를 멈추고 싶다면\n다시 한 번 클릭해요.',
                    imagePath: null,
                  ),

                  // 온보딩 페이지 6
                  OnboardingPage(
                    title: '03 기록 보기',
                    description: '통계 아이콘을 클릭하면\n오늘 하루의 통계를 볼 수 있어요.',
                    imagePath: null,
                  ),
                ],
              ),
            ),

            // 하단 네비게이션 (페이지 인디케이터와 버튼)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 뒤로가기 버튼
                  TextButton(
                    onPressed: _goToPreviousPage,
                    child: Text(
                      'back',
                      style: TextStyle(color: AppColors.gold),
                    ),
                  ),

                  // 페이지 인디케이터
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _totalPages,
                    effect: WormEffect(
                      dotColor: Colors.grey.shade800,
                      activeDotColor: AppColors.gold,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),

                  // 다음 버튼
                  TextButton(
                    onPressed: _goToNextPage,
                    child: Text(
                      'next',
                      style: TextStyle(color: AppColors.gold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 첫 번째 온보딩 페이지 위젯
  Widget _buildFirstOnboardingPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          const Text(
            '올해 이루고 싶은\n목표가 있나요?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),

          // 설명 (Timefolio 강조)
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
              children: [
                TextSpan(
                  text: 'Timefolio',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text:
                      ' 가\n목표를 현실로 만들 수\n있게 도와 드릴게요.\n\n터치로 하루 24시간을\n통제해 보세요.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 이미지 대체 위젯
  Widget _buildPlaceholderImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: AppColors.gold.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              '이미지 준비 중',
              style: TextStyle(
                color: AppColors.gold.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 온보딩 페이지 위젯 (2~6 페이지용)
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String? imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // _OnboardingScreenState의 _buildPlaceholderImage 메서드에 접근
    final state = context.findAncestorStateOfType<_OnboardingScreenState>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        children: [
          // 텍스트 영역
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                title,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 설명
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // 이미지 영역 (화면 중앙에 고정)
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.25, // 화면 높이의 25% 위치에 고정
            child: Container(
              height: 250, // 고정 높이
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: imagePath != null
                      ? Image.asset(
                          imagePath!,
                          fit: BoxFit.contain,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            // 이미지 로드 실패 시 대체 UI
                            return state?._buildPlaceholderImage() ??
                                const SizedBox.shrink();
                          },
                        )
                      : state?._buildPlaceholderImage() ??
                          const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
