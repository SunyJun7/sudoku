import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';
import 'package:sudoku/providers/game_state_provider.dart';
import 'package:sudoku/ui/screens/difficulty_screen.dart';

// ─── 헬퍼 ──────────────────────────────────────────────────────────────────────

PuzzleData _emptyPuzzle() => PuzzleData(
      id: 'test',
      givens: List.filled(81, 0),
      solution: List.filled(81, 1),
    );

GameState _makeGameState(Difficulty difficulty) => GameState(
      puzzle: _emptyPuzzle(),
      board: List.filled(
        81,
        const CellState(value: 0, isGiven: false, isError: false),
      ),
      selectedIndex: null,
      difficulty: difficulty,
      isComplete: false,
    );

// ─── Mock Notifier ─────────────────────────────────────────────────────────────

class _MockGameStateNotifier extends GameStateNotifier {
  final List<Difficulty> startedDifficulties = [];

  @override
  GameState? build() => null;

  @override
  Future<void> startNewGame(Difficulty difficulty) async {
    startedDifficulties.add(difficulty);
    state = _makeGameState(difficulty);
  }
}

// ─── 테스트 ────────────────────────────────────────────────────────────────────

void main() {
  group('DifficultyScreen', () {
    testWidgets('쉬움/보통/어려움 버튼 3개가 렌더링된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: DifficultyScreen(),
          ),
        ),
      );

      expect(find.text('쉬움'), findsOneWidget);
      expect(find.text('보통'), findsOneWidget);
      expect(find.text('어려움'), findsOneWidget);
    });

    testWidgets('[쉬움] 탭 시 startNewGame(Difficulty.easy)가 호출된다',
        (tester) async {
      final mockNotifier = _MockGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mockNotifier)],
          child: MaterialApp(
            routes: {
              '/': (context) => const DifficultyScreen(),
              '/game': (context) => const Scaffold(body: Text('게임 화면')),
            },
            initialRoute: '/',
          ),
        ),
      );

      await tester.tap(find.text('쉬움'));
      await tester.pumpAndSettle();

      expect(mockNotifier.startedDifficulties, contains(Difficulty.easy));
    });

    testWidgets('[보통] 탭 시 startNewGame(Difficulty.normal)이 호출된다',
        (tester) async {
      final mockNotifier = _MockGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mockNotifier)],
          child: MaterialApp(
            routes: {
              '/': (context) => const DifficultyScreen(),
              '/game': (context) => const Scaffold(body: Text('게임 화면')),
            },
            initialRoute: '/',
          ),
        ),
      );

      await tester.tap(find.text('보통'));
      await tester.pumpAndSettle();

      expect(mockNotifier.startedDifficulties, contains(Difficulty.normal));
    });

    testWidgets('[어려움] 탭 시 startNewGame(Difficulty.hard)가 호출된다',
        (tester) async {
      final mockNotifier = _MockGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mockNotifier)],
          child: MaterialApp(
            routes: {
              '/': (context) => const DifficultyScreen(),
              '/game': (context) => const Scaffold(body: Text('게임 화면')),
            },
            initialRoute: '/',
          ),
        ),
      );

      await tester.tap(find.text('어려움'));
      await tester.pumpAndSettle();

      expect(mockNotifier.startedDifficulties, contains(Difficulty.hard));
    });
  });
}
