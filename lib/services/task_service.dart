import 'package:timefolio/models/task.dart';

class TaskService {
  // 태스크 목록
  final List<Task> _tasks = [];

  // 다음 태스크 ID
  int _nextTaskId = 1;

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
    return newTask;
  }

  // 태스크 이름 수정
  void updateTaskName(int taskId, String newName) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].name = newName;
    }
  }

  // 태스크 삭제
  void deleteTask(int taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
  }

  // 태스크 순서 변경
  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
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
    }
  }
}
