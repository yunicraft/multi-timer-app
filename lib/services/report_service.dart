import 'package:timefolio/models/task.dart';
import 'package:timefolio/services/task_service.dart';
import 'package:intl/intl.dart';

class TaskStatistics {
  final String taskName;
  final int taskId;
  final int totalDuration; // 초 단위
  final double percentage; // 전체 시간 대비 비율

  TaskStatistics({
    required this.taskName,
    required this.taskId,
    required this.totalDuration,
    required this.percentage,
  });

  // 시간 형식으로 변환 (HH:MM:SS)
  String get formattedDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final seconds = totalDuration % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 시간 형식으로 변환 (시간 분)
  String get formattedDurationText {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours시간 ${minutes > 0 ? '$minutes분' : ''}';
    } else if (minutes > 0) {
      return '$minutes분';
    } else {
      return '1분 미만';
    }
  }

  // 퍼센트 형식으로 변환
  String get formattedPercentage {
    return '${percentage.toStringAsFixed(1)}%';
  }
}

class DailyStatistics {
  final DateTime date;
  final int totalDuration; // 초 단위
  final Map<int, int> taskDurations; // 태스크 ID별 시간 (초 단위)

  DailyStatistics({
    required this.date,
    required this.totalDuration,
    required this.taskDurations,
  });

  // 날짜 형식으로 변환
  String get formattedDate {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  // 요일 가져오기
  String get dayOfWeek {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    // DateTime의 weekday는 1(월요일)부터 7(일요일)
    return days[date.weekday - 1];
  }

  // 시간 형식으로 변환 (HH:MM)
  String get formattedDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // 시간 형식으로 변환 (시간 분)
  String get formattedDurationText {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours시간 ${minutes > 0 ? '$minutes분' : ''}';
    } else if (minutes > 0) {
      return '$minutes분';
    } else {
      return '1분 미만';
    }
  }
}

class ReportService {
  final TaskService _taskService;

  ReportService(this._taskService);

  // 전체 태스크 통계 가져오기
  List<TaskStatistics> getTaskStatistics() {
    final tasks = _taskService.getTasks();
    final List<TaskStatistics> statistics = [];

    // 전체 시간 계산
    int totalDuration = 0;
    for (final task in tasks) {
      totalDuration += _getTaskTotalDuration(task);
    }

    // 각 태스크별 통계 계산
    for (final task in tasks) {
      final taskDuration = _getTaskTotalDuration(task);
      if (taskDuration > 0) {
        final percentage =
            totalDuration > 0 ? (taskDuration / totalDuration) * 100 : 0.0;

        statistics.add(TaskStatistics(
          taskName: task.name,
          taskId: task.id,
          totalDuration: taskDuration,
          percentage: percentage,
        ));
      }
    }

    // 시간 순으로 정렬 (내림차순)
    statistics.sort((a, b) => b.totalDuration.compareTo(a.totalDuration));

    return statistics;
  }

  // 일별 통계 가져오기 (최근 7일)
  List<DailyStatistics> getDailyStatistics() {
    final tasks = _taskService.getTasks();
    final Map<String, DailyStatistics> dailyStats = {};

    // 최근 7일 날짜 생성
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 6));

    // 빈 통계 데이터 초기화
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      dailyStats[dateKey] = DailyStatistics(
        date: date,
        totalDuration: 0,
        taskDurations: {},
      );
    }

    // 태스크별 기록 처리
    for (final task in tasks) {
      for (final record in task.records) {
        final recordDate = DateFormat('yyyy-MM-dd').format(record.startTime);
        final duration = record.durationInSeconds;

        // 최근 7일 데이터만 처리
        if (dailyStats.containsKey(recordDate)) {
          final stats = dailyStats[recordDate]!;

          // 총 시간 업데이트
          dailyStats[recordDate] = DailyStatistics(
            date: stats.date,
            totalDuration: stats.totalDuration + duration,
            taskDurations: Map.from(stats.taskDurations)
              ..update(
                task.id,
                (value) => value + duration,
                ifAbsent: () => duration,
              ),
          );
        }
      }
    }

    // 날짜순으로 정렬 (오름차순)
    final result = dailyStats.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return result;
  }

  // 태스크별 일별 시간 가져오기
  Map<int, List<int>> getTaskDailyDurations() {
    final dailyStats = getDailyStatistics();
    final Map<int, List<int>> taskDailyDurations = {};

    // 모든 태스크 ID 가져오기
    final tasks = _taskService.getTasks();
    for (final task in tasks) {
      taskDailyDurations[task.id] = List.filled(7, 0);
    }

    // 일별 데이터 채우기
    for (int i = 0; i < dailyStats.length; i++) {
      final stats = dailyStats[i];

      stats.taskDurations.forEach((taskId, duration) {
        if (taskDailyDurations.containsKey(taskId)) {
          taskDailyDurations[taskId]![i] = duration;
        }
      });
    }

    return taskDailyDurations;
  }

  // 태스크의 총 시간 계산 (초 단위)
  int _getTaskTotalDuration(Task task) {
    int total = 0;
    for (final record in task.records) {
      total += record.durationInSeconds;
    }

    // 현재 측정 중인 시간도 포함
    if (task.isRunning && task.startTime != null) {
      total += DateTime.now().difference(task.startTime!).inSeconds;
    }

    return total;
  }
}
