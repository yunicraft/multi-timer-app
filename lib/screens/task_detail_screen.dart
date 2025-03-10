import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timefolio/models/task.dart';
import 'package:timefolio/services/service_provider.dart';
import 'package:timefolio/services/task_service.dart';
import 'package:timefolio/theme/app_colors.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final String taskName;
  final int taskIndex;
  final Function(String) onNameChanged;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.taskName,
    required this.taskIndex,
    required this.onNameChanged,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _nameController;
  bool _hasChanges = false;

  // 서비스 프로바이더
  final _serviceProvider = ServiceProvider();

  // 태스크 서비스
  late final TaskService _taskService;

  // 태스크 기록 목록
  List<TaskRecord> _records = [];

  // 총 기록 시간 (초 단위)
  int _totalDuration = 0;

  // 현재 측정 중인지 여부
  bool _isRunning = false;

  // 현재 측정 중인 시간의 시작 시간
  DateTime? _currentStartTime;

  // 타이머
  Timer? _timer;

  // 레코드 추가 관련 컨트롤러
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.taskName);
    _nameController.addListener(_checkChanges);

    // 태스크 서비스 초기화
    _taskService = _serviceProvider.taskService;

    // 태스크 기록 로드
    _loadTaskRecords();

    // 현재 측정 중인지 확인
    _isRunning = _taskService.isTaskRunning(widget.taskId);
    _currentStartTime = _taskService.getTaskStartTime(widget.taskId);

    // 타이머 시작 (1초마다 업데이트)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // 총 시간 업데이트
          _totalDuration = _taskService.getTaskTotalDuration(widget.taskId);
        });
      }
    });
  }

  // 태스크 기록 로드
  void _loadTaskRecords() {
    setState(() {
      _records = _taskService.getTaskRecords(widget.taskId);
      _totalDuration = _taskService.getTaskTotalDuration(widget.taskId);
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkChanges);
    _nameController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // 변경 사항이 있는지 확인
  void _checkChanges() {
    final hasChanges = _nameController.text != widget.taskName;
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  // 태스크 이름 저장
  void _saveName() {
    if (_nameController.text.isNotEmpty &&
        _nameController.text != widget.taskName) {
      widget.onNameChanged(_nameController.text);
      setState(() {
        _hasChanges = false;
      });
    }
  }

  // 뒤로 가기 처리
  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    // 변경 사항이 있으면 확인 다이얼로그 표시
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경 사항 저장'),
        content: const Text('변경 사항이 있습니다. 저장하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // 저장 안 함
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () {
              _saveName();
              Navigator.pop(context, true); // 저장 후 뒤로 가기
            },
            child: const Text('예'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // 시간 형식으로 변환 (HH:MM:SS)
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 레코드 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmDialog(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (result == true) {
      _taskService.deleteTaskRecord(widget.taskId, index);
      _loadTaskRecords();
    }
  }

  // 날짜 선택 다이얼로그
  Future<DateTime?> _selectDate(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.darkCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  // 시간 선택 다이얼로그
  Future<TimeOfDay?> _selectTime(
      BuildContext context, TimeOfDay initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.darkCard,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  // 레코드 추가 다이얼로그
  Future<void> _showAddRecordDialog() async {
    // 현재 날짜와 시간으로 초기화
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    _startDateController.text = dateFormat.format(now);
    _startTimeController.text =
        timeFormat.format(now.subtract(const Duration(hours: 1)));
    _endDateController.text = dateFormat.format(now);
    _endTimeController.text = timeFormat.format(now);

    DateTime startDate = now.subtract(const Duration(hours: 1));
    TimeOfDay startTime = TimeOfDay.fromDateTime(startDate);
    DateTime endDate = now;
    TimeOfDay endTime = TimeOfDay.fromDateTime(now);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 시작 날짜
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '시작 날짜',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final date = await _selectDate(context, startDate);
                        if (date != null) {
                          startDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            startTime.hour,
                            startTime.minute,
                          );
                          _startDateController.text = dateFormat.format(date);
                        }
                      },
                    ),
                  ),
                ],
              ),

              // 시작 시간
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '시작 시간',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () async {
                        final time = await _selectTime(context, startTime);
                        if (time != null) {
                          startTime = time;
                          startDate = DateTime(
                            startDate.year,
                            startDate.month,
                            startDate.day,
                            time.hour,
                            time.minute,
                          );
                          _startTimeController.text =
                              timeFormat.format(startDate);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 종료 날짜
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '종료 날짜',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final date = await _selectDate(context, endDate);
                        if (date != null) {
                          endDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            endTime.hour,
                            endTime.minute,
                          );
                          _endDateController.text = dateFormat.format(date);
                        }
                      },
                    ),
                  ),
                ],
              ),

              // 종료 시간
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _endTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '종료 시간',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () async {
                        final time = await _selectTime(context, endTime);
                        if (time != null) {
                          endTime = time;
                          endDate = DateTime(
                            endDate.year,
                            endDate.month,
                            endDate.day,
                            time.hour,
                            time.minute,
                          );
                          _endTimeController.text = timeFormat.format(endDate);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 시작 시간이 종료 시간보다 이후인지 확인
              if (startDate.isAfter(endDate)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('시작 시간은 종료 시간보다 이전이어야 합니다.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              Navigator.pop(context, true);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (result == true) {
      _taskService.addTaskRecord(widget.taskId, startDate, endDate);
      _loadTaskRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 날짜 포맷
    final dateFormat = DateFormat('yyyy.MM.dd');
    final formattedDate = dateFormat.format(DateTime.now());

    // 날짜 및 시간 포맷
    final recordDateFormat = DateFormat('yyyy.MM.dd');
    final recordTimeFormat = DateFormat('HH:mm:ss');

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            formattedDate,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            // 저장 버튼
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: () {
                _saveName();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('변경사항이 저장되었습니다.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 태스크 이름 편집 필드
              const Text(
                '태스크 이름',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '태스크 이름을 입력하세요',
                  hintStyle: const TextStyle(color: Colors.white38),
                ),
              ),

              const SizedBox(height: 24),

              // 태스크 기록 섹션 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '태스크 기록',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  // 총 기록 시간
                  Text(
                    '총 시간: ${_formatDuration(_totalDuration)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // 기록 추가 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: const Text(
                      '기록 추가',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    onPressed: _showAddRecordDialog,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 기록 목록
              Expanded(
                child: _records.isEmpty && !_isRunning
                    ? _buildEmptyRecordsMessage()
                    : _buildRecordsList(recordDateFormat, recordTimeFormat),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 기록이 없을 때 표시할 메시지
  Widget _buildEmptyRecordsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.gold.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 기록이 없습니다.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '태스크를 시작하면 기록이 여기에 표시됩니다.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 기록 목록 위젯
  Widget _buildRecordsList(DateFormat dateFormat, DateFormat timeFormat) {
    // 현재 측정 중인 항목을 추가
    final allRecords = List<Widget>.empty(growable: true);

    // 현재 측정 중인 항목
    if (_isRunning && _currentStartTime != null) {
      final startDate = dateFormat.format(_currentStartTime!);
      final startTime = timeFormat.format(_currentStartTime!);
      final now = DateTime.now();
      final currentDuration = now.difference(_currentStartTime!).inSeconds;

      allRecords.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜
              Text(
                startDate,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),

              // 시간 및 기간
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 시작 시간
                  Text(
                    '$startTime - 측정 중...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 현재까지의 기간
                  Text(
                    _formatDuration(currentDuration),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
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

    // 기존 기록 목록
    return ListView.builder(
      itemCount: _records.length + (_isRunning ? 1 : 0),
      itemBuilder: (context, index) {
        // 현재 측정 중인 항목
        if (_isRunning && index == 0) {
          return allRecords[0];
        }

        // 기존 기록
        final recordIndex = _isRunning ? index - 1 : index;
        final record = _records[recordIndex];
        final startDate = dateFormat.format(record.startTime);
        final startTime = timeFormat.format(record.startTime);
        final endTime = timeFormat.format(record.endTime);

        return Dismissible(
          key: ValueKey(
              'record_${recordIndex}_${record.startTime.millisecondsSinceEpoch}'),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('기록 삭제'),
                content: const Text('이 기록을 삭제하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('삭제'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            _taskService.deleteTaskRecord(widget.taskId, recordIndex);
            _loadTaskRecords();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜
                Text(
                  startDate,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),

                // 시간 및 기간
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 시작 및 종료 시간
                    Text(
                      '$startTime - $endTime',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // 기간
                    Text(
                      record.formattedDuration,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
