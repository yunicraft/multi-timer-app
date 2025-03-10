import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timefolio/models/task.dart';

class TaskService {
  // 태스크 목록
  final List<Task> _tasks = [];

  // 다음 태스크 ID
  int _nextTaskId = 1;

  // SharedPreferences 키
  static const String _tasksKey = 'tasks';
  static const String _nextTaskIdKey = 'nextTaskId';

  // 초기화 완료 여부
  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  // 생성자
  TaskService() {
    _initializationFuture = _initialize();
  }

  // 초기화
  Future<void> _initialize() async {
    if (!_isInitialized) {
      await _loadFromPrefs();
      _isInitialized = true;
    }
  }

  // 초기화가 완료될 때까지 기다림
  Future<void> waitForInitialization() async {
    await _initializationFuture;
  }

  // 로컬 저장소에서 데이터 로드
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // 다음 태스크 ID 로드
    _nextTaskId = prefs.getInt(_nextTaskIdKey) ?? 1;

    // 태스크 목록 로드
    final tasksJson = prefs.getStringList(_tasksKey);
    if (tasksJson != null) {
      _tasks.clear();
      for (final taskJson in tasksJson) {
        final taskMap = jsonDecode(taskJson);
        _tasks.add(Task.fromJson(taskMap));
      }
    }
  }

  // 로컬 저장소에 데이터 저장
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // 다음 태스크 ID 저장
    await prefs.setInt(_nextTaskIdKey, _nextTaskId);

    // 태스크 목록 저장
    final tasksJson = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  // 태스크 목록 가져오기
  List<Task> getTasks() {
    return _tasks;
  }

  // 태스크 추가
  Task addTask(String name) {
    final newTask = Task(
      id: _nextTaskId,
      name: name,
    );
    _tasks.add(newTask);
    _nextTaskId++;

    // 변경사항 저장
    _saveToPrefs();

    return newTask;
  }

  // 태스크 이름 수정
  void updateTaskName(int taskId, String newName) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].name = newName;

      // 변경사항 저장
      _saveToPrefs();
    }
  }

  // 태스크 삭제
  void deleteTask(int taskId) {
    _tasks.removeWhere((task) => task.id == taskId);

    // 변경사항 저장
    _saveToPrefs();
  }

  // 태스크 순서 변경
  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);

    // 변경사항 저장
    _saveToPrefs();
  }

  // 태스크 타이머 시작/중지
  void toggleTaskTimer(int taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      task.isRunning = !task.isRunning;

      if (task.isRunning) {
        // 타이머 시작
        task.startTime = DateTime.now();
        task.endTime = null;

        // 다른 실행 중인 태스크가 있으면 중지
        for (final otherTask in _tasks) {
          if (otherTask.id != taskId && otherTask.isRunning) {
            otherTask.isRunning = false;
            otherTask.endTime = DateTime.now();
          }
        }
      } else {
        // 타이머 중지
        task.endTime = DateTime.now();
      }

      // 변경사항 저장
      _saveToPrefs();
    }
  }
}
