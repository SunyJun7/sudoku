import 'package:flutter/material.dart';

/// 1시간 경과 후 표시되는 휴식 권고 팝업
class RestWarningDialog extends StatelessWidget {
  const RestWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '잠깐 쉬어가세요',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        '1시간 동안 게임을 하셨어요.\n잠시 쉬시고 다시 즐겨주세요.',
        style: TextStyle(fontSize: 18),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '계속하기',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}
