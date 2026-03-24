import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';
import 'package:sudoku/providers/game_state_provider.dart';
import 'package:sudoku/ui/screens/clear_screen.dart';

// ─── 헬퍼 ──────────────────────────────────────────────────────────────────────

PuzzleData _emptyPuzzle() => PuzzleData(
      id: 'test',
      givens: List.filled(81, 0),
      solution: List.filled(81, 1),
    );

GameState _completedGameState() => GameState(
      puzzle: _emptyPuzzle(),
      board: List.filled(
        81,
        const CellState(value: 0, isGiven: false, isError: false),
      ),
      selectedIndex: null,
      difficulty: Difficulty.easy,
      isComplete: true,
    );

// ─── Mock Notifiers ────────────────────────────────────────────────────────────

class _MockGameStateNotifier extends GameStateNotifier {
  bool resetCalled = false;
  bool clearCalled = false;

  @override
  GameState? build() => _completedGameState();

  @override
  void resetGame() {
    resetCalled = true;
    // 완료 상태를 해제한 새 상태로 전환
    state = GameState(
      puzzle: _emptyPuzzle(),
      board: List.filled(
        81,
        const CellState(value: 0, isGiven: false, isError: false),
      ),
      selectedIndex: null,
      difficulty: Difficulty.easy,
      isComplete: false,
    );
  }

  @override
  Future<void> clearSavedState() async {
    clearCalled = true;
  }
}

// ─── 테스트 ────────────────────────────────────────────────────────────────────

void main() {
  group('ClearScreen', () {
    testWidgets('완료! 텍스트가 렌더링된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: ClearScreen(),
          ),
        ),
      );

      expect(find.text('완료!'), findsOneWidget);
    });

    testWidgets('격려 메시지가 렌더링된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: ClearScreen(),
          ),
        ),
      );

      expect(find.text('스도쿠를 완성했습니다!'), findsOneWidget);
    });

    testWidgets('[다시 하기] 탭 시 resetGame()이 호출된다', (tester) async {
      final mockNotifier = _MockGameStateNotifier();

      // Navigator 키로 직접 ClearScreen을 두 번째 화면으로 push
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mockNotifier)],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('게임 화면')),
          ),
        ),
      );

      // ClearScreen을 스택 위에 push (Navigator.pop 대상이 생기도록)
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (context) => const ClearScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('다시 하기'), findsOneWidget);

      await tester.tap(find.text('다시 하기'));
      await tester.pumpAndSettle();

      expect(mockNotifier.resetCalled, isTrue);
    });

    testWidgets('[홈으로] 탭 시 clearSavedState()가 호출된다', (tester) async {
      final mockNotifier = _MockGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mockNotifier)],
          child: MaterialApp(
            routes: {
              '/': (context) => const Scaffold(body: Text('홈 화면')),
              '/clear': (context) => const ClearScreen(),
            },
            initialRoute: '/clear',
          ),
        ),
      );

      await tester.tap(find.text('홈으로'));
      await tester.pumpAndSettle();

      expect(mockNotifier.clearCalled, isTrue);
    });
  });
}
