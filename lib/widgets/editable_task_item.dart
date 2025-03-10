import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:timefolio/models/task.dart';
import 'package:timefolio/theme/app_colors.dart';
import 'dart:async';

// 실행 중인 타이머를 표시하는 별도 위젯
class RunningTimerWidget extends StatefulWidget {
  final Task task;

  const RunningTimerWidget({
    super.key,
    required this.task,
  });

  @override
  State<RunningTimerWidget> createState() => _RunningTimerWidgetState();
}

class _RunningTimerWidgetState extends State<RunningTimerWidget> {
  Timer? _timer;
  int _currentDuration = 0;

  @override
  void initState() {
    super.initState();
    if (widget.task.isRunning && widget.task.startTime != null) {
      _currentDuration =
          DateTime.now().difference(widget.task.startTime!).inSeconds;
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(RunningTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 태스크 상태가 변경되었을 때 타이머 관리
    if (widget.task.isRunning != oldWidget.task.isRunning) {
      if (widget.task.isRunning && widget.task.startTime != null) {
        _currentDuration =
            DateTime.now().difference(widget.task.startTime!).inSeconds;
        _startTimer();
      } else {
        _timer?.cancel();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && widget.task.isRunning && widget.task.startTime != null) {
        setState(() {
          _currentDuration =
              DateTime.now().difference(widget.task.startTime!).inSeconds;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 시간 형식으로 변환 (HH:MM:SS)
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = widget.task.totalDurationInSeconds + _currentDuration;
    final startTimeStr = DateFormat('HH:mm:ss').format(widget.task.startTime!);
    final currentTimeStr = DateFormat('HH:mm:ss').format(DateTime.now());

    return Text(
      '총 ${_formatDuration(totalDuration)} ($startTimeStr - $currentTimeStr)',
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class EditableTaskItem extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onToggleTimer;
  final VoidCallback onShowDetails;
  final VoidCallback onDelete;
  final Function(String) onNameChanged;
  final bool isEditing;

  const EditableTaskItem({
    super.key,
    required this.task,
    required this.index,
    required this.onToggleTimer,
    required this.onShowDetails,
    required this.onDelete,
    required this.onNameChanged,
    this.isEditing = false,
  });

  @override
  State<EditableTaskItem> createState() => _EditableTaskItemState();
}

class _EditableTaskItemState extends State<EditableTaskItem> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.name);
    _focusNode = FocusNode();
    _isEditing = widget.isEditing;

    // 포커스 변경 리스너 추가
    _focusNode.addListener(_onFocusChange);

    // 편집 모드로 시작하는 경우 포커스 요청
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  // 포커스 변경 시 호출되는 함수
  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      // 포커스를 잃었을 때 편집 모드 종료 및 이름 저장
      setState(() {
        _isEditing = false;
      });
      _saveName();
    }
  }

  // 이름 저장 함수
  void _saveName() {
    // 텍스트가 비어있으면 자동으로 '새 태스크'로 설정
    if (_controller.text.trim().isEmpty) {
      _controller.text = '새 태스크 ${widget.index + 1}';
    }

    // 이름이 변경되었을 때만 저장
    if (_controller.text != widget.task.name) {
      widget.onNameChanged(_controller.text);
    }
  }

  // 편집 모드 시작 함수
  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    _focusNode.requestFocus();
  }

  // 완료 버튼 클릭 함수
  void _onCompleteTap() {
    if (_isEditing) {
      // 편집 모드일 때는 저장 후 편집 모드 종료
      setState(() {
        _isEditing = false;
      });
      _saveName();
    } else {
      // 일반 모드일 때는 상세 정보 보기
      widget.onShowDetails();
    }
  }

  // 시간 형식으로 변환 (HH:MM:SS)
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 캡션 위젯 생성
  Widget _buildCaption() {
    // 기록이 없는 경우
    if (widget.task.records.isEmpty && !widget.task.isRunning) {
      return const Text(
        '태스크를 탭하여 시간을 측정하세요',
        style: TextStyle(
          color: Colors.white60,
          fontSize: 12,
        ),
      );
    }

    // 현재 측정 중인 경우
    if (widget.task.isRunning && widget.task.startTime != null) {
      return RunningTimerWidget(task: widget.task);
    }

    // 기록이 있는 경우
    return Text(
      '총 ${widget.task.formattedTotalDuration}',
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 편집 모드일 때는 Slidable을 사용하지 않고 확인 버튼 표시
    if (_isEditing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // 태스크 번호 (ID 대신 순번 표시)
            SizedBox(
              width: 30,
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 태스크 내용 (편집 모드)
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '태스크 이름을 입력하세요',
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            _isEditing = false;
                          });
                          _saveName();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 확인 버튼
            IconButton(
              icon: const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
              onPressed: _onCompleteTap,
            ),
          ],
        ),
      );
    }

    // 일반 모드일 때는 Slidable 사용
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // 태스크 번호 (ID 대신 순번 표시)
          SizedBox(
            width: 30,
            child: Text(
              '${widget.index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 태스크 내용 (스와이프 가능한 영역)
          Expanded(
            child: Slidable(
              key: ValueKey('task_${widget.task.id}'),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  // 삭제 버튼
                  SlidableAction(
                    onPressed: (context) async {
                      final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('태스크 삭제'),
                              content: const Text('이 태스크를 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (shouldDelete) {
                        widget.onDelete();
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    label: '삭제',
                  ),
                  // 상세 정보 버튼
                  SlidableAction(
                    onPressed: (_) => widget.onShowDetails(),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    label: '상세',
                  ),
                ],
              ),
              child: InkWell(
                onTap: widget.onToggleTimer,
                onLongPress: () {
                  // 롱프레스 시 드래그 시작을 위한 피드백
                  HapticFeedback.mediumImpact();
                },
                onDoubleTap: _startEditing, // 더블 탭으로 편집 모드 시작
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.task.isRunning
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.darkCard,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(8),
                          topRight: const Radius.circular(8),
                          bottomLeft: Radius.circular(
                              widget.task.records.isEmpty &&
                                      !widget.task.isRunning &&
                                      widget.task.name.isEmpty
                                  ? 8
                                  : 0),
                          bottomRight: Radius.circular(
                              widget.task.records.isEmpty &&
                                      !widget.task.isRunning &&
                                      widget.task.name.isEmpty
                                  ? 8
                                  : 0),
                        ),
                        border: widget.task.isRunning
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.task.name.isEmpty
                                  ? '태스크 이름을 입력하세요'
                                  : widget.task.name,
                              style: TextStyle(
                                color: widget.task.name.isEmpty
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (widget.task.isRunning)
                            const Icon(
                              Icons.timer,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                    // 캡션 추가
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.task.isRunning
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.darkCard.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        border: widget.task.isRunning
                            ? Border(
                                left: const BorderSide(
                                    color: AppColors.primary, width: 2),
                                right: const BorderSide(
                                    color: AppColors.primary, width: 2),
                                bottom: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              )
                            : null,
                      ),
                      child: _buildCaption(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
