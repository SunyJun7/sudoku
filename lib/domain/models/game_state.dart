import 'cell_state.dart';
import 'difficulty.dart';
import 'puzzle_data.dart';

class GameState {
  final PuzzleData puzzle;
  final List<CellState> board;
  final int? selectedIndex;
  final Difficulty difficulty;
  final bool isComplete;
  // UI 전용: 마지막으로 입력한 셀 인덱스 (직렬화 불필요)
  final int? lastPlacedIndex;

  const GameState({
    required this.puzzle,
    required this.board,
    required this.selectedIndex,
    required this.difficulty,
    required this.isComplete,
    this.lastPlacedIndex,
  });

  GameState copyWith({
    PuzzleData? puzzle,
    List<CellState>? board,
    Object? selectedIndex = _sentinel,
    Difficulty? difficulty,
    bool? isComplete,
    Object? lastPlacedIndex = _sentinel,
  }) {
    return GameState(
      puzzle: puzzle ?? this.puzzle,
      board: board ?? this.board,
      selectedIndex: selectedIndex == _sentinel
          ? this.selectedIndex
          : selectedIndex as int?,
      difficulty: difficulty ?? this.difficulty,
      isComplete: isComplete ?? this.isComplete,
      lastPlacedIndex: lastPlacedIndex == _sentinel
          ? this.lastPlacedIndex
          : lastPlacedIndex as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzle': puzzle.toJson(),
      'board': board.map((c) => c.toJson()).toList(),
      'selectedIndex': selectedIndex,
      'difficulty': difficulty.name,
      'isComplete': isComplete,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      puzzle: PuzzleData.fromJson(json['puzzle'] as Map<String, dynamic>),
      board: (json['board'] as List)
          .map((c) => CellState.fromJson(c as Map<String, dynamic>))
          .toList(),
      selectedIndex: json['selectedIndex'] as int?,
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      isComplete: json['isComplete'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameState) return false;
    if (puzzle != other.puzzle) return false;
    if (selectedIndex != other.selectedIndex) return false;
    if (difficulty != other.difficulty) return false;
    if (isComplete != other.isComplete) return false;
    if (board.length != other.board.length) return false;
    for (int i = 0; i < board.length; i++) {
      if (board[i] != other.board[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        puzzle,
        Object.hashAll(board),
        selectedIndex,
        difficulty,
        isComplete,
      );
}

// sentinel 값: copyWith에서 null과 "전달하지 않음"을 구별하기 위해 사용
const Object _sentinel = Object();
