import 'models/cell_state.dart';
import 'models/puzzle_data.dart';

class SudokuValidator {
  /// 특정 인덱스의 값이 정답과 일치하는지 확인.
  /// value가 0(빈칸)이면 항상 false 반환.
  static bool isCorrect(PuzzleData puzzle, int index, int value) {
    if (value == 0) return false;
    return puzzle.solution[index] == value;
  }

  /// 보드가 완성 상태인지 확인.
  /// 81칸 모두 채워지고(value != 0) 오류가 없어야(isError == false) 완성.
  static bool isComplete(PuzzleData puzzle, List<CellState> board) {
    if (board.length != 81) return false;
    for (int i = 0; i < 81; i++) {
      final cell = board[i];
      if (cell.value == 0) return false;
      if (cell.isError) return false;
      if (cell.value != puzzle.solution[i]) return false;
    }
    return true;
  }
}
