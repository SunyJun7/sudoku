import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';
import 'package:sudoku/providers/game_state_provider.dart';
import 'package:sudoku/ui/screens/game_screen.dart';
import 'package:sudoku/ui/widgets/game_control_bar.dart';
import 'package:sudoku/ui/widgets/number_pad.dart';
import 'package:sudoku/ui/widgets/sudoku_grid.dart';

// ─── 헬퍼 ──────────────────────────────────────────────────────────────────────

PuzzleData _emptyPuzzle() => PuzzleData(
      id: 'test',
      givens: List.filled(81, 0),
      solution: List.filled(81, 1),
    );

GameState _defaultGameState({bool isComplete = false}) => GameState(
      puzzle: _emptyPuzzle(),
      board: List.filled(
        81,
        const CellState(value: 0, isGiven: false, isError: false),
      ),
      selectedIndex: null,
      difficulty: Difficulty.easy,
      isComplete: isComplete,
    );

// ─── Mock Notifiers ────────────────────────────────────────────────────────────

class _NullGameStateNotifier extends GameStateNotifier {
  @override
  GameState? build() => null;
}

class _DefaultGameStateNotifier extends GameStateNotifier {
  @override
  GameState? build() => _defaultGameState();
}

/// isComplete=false로 시작 후 외부에서 완료 상태로 전환하기 위한 Notifier
class _CompletableGameStateNotifier extends GameStateNotifier {
  @override
  GameState? build() => _defaultGameState(isComplete: false);

  void markComplete() {
    state = _defaultGameState(isComplete: true);
  }
}

// ─── 테스트 ────────────────────────────────────────────────────────────────────

void main() {
  group('GameScreen', () {
    testWidgets('gameState가 null이면 CircularProgressIndicator를 표시한다',
        (tester) async {
      final nullNotifier = _NullGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => nullNotifier)],
          child: const MaterialApp(
            home: GameScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('gameState가 있으면 SudokuGrid, NumberPad, GameControlBar를 표시한다',
        (tester) async {
      final notifier = _DefaultGameStateNotifier();

      // 그리드 + 패드가 충분히 렌더링될 화면 크기 설정
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => notifier)],
          child: const MaterialApp(
            home: GameScreen(),
          ),
        ),
      );

      expect(find.byType(SudokuGrid), findsOneWidget);
      expect(find.byType(NumberPad), findsOneWidget);
      expect(find.byType(GameControlBar), findsOneWidget);

      // 테스트 후 기본 크기 복원
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('isComplete=true 전환 시 /clear 라우트로 이동한다', (tester) async {
      final notifier = _CompletableGameStateNotifier();

      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => notifier)],
          child: MaterialApp(
            routes: {
              '/': (context) => const GameScreen(),
              '/clear': (context) =>
                  const Scaffold(body: Text('클리어 화면')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // 완료 상태로 전환
      notifier.markComplete();
      // ref.listen → addPostFrameCallback → push 순서로 처리되므로
      // pumpAndSettle로 모든 프레임과 애니메이션 완료 대기
      await tester.pumpAndSettle();

      expect(find.text('클리어 화면'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
