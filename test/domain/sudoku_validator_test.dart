import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';
import 'package:sudoku/domain/sudoku_validator.dart';

void main() {
  // 테스트용 단순 퍼즐: solution은 1~9가 반복되는 81개 배열
  // givens는 처음 9칸만 힌트, 나머지는 0
  late PuzzleData puzzle;

  setUp(() {
    final solution = List.generate(81, (i) => (i % 9) + 1);
    final givens = List.generate(81, (i) => i < 9 ? solution[i] : 0);
    puzzle = PuzzleData(
      id: 'test_001',
      givens: givens,
      solution: solution,
    );
  });

  group('SudokuValidator.isCorrect', () {
    test('정답과 일치하는 값은 true를 반환한다', () {
      // solution[0] == 1
      expect(SudokuValidator.isCorrect(puzzle, 0, 1), isTrue);
    });

    test('정답과 다른 값은 false를 반환한다', () {
      // solution[0] == 1, 입력은 5
      expect(SudokuValidator.isCorrect(puzzle, 0, 5), isFalse);
    });

    test('value가 0이면 false를 반환한다', () {
      expect(SudokuValidator.isCorrect(puzzle, 0, 0), isFalse);
    });

    test('마지막 인덱스(80)에서도 정상 동작한다', () {
      // solution[80] == (80 % 9) + 1 == 9
      expect(SudokuValidator.isCorrect(puzzle, 80, 9), isTrue);
      expect(SudokuValidator.isCorrect(puzzle, 80, 1), isFalse);
    });

    test('중간 인덱스에서 정상 동작한다', () {
      // solution[40] == (40 % 9) + 1 == 5
      expect(SudokuValidator.isCorrect(puzzle, 40, 5), isTrue);
      expect(SudokuValidator.isCorrect(puzzle, 40, 3), isFalse);
    });
  });

  group('SudokuValidator.isComplete', () {
    test('모든 칸이 정답으로 채워지면 true를 반환한다', () {
      final board = List.generate(
        81,
        (i) => CellState(
          value: puzzle.solution[i],
          isGiven: i < 9,
          isError: false,
        ),
      );
      expect(SudokuValidator.isComplete(puzzle, board), isTrue);
    });

    test('빈 칸이 있으면 false를 반환한다', () {
      final board = List.generate(
        81,
        (i) => CellState(
          value: i == 50 ? 0 : puzzle.solution[i],
          isGiven: i < 9,
          isError: false,
        ),
      );
      expect(SudokuValidator.isComplete(puzzle, board), isFalse);
    });

    test('오류가 있는 칸이 있으면 false를 반환한다', () {
      final board = List.generate(
        81,
        (i) => CellState(
          value: puzzle.solution[i],
          isGiven: i < 9,
          isError: i == 10, // 인덱스 10만 오류로 표시
        ),
      );
      expect(SudokuValidator.isComplete(puzzle, board), isFalse);
    });

    test('정답이 아닌 값이 있으면 false를 반환한다', () {
      final board = List.generate(
        81,
        (i) => CellState(
          value: i == 20 ? (puzzle.solution[20] % 9 + 1) : puzzle.solution[i],
          isGiven: i < 9,
          isError: false,
        ),
      );
      expect(SudokuValidator.isComplete(puzzle, board), isFalse);
    });

    test('보드 크기가 81이 아니면 false를 반환한다', () {
      final board = List.generate(
        80,
        (i) => CellState(
          value: puzzle.solution[i],
          isGiven: false,
          isError: false,
        ),
      );
      expect(SudokuValidator.isComplete(puzzle, board), isFalse);
    });

    test('빈 보드는 false를 반환한다', () {
      final board = List.generate(
        81,
        (_) => const CellState(value: 0, isGiven: false, isError: false),
      );
      expect(SudokuValidator.isComplete(puzzle, board), isFalse);
    });
  });
}
