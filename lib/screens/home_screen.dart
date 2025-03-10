import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
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
  DateTime selectedDate = DateTime.now();

  // 서비스 프로바이더
  final _serviceProvider = ServiceProvider();

  // 태스크 서비스
  late final TaskService _taskService;

  // 현재 편집 중인 태스크 ID
  int? _editingTaskId;

  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  // 태스크 추가 중복 방지를 위한 플래그
  bool _isAddingTask = false;

  // 리스트뷰 키
  final GlobalKey _listViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _taskService = _serviceProvider.taskService;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    // 이미 태스크 추가 중이면 무시
    if (_isAddingTask) return;

    // 태스크 추가 중 플래그 설정
    _isAddingTask = true;

    final tasks = _taskService.getTasks();
    final newTaskName = '새 태스크 ${tasks.length + 1}';
    final newTask = _taskService.addTask(newTaskName);

    setState(() {
      // 새 태스크를 편집 모드로 설정
      _editingTaskId = newTask.id;
    });

    // 새 태스크로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 다음 프레임에서 스크롤 위치 조정
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    // 딜레이 후 플래그 해제
    Future.delayed(const Duration(milliseconds: 500), () {
      _isAddingTask = false;
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
        'index': taskIndex + 1,
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
    final formattedDate = dateFormat.format(selectedDate);

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
            fontSize: 20,
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
      child: Scrollbar(
        controller: _scrollController,
        child: ReorderableListView.builder(
          key: _listViewKey,
          scrollController: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              // TaskService에서 이미 인덱스 조정을 하므로 여기서는 제거
              _taskService.reorderTasks(oldIndex, newIndex);
            });
          },
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              key: ValueKey(task.id),
              padding: const EdgeInsets.only(right: 28.0),
              child: Row(
                children: [
                  // 태스크 번호 (ID 대신 순번 표시)
                  Container(
                    width: 30,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 태스크 내용 (드래그 가능한 영역)
                  Expanded(
                    child: ReorderableDragStartListener(
                      index: index,
                      child: EditableTaskItem(
                        key: ValueKey('${task.id}_item'),
                        task: task,
                        index: index,
                        isEditing: task.id == _editingTaskId,
                        onToggleTimer: () => _toggleTaskTimer(task.id),
                        onShowDetails: () => _showTaskDetails(task.id),
                        onDelete: () => _deleteTask(task.id),
                        onNameChanged: (newName) =>
                            _updateTaskName(task.id, newName),
                        showTaskNumber: false,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
