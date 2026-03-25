import 'package:flutter/material.dart';

/// 자동 종료 경고 팝업 (기능 3: 110분 경과 / 기능 5: 새벽 1:50 경고)
///
/// 사용 예시:
/// - 기능 3: ShutdownWarningDialog(message: '10분 후 게임이 자동으로 종료됩니다.')
/// - 기능 5: ShutdownWarningDialog(message: '새벽 2시가 되면 게임이 종료됩니다.')
class ShutdownWarningDialog extends StatelessWidget {
  final String message;

  const ShutdownWarningDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '곧 종료됩니다',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '확인',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }
}
