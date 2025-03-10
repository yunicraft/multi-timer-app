import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timefolio/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeScreen({super.key, this.scaffoldKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 현재 날짜
  DateTime _selectedDate = DateTime.now();

  // 태스크 목록 (임시 데이터)
  final List<String> _tasks = [];

  // 온보딩 화면으로 이동하는 함수
  void _goToOnboarding(BuildContext context) {
    context.go('/onboarding');
  }

  // 리포트 화면으로 이동하는 함수
  void _goToReport(BuildContext context) {
    context.go('/report');
  }

  // 태스크 추가 다이얼로그 표시
  void _showAddTaskDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('태스크 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '태스크 이름을 입력하세요',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _tasks.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // 메뉴 드로어 열기
  void _openDrawer() {
    widget.scaffoldKey?.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 날짜 포맷
    final dateFormat = DateFormat('yyyy.MM.dd');
    final formattedDate = dateFormat.format(_selectedDate);

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.darkBackground,

      // 메뉴 드로어
      drawer: _buildDrawer(),

      // 앱바 대신 커스텀 헤더 사용
      appBar: null,

      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (메뉴 버튼, 날짜, 리포트 버튼, 태스크 추가 버튼)
            _buildHeader(formattedDate),

            // 태스크가 없을 때 메시지
            if (_tasks.isEmpty) _buildEmptyTaskMessage(),

            // 태스크 목록
            if (_tasks.isNotEmpty) _buildTaskList(),
          ],
        ),
      ),
    );
  }

  // 상단 헤더 위젯
  Widget _buildHeader(String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 메뉴 버튼
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: _openDrawer,
          ),

          // 날짜
          Text(
            formattedDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 리포트 버튼과 태스크 추가 버튼
          Row(
            children: [
              // 리포트 버튼
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Text(
                    'R',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _goToReport(context),
                ),
              ),
              const SizedBox(width: 8),
              // 태스크 추가 버튼
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _showAddTaskDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 태스크가 없을 때 메시지 위젯
  Widget _buildEmptyTaskMessage() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '아직 태스크가 없어요!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '상단의 + 버튼으로 생성해주세요.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 태스크 목록 위젯
  Widget _buildTaskList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: AppColors.darkCard,
            child: ListTile(
              title: Text(
                _tasks[index],
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: AppColors.gold),
                    onPressed: () {
                      // TODO: 태스크 시작 기능 구현
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white54),
                    onPressed: () {
                      setState(() {
                        _tasks.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 메뉴 드로어 위젯
  Widget _buildDrawer() {
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
            _buildDrawerItem(
              icon: Icons.help_outline,
              title: '앱 사용 방법',
              onTap: () => _goToOnboarding(context),
            ),
            _buildDrawerItem(
              icon: Icons.share,
              title: '공유하고 포인트 받기',
              onTap: () {
                // TODO: 공유 기능 구현
              },
            ),
            _buildDrawerItem(
              icon: Icons.email_outlined,
              title: '문의하기',
              onTap: () {
                // TODO: 문의하기 기능 구현
              },
            ),
            const Divider(color: AppColors.outline),
            _buildDrawerItem(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보 처리방침',
              onTap: () {
                // TODO: 개인정보 처리방침 페이지로 이동
              },
            ),
            _buildDrawerItem(
              icon: Icons.description_outlined,
              title: '이용약관',
              onTap: () {
                // TODO: 이용약관 페이지로 이동
              },
            ),
            _buildDrawerItem(
              icon: Icons.info_outline,
              title: '버전 정보',
              onTap: () {
                // TODO: 버전 정보 표시
              },
            ),
          ],
        ),
      ),
    );
  }

  // 드로어 아이템 위젯
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
