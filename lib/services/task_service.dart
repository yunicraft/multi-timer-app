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
      final wasRunning = task.isRunning;
      task.isRunning = !wasRunning;

      if (task.isRunning) {
        // 타이머 시작
        task.startTime = DateTime.now();
        task.endTime = null;

        // 다른 실행 중인 태스크가 있으면 중지
        for (final otherTask in _tasks) {
          if (otherTask.id != taskId && otherTask.isRunning) {
            otherTask.isRunning = false;
            otherTask.endTime = DateTime.now();

            // 다른 태스크의 기록 추가
            if (otherTask.startTime != null && otherTask.endTime != null) {
              otherTask.records.add(TaskRecord(
                startTime: otherTask.startTime!,
                endTime: otherTask.endTime!,
              ));
            }
          }
        }
      } else {
        // 타이머 중지
        task.endTime = DateTime.now();

        // 기록 추가
        if (task.startTime != null && task.endTime != null) {
          task.records.add(TaskRecord(
            startTime: task.startTime!,
            endTime: task.endTime!,
          ));
        }
      }

      // 변경사항 저장
      _saveToPrefs();
    }
  }

  // 태스크 기록 가져오기
  List<TaskRecord> getTaskRecords(int taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      // 오름차순 정렬 (오래된 기록이 먼저 오도록)
      final records = List<TaskRecord>.from(_tasks[taskIndex].records);
      records.sort((a, b) => a.startTime.compareTo(b.startTime));
      return records;
    }
    return [];
  }

  // 현재 측정 중인 태스크인지 확인
  bool isTaskRunning(int taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      return _tasks[taskIndex].isRunning;
    }
    return false;
  }

  // 현재 측정 중인 태스크의 시작 시간 가져오기
  DateTime? getTaskStartTime(int taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1 && _tasks[taskIndex].isRunning) {
      return _tasks[taskIndex].startTime;
    }
    return null;
  }

  // 태스크 레코드 추가
  void addTaskRecord(int taskId, DateTime startTime, DateTime endTime) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].records.add(TaskRecord(
            startTime: startTime,
            endTime: endTime,
          ));

      // 변경사항 저장
      _saveToPrefs();
    }
  }

  // 태스크 레코드 삭제
  void deleteTaskRecord(int taskId, int recordIndex) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1 &&
        recordIndex >= 0 &&
        recordIndex < _tasks[taskIndex].records.length) {
      _tasks[taskIndex].records.removeAt(recordIndex);

      // 변경사항 저장
      _saveToPrefs();
    }
  }

  // 태스크 총 기록 시간 가져오기 (초 단위)
  int getTaskTotalDuration(int taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      int total = _tasks[taskIndex].totalDurationInSeconds;

      // 현재 측정 중인 시간도 포함
      if (_tasks[taskIndex].isRunning && _tasks[taskIndex].startTime != null) {
        total +=
            DateTime.now().difference(_tasks[taskIndex].startTime!).inSeconds;
      }

      return total;
    }
    return 0;
  }
}
