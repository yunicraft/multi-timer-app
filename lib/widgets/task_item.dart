import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timefolio/models/task.dart';
import 'package:timefolio/theme/app_colors.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final int index;
  final VoidCallback onToggleTimer;
  final VoidCallback onShowDetails;

  const TaskItem({
    super.key,
    required this.task,
    required this.index,
    required this.onToggleTimer,
    required this.onShowDetails,
  });

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
              '${task.id}',
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
              onTap: onToggleTimer,
              onLongPress: () {
                // 롱프레스 시 드래그 시작을 위한 피드백
                HapticFeedback.mediumImpact();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: task.isRunning
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(8),
                  border: task.isRunning
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.name.isEmpty ? '태스크 이름을 입력하세요' : task.name,
                        style: TextStyle(
                          color:
                              task.name.isEmpty ? Colors.white38 : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (task.isRunning)
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

          // 편집 버튼
          IconButton(
            icon: const Text(
              'E',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: onShowDetails,
          ),
        ],
      ),
    );
  }
}
