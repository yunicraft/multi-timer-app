import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timefolio/services/service_provider.dart';
import 'package:timefolio/services/report_service.dart';
import 'package:timefolio/theme/app_colors.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  // 서비스 프로바이더
  final _serviceProvider = ServiceProvider();

  // 리포트 서비스
  late final ReportService _reportService;

  // 탭 컨트롤러
  late TabController _tabController;

  // 태스크 통계
  late List<TaskStatistics> _taskStatistics;

  // 일별 통계
  late List<DailyStatistics> _dailyStatistics;

  // 태스크별 일별 시간
  late Map<int, List<int>> _taskDailyDurations;

  // 총 측정 시간
  int _totalDuration = 0;

  // 로딩 상태
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reportService = _serviceProvider.reportService;
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 데이터 로드
  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    // 태스크 통계 로드
    _taskStatistics = _reportService.getTaskStatistics();

    // 일별 통계 로드
    _dailyStatistics = _reportService.getDailyStatistics();

    // 태스크별 일별 시간 로드
    _taskDailyDurations = _reportService.getTaskDailyDurations();

    // 총 측정 시간 계산
    _totalDuration = 0;
    for (final stat in _taskStatistics) {
      _totalDuration += stat.totalDuration;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '통계',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '태스크별 통계'),
            Tab(text: '일별 통계'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTaskStatisticsTab(),
                _buildDailyStatisticsTab(),
              ],
            ),
    );
  }

  // 태스크별 통계 탭
  Widget _buildTaskStatisticsTab() {
    if (_taskStatistics.isEmpty) {
      return _buildEmptyState('아직 측정된 태스크가 없습니다.');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그라인
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '당신의 시간 자산, 제대로 투자하세요.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // 총 측정 시간
          _buildTotalTimeCard(),

          const SizedBox(height: 24),

          // 파이 차트
          if (_taskStatistics.isNotEmpty) _buildPieChart(),

          const SizedBox(height: 24),

          // 태스크별 시간 목록
          const Text(
            '태스크별 시간 사용',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 태스크 목록
          ...List.generate(_taskStatistics.length, (index) {
            final stat = _taskStatistics[index];
            return _buildTaskStatItem(stat, index);
          }),
        ],
      ),
    );
  }

  // 일별 통계 탭
  Widget _buildDailyStatisticsTab() {
    // 데이터가 없는 경우
    bool hasData = false;
    for (final stat in _dailyStatistics) {
      if (stat.totalDuration > 0) {
        hasData = true;
        break;
      }
    }

    if (!hasData) {
      return _buildEmptyState('아직 측정된 데이터가 없습니다.');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그라인
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '당신의 시간 자산, 제대로 투자하세요.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // 바 차트
          _buildBarChart(),

          const SizedBox(height: 24),

          // 일별 시간 목록
          const Text(
            '일별 시간 사용',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 일별 목록
          ...List.generate(_dailyStatistics.length, (index) {
            final stat = _dailyStatistics[index];
            return _buildDailyStatItem(stat);
          }),
        ],
      ),
    );
  }

  // 총 측정 시간 카드
  Widget _buildTotalTimeCard() {
    final hours = _totalDuration ~/ 3600;
    final minutes = (_totalDuration % 3600) ~/ 60;

    String timeText;
    if (hours > 0) {
      timeText = '$hours시간 ${minutes > 0 ? '$minutes분' : ''}';
    } else if (minutes > 0) {
      timeText = '$minutes분';
    } else {
      timeText = '1분 미만';
    }

    return Card(
      color: AppColors.darkCard,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '총 측정 시간',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  color: AppColors.gold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  timeText,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 파이 차트
  Widget _buildPieChart() {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _getPieChartSections(),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // 터치 이벤트 처리 (필요시)
                },
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.gold,
                  size: 24,
                ),
                const SizedBox(height: 4),
                const Text(
                  '시간 분배',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 파이 차트 섹션 데이터
  List<PieChartSectionData> _getPieChartSections() {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    return List.generate(
      _taskStatistics.length > 10 ? 10 : _taskStatistics.length,
      (index) {
        final stat = _taskStatistics[index];
        final color = colors[index % colors.length];

        return PieChartSectionData(
          color: color,
          value: stat.percentage,
          title: '${stat.percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }

  // 바 차트
  Widget _buildBarChart() {
    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxDailyDuration(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black54,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final stat = _dailyStatistics[groupIndex];
                return BarTooltipItem(
                  stat.formattedDurationText,
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < _dailyStatistics.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _dailyStatistics[index].dayOfWeek,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            _dailyStatistics.length,
            (index) {
              final stat = _dailyStatistics[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: stat.totalDuration / 60, // 분 단위로 변환
                    color: AppColors.gold,
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // 최대 일별 시간 계산 (분 단위)
  double _getMaxDailyDuration() {
    double maxDuration = 0;
    for (final stat in _dailyStatistics) {
      final durationInMinutes = stat.totalDuration / 60;
      if (durationInMinutes > maxDuration) {
        maxDuration = durationInMinutes;
      }
    }

    // 최소 60분(1시간)으로 설정, 없으면 10분
    if (maxDuration < 10) {
      return 10;
    } else if (maxDuration < 60) {
      return 60;
    }

    // 올림하여 깔끔한 숫자로 만들기
    return (maxDuration / 60).ceil() * 60;
  }

  // 태스크 통계 아이템
  Widget _buildTaskStatItem(TaskStatistics stat, int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    final color = colors[index % colors.length];

    return Card(
      color: AppColors.darkCard,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 색상 표시
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // 태스크 이름
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.taskName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.formattedDurationText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // 퍼센트
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                stat.formattedPercentage,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 일별 통계 아이템
  Widget _buildDailyStatItem(DailyStatistics stat) {
    // 시간이 없는 경우 회색으로 표시
    final hasTime = stat.totalDuration > 0;

    return Card(
      color: AppColors.darkCard,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 날짜 및 요일
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.formattedDate,
                  style: TextStyle(
                    color: hasTime ? Colors.white : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: hasTime
                        ? AppColors.gold.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stat.dayOfWeek,
                    style: TextStyle(
                      color: hasTime ? AppColors.gold : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // 시간
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: hasTime ? Colors.white70 : Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  hasTime ? stat.formattedDurationText : '기록 없음',
                  style: TextStyle(
                    color: hasTime ? Colors.white : Colors.white38,
                    fontSize: 16,
                    fontWeight: hasTime ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment,
            size: 80,
            color: AppColors.gold,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '태스크를 측정하면 여기에 통계가 표시됩니다.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
