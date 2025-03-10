class Task {
  final int id;
  String name;
  bool isRunning;
  DateTime? startTime;
  DateTime? endTime;

  Task({
    required this.id,
    required this.name,
    this.isRunning = false,
    this.startTime,
    this.endTime,
  });

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isRunning': isRunning,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  // JSON에서 생성
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      isRunning: json['isRunning'] ?? false,
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}
