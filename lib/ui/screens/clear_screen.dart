import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_state_provider.dart';
import '../theme/app_theme.dart';

class ClearScreen extends ConsumerWidget {
  const ClearScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      // 시스템 뒤로가기 버튼으로 이 화면을 빠져나가지 못하게 차단
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '완료!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.givenNumber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '스도쿠를 완성했습니다!',
                    style: TextStyle(
                      fontSize: AppTextStyles.button,
                      color: AppColors.givenNumber,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // 같은 퍼즐을 초기화(givens 유지)하고 게임 화면으로 복귀
                        ref.read(gameStateProvider.notifier).resetGame();
                        Navigator.of(context).pop();
                      },
                      child: const Text('다시 하기'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(gameStateProvider.notifier)
                            .clearSavedState();
                        if (context.mounted) {
                          // 스택 전부 제거 후 홈으로 이동, 그 다음 난이도 선택 push
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                          Navigator.of(context).pushNamed('/difficulty');
                        }
                      },
                      child: const Text('새 게임'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(gameStateProvider.notifier)
                            .clearSavedState();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                        }
                      },
                      child: const Text('홈으로'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
