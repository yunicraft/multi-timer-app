import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:timefolio/models/task.dart';
import 'package:timefolio/services/service_provider.dart';
import 'package:timefolio/services/task_service.dart';
import 'package:timefolio/theme/app_colors.dart';
import 'package:timefolio/widgets/app_drawer.dart';
import 'package:timefolio/widgets/editable_task_item.dart';
import 'package:timefolio/widgets/empty_task_message.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeScreen({super.key, this.scaffoldKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 현재 날짜
  DateTime _selectedDate = DateTime.now();

  // 서비스 프로바이더
  final _serviceProvider = ServiceProvider();

  // 태스크 서비스
  late final TaskService _taskService;

  // 현재 편집 중인 태스크 ID
  int? _editingTaskId;

  @override
  void initState() {
    super.initState();
    _taskService = _serviceProvider.taskService;
  }

  // 온보딩 화면으로 이동하는 함수
  void _goToOnboarding(BuildContext context) {
    context.push('/onboarding');
  }

  // 리포트 화면으로 이동하는 함수
  void _goToReport(BuildContext context) {
    context.push('/report');
  }

  // 태스크 추가 함수
  void _addTask() {
    final newTask = _taskService.addTask('');

    setState(() {
      // 새 태스크를 편집 모드로 설정
      _editingTaskId = newTask.id;
    });
  }

  // 태스크 이름 변경 함수
  void _updateTaskName(int taskId, String newName) {
    setState(() {
      // 위젯에서 이미 빈 이름 처리를 했으므로 그대로 사용
      _taskService.updateTaskName(taskId, newName);
      _editingTaskId = null; // 편집 모드 종료
    });
  }

  // 태스크 이름 편집 함수 (다이얼로그 방식 - 상세 화면에서 사용)
  void _editTaskName(int taskId) {
    final tasks = _taskService.getTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];
    final TextEditingController controller =
        TextEditingController(text: task.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('태스크 ${task.id} 수정'),
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
              // 이름이 비어있으면 기본 이름 설정
              if (controller.text.trim().isEmpty) {
                controller.text = '새 태스크 ${task.id}';
              }

              setState(() {
                _taskService.updateTaskName(task.id, controller.text);
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  // 태스크 타이머 시작/중지 함수
  void _toggleTaskTimer(int taskId) {
    setState(() {
      _taskService.toggleTaskTimer(taskId);
    });
  }

  // 태스크 삭제 함수
  void _deleteTask(int taskId) {
    setState(() {
      _taskService.deleteTask(taskId);
    });
  }

  // 태스크 상세 정보 보기 함수
  void _showTaskDetails(int taskId) {
    final tasks = _taskService.getTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];
    context.push(
      '/task/${task.id}',
      extra: {
        'name': task.name,
        'onNameChanged': (String newName) {
          setState(() {
            _taskService.updateTaskName(task.id, newName);
          });
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 현재 날짜 포맷
    final dateFormat = DateFormat('yyyy.MM.dd');
    final formattedDate = dateFormat.format(_selectedDate);

    // 태스크 목록
    final tasks = _taskService.getTasks();

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.darkBackground,

      // 메뉴 드로어
      drawer: AppDrawer(
        onOnboardingTap: () => _goToOnboarding(context),
        onShareTap: () {
          // TODO: 공유 기능 구현
        },
        onContactTap: () {
          // TODO: 문의하기 기능 구현
        },
        onPrivacyPolicyTap: () {
          // TODO: 개인정보 처리방침 페이지로 이동
        },
        onTermsOfServiceTap: () {
          // TODO: 이용약관 페이지로 이동
        },
        onVersionInfoTap: () {
          // TODO: 버전 정보 표시
        },
      ),

      // 앱바 사용
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          formattedDate,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 리포트 버튼
          IconButton(
            icon: const Icon(Icons.assessment, color: Colors.white),
            tooltip: '통계 보기',
            onPressed: () => _goToReport(context),
          ),
          // 태스크 추가 버튼
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: '태스크 추가',
            onPressed: _addTask,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 태스크가 없을 때 메시지
            if (tasks.isEmpty) const EmptyTaskMessage(),

            // 태스크 목록
            if (tasks.isNotEmpty) _buildTaskList(tasks),
          ],
        ),
      ),
    );
  }

  // 태스크 목록 위젯
  Widget _buildTaskList(List<Task> tasks) {
    return Expanded(
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            _taskService.reorderTasks(oldIndex, newIndex);
          });
        },
        itemBuilder: (context, index) {
          final task = tasks[index];
          return EditableTaskItem(
            key: ValueKey(task.id),
            task: task,
            index: index,
            isEditing: task.id == _editingTaskId,
            onToggleTimer: () => _toggleTaskTimer(task.id),
            onShowDetails: () => _showTaskDetails(task.id),
            onNameChanged: (newName) => _updateTaskName(task.id, newName),
          );
        },
      ),
    );
  }
}
