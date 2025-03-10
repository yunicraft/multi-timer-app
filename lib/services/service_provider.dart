import 'package:timefolio/services/task_service.dart';

class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._internal();

  factory ServiceProvider() {
    return _instance;
  }

  ServiceProvider._internal();

  // 서비스 인스턴스들
  final TaskService taskService = TaskService();
}
