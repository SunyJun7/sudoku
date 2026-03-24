import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/difficulty.dart';
import '../../providers/game_state_provider.dart';
import '../widgets/game_control_bar.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_grid.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 앱이 백그라운드로 진입할 때 상태를 저장한다
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      ref.read(gameStateProvider.notifier).saveState();
    }
  }

  String _difficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '쉬움';
      case Difficulty.normal:
        return '보통';
      case Difficulty.hard:
        return '어려움';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    // 완료 시 클리어 화면으로 이동 (빌드 후 처리)
    ref.listen(gameStateProvider, (previous, next) {
      if (next != null &&
          next.isComplete &&
          (previous == null || !previous.isComplete)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushNamed('/clear');
          }
        });
      }
    });

    final difficultyLabel = gameState != null
        ? _difficultyLabel(gameState.difficulty)
        : '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await ref.read(gameStateProvider.notifier).saveState();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Text('스도쿠 - $difficultyLabel'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await ref.read(gameStateProvider.notifier).saveState();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (r) => false);
              }
            },
          ),
        ),
        body: gameState == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    const SudokuGrid(),
                    const Spacer(),
                    const NumberPad(),
                    const GameControlBar(),
                  ],
                ),
              ),
      ),
    );
  }
}
