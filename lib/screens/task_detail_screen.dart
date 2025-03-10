import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.taskName);
    _nameController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkChanges);
    _nameController.dispose();
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

  @override
  Widget build(BuildContext context) {
    // 현재 날짜 포맷
    final dateFormat = DateFormat('yyyy.MM.dd');
    final formattedDate = dateFormat.format(DateTime.now());

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
              } else {
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

              // 태스크 기록 섹션
              const Text(
                '태스크 기록',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // 기록이 없을 때 메시지
              Expanded(
                child: Center(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
