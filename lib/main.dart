import 'package:timefolio/router.dart';
import 'package:timefolio/services/service_provider.dart';
import 'package:timefolio/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  await dotenv.load(fileName: '.env');

  // 화면 세로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 서비스 프로바이더 초기화 (싱글톤 패턴으로 자동 초기화)
  ServiceProvider();

  final packageInfo = await PackageInfo.fromPlatform();

  runApp(MyApp(packageInfo: packageInfo)
      // // 다음처럼 의존성 주입할 것.
      // MultiProvider(
      //   providers: [
      //     // Provider<Repository>(create: (_) => repository),
      //     // Provider<Service>(create: (_) => service),
      //   ],
      //   child: const MyApp(),
      // ),
      );
}

class MyApp extends StatelessWidget {
  final PackageInfo packageInfo;

  const MyApp({
    super.key,
    required this.packageInfo,
  });

  @override
  Widget build(BuildContext context) {
    // packageInfo 예시:
    // packageInfo.appName -> "Base App"
    // packageInfo.packageName -> "com.moment.timefolio"
    // packageInfo.version -> "1.0.0"
    // packageInfo.buildNumber -> "1"
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Timefolio',
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return child;
      },
    );
  }
}
