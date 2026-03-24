import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';
import 'package:sudoku/providers/game_state_provider.dart';
import 'package:sudoku/ui/widgets/sudoku_grid.dart';

// ─── 헬퍼 ──────────────────────────────────────────────────────────────────────

PuzzleData _emptyPuzzle() => PuzzleData(
      id: 'test-puzzle',
      givens: List.filled(81, 0),
      solution: List.filled(81, 1),
    );

GameState _defaultState() => GameState(
      puzzle: _emptyPuzzle(),
      board: List.filled(
        81,
        const CellState(value: 0, isGiven: false, isError: false),
      ),
      selectedIndex: null,
      difficulty: Difficulty.easy,
      isComplete: false,
    );

/// index 0만 isGiven=true (value=5)인 board
GameState _stateWithGiven() => GameState(
      puzzle: _emptyPuzzle(),
      board: List.generate(81, (i) {
        if (i == 0) {
          return const CellState(value: 5, isGiven: true, isError: false);
        }
        return const CellState(value: 0, isGiven: false, isError: false);
      }),
      selectedIndex: null,
      difficulty: Difficulty.easy,
      isComplete: false,
    );

// ─── Mock Notifiers ────────────────────────────────────────────────────────────

class _DefaultMockNotifier extends GameStateNotifier {
  final List<int> selectedCells = [];

  @override
  GameState? build() => _defaultState();

  @override
  void selectCell(int index) {
    selectedCells.add(index);
    // state 변경은 _element 초기화 이후에만 가능 — build() 이후 안전
    state = state?.copyWith(selectedIndex: index);
  }
}

/// 힌트 셀이 포함된 초기 상태 Notifier
class _GivenMockNotifier extends GameStateNotifier {
  final List<int> selectedCells = [];

  @override
  GameState? build() => _stateWithGiven();

  @override
  void selectCell(int index) {
    selectedCells.add(index);
    state = state?.copyWith(selectedIndex: index);
  }
}

class _NullMockNotifier extends GameStateNotifier {
  @override
  GameState? build() => null;
}

// ─── 테스트 ────────────────────────────────────────────────────────────────────

void main() {
  group('SudokuGrid', () {
    testWidgets('일반 셀 탭 시 selectCell이 해당 인덱스로 호출된다', (tester) async {
      final mock = _DefaultMockNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(
            home: Scaffold(body: SudokuGrid()),
          ),
        ),
      );

      // 인덱스 0 셀 탭 (GestureDetector 첫 번째)
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(mock.selectedCells, contains(0));
    });

    testWidgets('힌트 셀(isGiven=true) 탭도 selectCell이 호출된다', (tester) async {
      final mock = _GivenMockNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(
            home: Scaffold(body: SudokuGrid()),
          ),
        ),
      );

      // 인덱스 0 셀(힌트) 탭 — 선택은 허용, 입력만 GameStateNotifier에서 막음
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(mock.selectedCells, contains(0));
    });

    testWidgets('81개 셀(GestureDetector)이 렌더링된다', (tester) async {
      final mock = _DefaultMockNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => mock)],
          child: const MaterialApp(
            home: Scaffold(body: SudokuGrid()),
          ),
        ),
      );

      expect(
        find.byType(GestureDetector).evaluate().length,
        greaterThanOrEqualTo(81),
      );
    });

    testWidgets('gameState가 null이면 SizedBox.shrink만 렌더링된다', (tester) async {
      final nullMock = _NullMockNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWith(() => nullMock)],
          child: const MaterialApp(
            home: Scaffold(body: SudokuGrid()),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNothing);
    });
  });
}
