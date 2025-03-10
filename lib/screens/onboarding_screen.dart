import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
      backgroundColor: Colors.black,
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
                    child: const Text(
                      'skip',
                      style: TextStyle(color: Colors.white),
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
                  // 온보딩 페이지 1
                  OnboardingPage(
                    title: '올해 이루고 싶은\n목표가 있나요?',
                    description:
                        'Timefolio가\n목표를 현실로 만들 수\n있게 도와 드릴게요.\n\n터치로 하루 24시간을\n통제해 보세요.',
                  ),

                  // 온보딩 페이지 2
                  OnboardingPage(
                    title: '01 태스크 만들기',
                    description: '화면 상단의 + 버튼을\n클릭해서 수행할 일의 이름을\n정해 보아요.',
                    imagePath: null,
                    imageCaption: '+ 위치 보이는 화면',
                  ),

                  // 온보딩 페이지 3
                  OnboardingPage(
                    title: '01 태스크 만들기',
                    description: '원하는 태스크 명칭을 입력하\n고 저장해요.',
                    imagePath: null,
                    imageCaption: '태스크 입력 모달\n나타난 화면',
                  ),

                  // 온보딩 페이지 4
                  OnboardingPage(
                    title: '01 태스크 만들기',
                    description:
                        '태스크 순서를 바꾸고 싶다면,\n태스크 명칭을 꾹 누르시 옮겨\n주세요. 드래그&드롭으로 쉽게\n사용할 수도 있어요.',
                    imagePath: null,
                    imageCaption: '태스크 입력 모달\n나타난 화면',
                  ),

                  // 온보딩 페이지 5
                  OnboardingPage(
                    title: '02 타이머 사용하기',
                    description:
                        '측정할 시작할 태스크 명칭을\n터치하면 색상이 바뀌면서 타\n이머가 시작되요.\n타이머를 멈추고 싶다면, 다시\n한 번 클릭해요.',
                    imagePath: null,
                    imageCaption: '색상이 바뀌면서\n타이머 시간이 흐르는\n화면',
                  ),

                  // 온보딩 페이지 6
                  OnboardingPage(
                    title: '03 기록 보기',
                    description: '통계 아이콘을 클릭하면 오늘\n하루의 통계를 볼 수 있어요.',
                    imagePath: null,
                    imageCaption: '통계 아이콘 위치\n확대한 화면',
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
                    child: const Text(
                      'back',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  // 페이지 인디케이터
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _totalPages,
                    effect: const WormEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),

                  // 다음 버튼
                  TextButton(
                    onPressed: _goToNextPage,
                    child: const Text(
                      'next',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // 하단 안내 텍스트
            if (_currentPage == _totalPages - 1)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '[주의] start/stop에 사용되는 컬러를 사용\n자가 지정할 수 있게 해도 좋을 듯',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 온보딩 페이지 위젯
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String? imagePath;
  final String? imageCaption;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    this.imagePath,
    this.imageCaption,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
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
          const SizedBox(height: 32),

          // 이미지 영역 (항상 표시)
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 이미지 (있는 경우) 또는 대체 UI
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: imagePath != null
                          ? Image.asset(
                              imagePath!,
                              fit: BoxFit.contain,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                // 이미지 로드 실패 시 대체 UI
                                return _buildPlaceholderImage();
                              },
                            )
                          : _buildPlaceholderImage(),
                    ),

                    // 이미지 캡션 (있는 경우)
                    if (imageCaption != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          imageCaption!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.white54,
            ),
            SizedBox(height: 8),
            Text(
              '이미지 준비 중',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
