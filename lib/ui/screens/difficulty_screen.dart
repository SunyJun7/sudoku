import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/difficulty.dart';
import '../../providers/game_state_provider.dart';

class DifficultyScreen extends ConsumerWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('난이도 선택'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DifficultyButton(
                label: '쉬움',
                difficulty: Difficulty.easy,
              ),
              const SizedBox(height: 16),
              _DifficultyButton(
                label: '보통',
                difficulty: Difficulty.normal,
              ),
              const SizedBox(height: 16),
              _DifficultyButton(
                label: '어려움',
                difficulty: Difficulty.hard,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends ConsumerWidget {
  const _DifficultyButton({
    required this.label,
    required this.difficulty,
  });

  final String label;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          await ref
              .read(gameStateProvider.notifier)
              .startNewGame(difficulty);
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/game');
          }
        },
        child: Text(label),
      ),
    );
  }
}
