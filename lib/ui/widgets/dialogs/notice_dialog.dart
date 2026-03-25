import 'package:flutter/material.dart';

/// 게임 시작 시 표시되는 공지사항 팝업
class NoticeDialog extends StatelessWidget {
  const NoticeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '공지사항',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        '· 2시간 이상 연속 플레이 시 게임이 종료됩니다.\n'
        '· 새벽 2시부터 8시까지는 플레이할 수 없습니다.',
        style: TextStyle(fontSize: 18),
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
