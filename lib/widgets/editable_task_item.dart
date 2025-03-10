import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timefolio/models/task.dart';
import 'package:timefolio/theme/app_colors.dart';

class EditableTaskItem extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onToggleTimer;
  final VoidCallback onShowDetails;
  final Function(String) onNameChanged;
  final bool isEditing;

  const EditableTaskItem({
    super.key,
    required this.task,
    required this.index,
    required this.onToggleTimer,
    required this.onShowDetails,
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
      _controller.text = '새 태스크 ${widget.task.id}';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // 태스크 번호
          SizedBox(
            width: 30,
            child: Text(
              '${widget.task.id}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 태스크 내용 (클릭 가능한 영역)
          Expanded(
            child: InkWell(
              onTap: _isEditing ? null : widget.onToggleTimer,
              onLongPress: _isEditing
                  ? null
                  : () {
                      // 롱프레스 시 드래그 시작을 위한 피드백
                      HapticFeedback.mediumImpact();
                    },
              onDoubleTap: _isEditing ? null : _startEditing,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.task.isRunning
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(8),
                  border: widget.task.isRunning
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _isEditing
                          ? TextField(
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
                            )
                          : Text(
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
                    if (widget.task.isRunning && !_isEditing)
                      const Icon(
                        Icons.timer,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 편집/완료 버튼
          IconButton(
            icon: _isEditing
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  )
                : const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
            onPressed: _onCompleteTap,
          ),
        ],
      ),
    );
  }
}
