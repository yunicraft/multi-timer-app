import 'package:timefolio/services/task_service.dart';
import 'package:timefolio/services/report_service.dart';

class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._internal();

  factory ServiceProvider() {
    return _instance;
  }

  ServiceProvider._internal() {
    // ReportService 초기화 (TaskService 의존성 주입)
    reportService = ReportService(taskService);
  }

  // 서비스 인스턴스들
  final TaskService taskService = TaskService();
  late final ReportService reportService;

  // 모든 서비스가 초기화될 때까지 기다림
  Future<void> waitForServicesInitialization() async {
    // TaskService 초기화 완료 대기
    await taskService.waitForInitialization();

    // 나중에 다른 서비스가 추가되면 여기에 추가
  }
}
