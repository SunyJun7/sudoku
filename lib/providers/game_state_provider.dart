import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/cell_state.dart';
import '../domain/models/difficulty.dart';
import '../domain/models/game_state.dart';
import '../domain/sudoku_validator.dart';
import 'game_storage_provider.dart';
import 'puzzle_repository_provider.dart';

final gameStateProvider = NotifierProvider<GameStateNotifier, GameState?>(() {
  return GameStateNotifier();
});

class GameStateNotifier extends Notifier<GameState?> {
  @override
  GameState? build() => null;

  /// 새 게임 시작
  Future<void> startNewGame(Difficulty difficulty) async {
    final repository = ref.read(puzzleRepositoryProvider);
    final storage = ref.read(gameStorageProvider);

    final playedIds = await storage.getPlayedIds(difficulty);
    final puzzle = await repository.getPuzzle(difficulty, excludeIds: playedIds);

    final board = List<CellState>.generate(81, (i) {
      final given = puzzle.givens[i];
      return CellState(
        value: given,
        isGiven: given != 0,
        isError: false,
      );
    });

    state = GameState(
      puzzle: puzzle,
      board: board,
      selectedIndex: null,
      difficulty: difficulty,
      isComplete: false,
    );

    await storage.saveGame(state!);
  }

  /// 저장된 게임 복원
  Future<void> restoreGame() async {
    final storage = ref.read(gameStorageProvider);
    try {
      final savedState = await storage.loadGame();
      if (savedState != null) {
        state = savedState;
      }
    } catch (e) {
      // corrupt 데이터 → 저장 삭제 후 null 유지
      await storage.clearGame();
    }
  }

  /// 셀 선택
  void selectCell(int index) {
    if (state == null) return;
    state = state!.copyWith(selectedIndex: index);
  }

  /// 숫자 입력 (오류 검증 포함)
  void placeNumber(int value) {
    final current = state;
    if (current == null) return;
    final index = current.selectedIndex;
    if (index == null) return;

    final cell = current.board[index];
    if (cell.isGiven) return; // 힌트 셀은 수정 불가

    final isError = !SudokuValidator.isCorrect(current.puzzle, index, value);
    final newCell = CellState(value: value, isGiven: false, isError: isError);

    final newBoard = List<CellState>.from(current.board);
    newBoard[index] = newCell;

    final isComplete = SudokuValidator.isComplete(current.puzzle, newBoard);

    state = current.copyWith(board: newBoard, isComplete: isComplete, lastPlacedIndex: index);

    // 비동기 저장 (fire-and-forget)
    _saveStateAsync();
  }

  /// 숫자 지우기
  void eraseNumber() {
    final current = state;
    if (current == null) return;
    final index = current.selectedIndex;
    if (index == null) return;

    final cell = current.board[index];
    if (cell.isGiven) return; // 힌트 셀은 수정 불가
    if (cell.value == 0) return; // 이미 비어 있으면 무시

    final newBoard = List<CellState>.from(current.board);
    newBoard[index] = CellState(value: 0, isGiven: false, isError: false);

    state = current.copyWith(board: newBoard, isComplete: false);

    _saveStateAsync();
  }

  /// 게임 재시작 (사용자 입력만 초기화, givens 유지)
  void resetGame() {
    final current = state;
    if (current == null) return;

    final resetBoard = List<CellState>.generate(81, (i) {
      final cell = current.board[i];
      if (cell.isGiven) return cell;
      return const CellState(value: 0, isGiven: false, isError: false);
    });

    state = current.copyWith(
      board: resetBoard,
      selectedIndex: null,
      isComplete: false,
    );

    _saveStateAsync();
  }

  /// 상태 저장
  Future<void> saveState() async {
    final current = state;
    if (current == null) return;
    final storage = ref.read(gameStorageProvider);
    await storage.saveGame(current);
  }

  /// 저장 상태 삭제
  Future<void> clearSavedState() async {
    final storage = ref.read(gameStorageProvider);
    await storage.clearGame();
  }

  void _saveStateAsync() {
    saveState().ignore();
  }
}
