import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';

PuzzleData _makePuzzle() {
  final solution = List.generate(81, (i) => (i % 9) + 1);
  final givens = List.generate(81, (i) => i < 9 ? solution[i] : 0);
  return PuzzleData(id: 'test_001', givens: givens, solution: solution);
}

List<CellState> _makeBoard(PuzzleData puzzle) {
  return List.generate(
    81,
    (i) => CellState(
      value: puzzle.givens[i],
      isGiven: puzzle.givens[i] != 0,
      isError: false,
    ),
  );
}

void main() {
  group('CellState', () {
    test('copyWith으로 value를 변경할 수 있다', () {
      const cell = CellState(value: 0, isGiven: false, isError: false);
      final updated = cell.copyWith(value: 5);
      expect(updated.value, 5);
      expect(updated.isGiven, false);
      expect(updated.isError, false);
    });

    test('copyWith으로 isError를 변경할 수 있다', () {
      const cell = CellState(value: 3, isGiven: false, isError: false);
      final updated = cell.copyWith(isError: true);
      expect(updated.value, 3);
      expect(updated.isError, true);
    });

    test('copyWith은 isGiven을 변경할 수 없다', () {
      const cell = CellState(value: 5, isGiven: true, isError: false);
      final updated = cell.copyWith(value: 7);
      expect(updated.isGiven, true); // isGiven은 유지
    });

    test('값이 같으면 동일한 객체로 취급된다', () {
      const a = CellState(value: 1, isGiven: true, isError: false);
      const b = CellState(value: 1, isGiven: true, isError: false);
      expect(a, equals(b));
    });

    test('toJson / fromJson 왕복 직렬화가 정상 동작한다', () {
      const cell = CellState(value: 7, isGiven: true, isError: false);
      final json = cell.toJson();
      final restored = CellState.fromJson(json);
      expect(restored, equals(cell));
    });
  });

  group('GameState 생성', () {
    test('기본 GameState를 생성할 수 있다', () {
      final puzzle = _makePuzzle();
      final board = _makeBoard(puzzle);
      final state = GameState(
        puzzle: puzzle,
        board: board,
        selectedIndex: null,
        difficulty: Difficulty.easy,
        isComplete: false,
      );
      expect(state.board.length, 81);
      expect(state.selectedIndex, isNull);
      expect(state.isComplete, isFalse);
      expect(state.difficulty, Difficulty.easy);
    });
  });

  group('GameState.copyWith', () {
    test('selectedIndex를 null로 설정할 수 있다', () {
      final puzzle = _makePuzzle();
      final board = _makeBoard(puzzle);
      final state = GameState(
        puzzle: puzzle,
        board: board,
        selectedIndex: 5,
        difficulty: Difficulty.easy,
        isComplete: false,
      );
      final updated = state.copyWith(selectedIndex: null);
      expect(updated.selectedIndex, isNull);
    });

    test('selectedIndex를 정수로 업데이트할 수 있다', () {
      final puzzle = _makePuzzle();
      final board = _makeBoard(puzzle);
      final state = GameState(
        puzzle: puzzle,
        board: board,
        selectedIndex: null,
        difficulty: Difficulty.easy,
        isComplete: false,
      );
      final updated = state.copyWith(selectedIndex: 42);
      expect(updated.selectedIndex, 42);
    });

    test('selectedIndex를 생략하면 기존 값을 유지한다', () {
      final puzzle = _makePuzzle();
      final board = _makeBoard(puzzle);
      final state = GameState(
        puzzle: puzzle,
        board: board,
        selectedIndex: 10,
        difficulty: Difficulty.easy,
        isComplete: false,
      );
      final updated = state.copyWith(isComplete: true);
      expect(updated.selectedIndex, 10);
    });

    test('difficulty를 변경할 수 있다', () {
      final puzzle = _makePuzzle();
      final board = _makeBoard(puzzle);
      final state = GameState(
        puzzle: puzzle,
        board: board,
        selectedIndex: null,
        difficulty: Difficulty.easy,
        isComplete: false,
      );
      final updated = state.copyWith(difficulty: Difficulty.hard);
      expect(updated.difficulty, Difficulty.hard);
    });
  });

  group('GameState toJson / fromJson', () {
    test('직렬화 후 역직렬화하면 동일한 데이터가 복원된다', () {
      final puzzle = _makePuzzle();
      final board = _makeBoard(puzzle);
      final state = GameState(
        puzzle: puzzle,
        board: board,
        selectedIndex: 15,
        difficulty: Difficulty.normal,
        isComplete: false,
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.puzzle.id, state.puzzle.id);
      expect(restored.puzzle.givens, state.puzzle.givens);
      expect(restored.puzzle.solution, state.puzzle.solution);
      expect(restored.board.length, state.board.length);
      expect(restored.selectedIndex, state.selectedIndex);
      expect(restored.difficulty, state.difficulty);
      expect(restored.isComplete, state.isComplete);
    });

    test('selectedIndex가 null일 때도 정상 직렬화/역직렬화된다', () {
      final puzzle = _makePuzzle();
      final board = _makeBoard(puzzle);
      final state = GameState(
        puzzle: puzzle,
        board: board,
        selectedIndex: null,
        difficulty: Difficulty.hard,
        isComplete: true,
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.selectedIndex, isNull);
      expect(restored.isComplete, isTrue);
      expect(restored.difficulty, Difficulty.hard);
    });

    test('board의 각 CellState가 정확히 복원된다', () {
      final puzzle = _makePuzzle();
      final board = List.generate(
        81,
        (i) => CellState(
          value: i % 3 == 0 ? puzzle.solution[i] : 0,
          isGiven: i < 9,
          isError: i >= 9 && i % 5 == 0,
        ),
      );
      final state = GameState(
        puzzle: puzzle,
        board: board,
        selectedIndex: null,
        difficulty: Difficulty.easy,
        isComplete: false,
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      for (int i = 0; i < 81; i++) {
        expect(restored.board[i].value, board[i].value,
            reason: 'index $i: value mismatch');
        expect(restored.board[i].isGiven, board[i].isGiven,
            reason: 'index $i: isGiven mismatch');
        expect(restored.board[i].isError, board[i].isError,
            reason: 'index $i: isError mismatch');
      }
    });

    test('Difficulty.easy / normal / hard 모두 직렬화된다', () {
      for (final diff in Difficulty.values) {
        final puzzle = _makePuzzle();
        final board = _makeBoard(puzzle);
        final state = GameState(
          puzzle: puzzle,
          board: board,
          selectedIndex: null,
          difficulty: diff,
          isComplete: false,
        );
        final restored = GameState.fromJson(state.toJson());
        expect(restored.difficulty, diff);
      }
    });
  });
}
