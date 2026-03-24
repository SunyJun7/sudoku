import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';
import 'package:sudoku/providers/game_state_provider.dart';
import 'package:sudoku/ui/widgets/number_pad.dart';

// ─── 테스트용 헬퍼 ─────────────────────────────────────────────────────────────

PuzzleData _emptyPuzzle() => PuzzleData(
      id: 'test-puzzle',
      givens: List.filled(81, 0),
      solution: List.filled(81, 1),
    );

GameState _makeState({bool isComplete = false}) => GameState(
      puzzle: _emptyPuzzle(),
      board: List.filled(
        81,
        const CellState(value: 0, isGiven: false, isError: false),
      ),
      selectedIndex: 0,
      difficulty: Difficulty.easy,
      isComplete: isComplete,
    );

// ─── Mock Notifier ─────────────────────────────────────────────────────────────

class _MockGameStateNotifier extends GameStateNotifier {
  final List<int> placedNumbers = [];
  int eraseCount = 0;

  @override
  GameState? build() => _makeState();

  @override
  void placeNumber(int value) {
    placedNumbers.add(value);
  }

  @override
  void eraseNumber() {
    eraseCount++;
  }
}

class _CompletedGameStateNotifier extends GameStateNotifier {
  final List<int> placedNumbers = [];
  int eraseCount = 0;

  @override
  GameState? build() => _makeState(isComplete: true);

  @override
  void placeNumber(int value) {
    placedNumbers.add(value);
  }

  @override
  void eraseNumber() {
    eraseCount++;
  }
}

// ─── 테스트 ────────────────────────────────────────────────────────────────────

void main() {
  group('NumberPad', () {
    testWidgets('숫자 버튼 1~9가 모두 렌더링된다', (tester) async {
      final mock = _MockGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(home: Scaffold(body: NumberPad())),
        ),
      );

      for (int i = 1; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('숫자 버튼 탭 시 placeNumber가 해당 숫자로 호출된다', (tester) async {
      final mock = _MockGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(home: Scaffold(body: NumberPad())),
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(mock.placedNumbers, contains(5));
    });

    testWidgets('1부터 9까지 각 버튼 탭 시 placeNumber에 올바른 숫자가 전달된다', (tester) async {
      final mock = _MockGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(home: Scaffold(body: NumberPad())),
        ),
      );

      for (int i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();
      }

      expect(mock.placedNumbers, equals([1, 2, 3, 4, 5, 6, 7, 8, 9]));
    });

    testWidgets('지우기 버튼 탭 시 eraseNumber가 호출된다', (tester) async {
      final mock = _MockGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(home: Scaffold(body: NumberPad())),
        ),
      );

      await tester.tap(find.text('⌫'));
      await tester.pump();

      expect(mock.eraseCount, equals(1));
    });

    testWidgets('isComplete=true이면 숫자 버튼 탭이 placeNumber를 호출하지 않는다',
        (tester) async {
      final mock = _CompletedGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(home: Scaffold(body: NumberPad())),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(mock.placedNumbers, isEmpty);
    });

    testWidgets('isComplete=true이면 지우기 버튼 탭이 eraseNumber를 호출하지 않는다',
        (tester) async {
      final mock = _CompletedGameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(home: Scaffold(body: NumberPad())),
        ),
      );

      await tester.tap(find.text('⌫'));
      await tester.pump();

      expect(mock.eraseCount, equals(0));
    });
  });
}
