import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_state_provider.dart';
import '../../providers/game_storage_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSavedGame = ref.watch(hasSavedGameProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '스도쿠',
                style: TextStyle(
                  fontSize: AppTextStyles.title,
                  fontWeight: FontWeight.bold,
                  color: AppColors.givenNumber,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/difficulty');
                  },
                  child: const Text('시작'),
                ),
              ),
              // hasSavedGameProvider는 FutureProvider → AsyncValue.when()으로 처리
              hasSavedGame.when(
                data: (hasSaved) {
                  if (!hasSaved) return const SizedBox.shrink();
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(gameStateProvider.notifier)
                                .restoreGame();
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/game');
                            }
                          },
                          child: const Text('이어하기'),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
