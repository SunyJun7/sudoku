import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_state_provider.dart';
import '../theme/app_theme.dart';

class GameControlBar extends ConsumerWidget {
  const GameControlBar({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('다시 시작'),
        content: const Text('입력한 숫자가 모두 지워집니다. 계속할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(gameStateProvider.notifier).resetGame();
    }
  }

  Future<void> _goToNewGame(BuildContext context, WidgetRef ref) async {
    await ref.read(gameStateProvider.notifier).clearSavedState();
    if (context.mounted) {
      Navigator.of(context).pushNamed('/difficulty');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _confirmReset(context, ref),
            child: const Text(
              '다시 시작',
              style: TextStyle(fontSize: AppTextStyles.button),
            ),
          ),
          ElevatedButton(
            onPressed: () => _goToNewGame(context, ref),
            child: const Text(
              '새 게임',
              style: TextStyle(fontSize: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}
