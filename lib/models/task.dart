class Task {
  final int id;
  String name;
  bool isRunning;
  DateTime? startTime;
  DateTime? endTime;
  final List<TaskRecord> records; // 태스크 기록 목록

  Task({
    required this.id,
    required this.name,
    this.isRunning = false,
    this.startTime,
    this.endTime,
    List<TaskRecord>? records,
  }) : records = records ?? [];

  // 총 기록 시간 계산 (초 단위)
  int get totalDurationInSeconds {
    int total = 0;
    for (final record in records) {
      total += record.durationInSeconds;
    }
    return total;
  }

  // 시간 형식으로 변환 (HH:MM:SS)
  String get formattedTotalDuration {
    final totalSeconds = totalDurationInSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isRunning': isRunning,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  // JSON에서 생성
  factory Task.fromJson(Map<String, dynamic> json) {
    final recordsList = (json['records'] as List?)
            ?.map((recordJson) => TaskRecord.fromJson(recordJson))
            .toList() ??
        [];

    return Task(
      id: json['id'],
      name: json['name'],
      isRunning: json['isRunning'] ?? false,
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      records: recordsList,
    );
  }
}

// 태스크 기록 클래스
class TaskRecord {
  final DateTime startTime;
  final DateTime endTime;

  TaskRecord({
    required this.startTime,
    required this.endTime,
  });

  // 기록 시간 (초 단위)
  int get durationInSeconds {
    return endTime.difference(startTime).inSeconds;
  }

  // 시간 형식으로 변환 (HH:MM:SS)
  String get formattedDuration {
    final seconds = durationInSeconds;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  // JSON에서 생성
  factory TaskRecord.fromJson(Map<String, dynamic> json) {
    return TaskRecord(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }
}
