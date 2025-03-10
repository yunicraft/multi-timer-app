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
}
