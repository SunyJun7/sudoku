import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/game_storage_service.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';
import 'package:sudoku/domain/puzzle_repository.dart';
import 'package:sudoku/providers/game_state_provider.dart';
import 'package:sudoku/providers/game_storage_provider.dart';
import 'package:sudoku/providers/puzzle_repository_provider.dart';

// ---------------------------------------------------------------------------
// Mock: PuzzleRepository
// ---------------------------------------------------------------------------

class MockPuzzleRepository implements PuzzleRepository {
  final PuzzleData _puzzle;

  MockPuzzleRepository(this._puzzle);

  @override
  Future<PuzzleData> getPuzzle(
    Difficulty difficulty, {
    List<String> excludeIds = const [],
  }) async {
    return _puzzle;
  }
}

// ---------------------------------------------------------------------------
// Mock: GameStorageService
// ---------------------------------------------------------------------------

class MockGameStorageService implements GameStorageService {
  GameState? _saved;
  bool throwOnLoad = false;
  int clearGameCallCount = 0;

  @override
  Future<void> saveGame(GameState state) async {
    _saved = state;
  }

  @override
  Future<GameState?> loadGame() async {
    if (throwOnLoad) throw const FormatException('corrupt JSON');
    return _saved;
  }

  @override
  Future<void> clearGame() async {
    clearGameCallCount++;
    _saved = null;
  }

  @override
  Future<bool> hasSavedGame() async {
    return _saved != null;
  }

  @override
  Future<List<String>> getPlayedIds(Difficulty difficulty) async {
    return [];
  }

  @override
  Future<void> savePlayedId(Difficulty difficulty, String puzzleId) async {}

  @override
  Future<void> clearPlayedIds(Difficulty difficulty) async {}
}

// ---------------------------------------------------------------------------
// 헬퍼: 완전한 9x9 퍼즐 (행·열·박스 모두 유효한 솔루션)
// ---------------------------------------------------------------------------

/// solution은 표준 스도쿠 격자. givens는 첫 행만 노출, 나머지는 0.
PuzzleData _makePuzzle({String id = 'test_001'}) {
  // 유효한 스도쿠 솔루션 (행 1~9를 순환 시프트하여 생성)
  const solution = [
    5, 3, 4, 6, 7, 8, 9, 1, 2,
    6, 7, 2, 1, 9, 5, 3, 4, 8,
    1, 9, 8, 3, 4, 2, 5, 6, 7,
    8, 5, 9, 7, 6, 1, 4, 2, 3,
    4, 2, 6, 8, 5, 3, 7, 9, 1,
    7, 1, 3, 9, 2, 4, 8, 5, 6,
    9, 6, 1, 5, 3, 7, 2, 8, 4,
    2, 8, 7, 4, 1, 9, 6, 3, 5,
    3, 4, 5, 2, 8, 6, 1, 7, 9,
  ];

  // givens: 첫 행(인덱스 0~8)만 힌트로 노출
  final givens = List<int>.filled(81, 0);
  for (int i = 0; i < 9; i++) {
    givens[i] = solution[i];
  }

  return PuzzleData(id: id, givens: givens, solution: solution);
}

// ---------------------------------------------------------------------------
// 헬퍼: ProviderContainer 생성
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({
  required MockPuzzleRepository mockRepo,
  required MockGameStorageService mockStorage,
}) {
  return ProviderContainer(
    overrides: [
      puzzleRepositoryProvider.overrideWithValue(mockRepo),
      gameStorageProvider.overrideWithValue(mockStorage),
    ],
  );
}

// ---------------------------------------------------------------------------
// 테스트
// ---------------------------------------------------------------------------

void main() {
  group('GameStateNotifier', () {
    late PuzzleData puzzle;
    late MockPuzzleRepository mockRepo;
    late MockGameStorageService mockStorage;
    late ProviderContainer container;

    setUp(() {
      puzzle = _makePuzzle();
      mockRepo = MockPuzzleRepository(puzzle);
      mockStorage = MockGameStorageService();
      container = _makeContainer(
        mockRepo: mockRepo,
        mockStorage: mockStorage,
      );
      addTearDown(container.dispose);
    });

    // -----------------------------------------------------------------------
    // 1. startNewGame → state가 null에서 GameState로 변경
    // -----------------------------------------------------------------------
    test('startNewGame(easy) → state가 null에서 GameState로 변경', () async {
      expect(container.read(gameStateProvider), isNull);

      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);

      final state = container.read(gameStateProvider);
      expect(state, isNotNull);
      expect(state!.difficulty, Difficulty.easy);
      expect(state.board.length, 81);
      expect(state.isComplete, isFalse);
      // 첫 행(인덱스 0~8)은 givens이어야 함
      for (int i = 0; i < 9; i++) {
        expect(state.board[i].isGiven, isTrue);
        expect(state.board[i].value, puzzle.givens[i]);
      }
    });

    // -----------------------------------------------------------------------
    // 2. placeNumber → 선택된 셀에 숫자 입력, isError 정확히 설정
    // -----------------------------------------------------------------------
    test('placeNumber(정답) → isError = false', () async {
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);
      container.read(gameStateProvider.notifier).selectCell(9); // row 2, col 1
      // index 9의 solution은 6
      container.read(gameStateProvider.notifier).placeNumber(6);

      final cell = container.read(gameStateProvider)!.board[9];
      expect(cell.value, 6);
      expect(cell.isError, isFalse);
    });

    test('placeNumber(오답) → isError = true', () async {
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);
      container.read(gameStateProvider.notifier).selectCell(9);
      // index 9의 정답은 6이므로 5는 오류
      container.read(gameStateProvider.notifier).placeNumber(5);

      final cell = container.read(gameStateProvider)!.board[9];
      expect(cell.value, 5);
      expect(cell.isError, isTrue);
    });

    test('placeNumber — givens 셀은 수정 불가', () async {
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);
      // index 0은 givens
      final originalValue = container.read(gameStateProvider)!.board[0].value;
      container.read(gameStateProvider.notifier).selectCell(0);
      container.read(gameStateProvider.notifier).placeNumber(9);

      expect(
        container.read(gameStateProvider)!.board[0].value,
        originalValue,
      );
    });

    // -----------------------------------------------------------------------
    // 3. eraseNumber → 선택된 셀 지우기
    // -----------------------------------------------------------------------
    test('eraseNumber → 선택된 셀 값이 0으로 초기화', () async {
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);
      container.read(gameStateProvider.notifier).selectCell(9);
      container.read(gameStateProvider.notifier).placeNumber(5); // 오답 입력
      expect(container.read(gameStateProvider)!.board[9].value, 5);

      container.read(gameStateProvider.notifier).eraseNumber();

      final cell = container.read(gameStateProvider)!.board[9];
      expect(cell.value, 0);
      expect(cell.isError, isFalse);
    });

    test('eraseNumber — givens 셀은 지울 수 없음', () async {
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);
      final originalValue = container.read(gameStateProvider)!.board[0].value;
      container.read(gameStateProvider.notifier).selectCell(0); // given
      container.read(gameStateProvider.notifier).eraseNumber();

      expect(container.read(gameStateProvider)!.board[0].value, originalValue);
    });

    // -----------------------------------------------------------------------
    // 4. resetGame → 사용자 입력만 초기화, givens 유지
    // -----------------------------------------------------------------------
    test('resetGame → 사용자 입력 초기화, givens 유지', () async {
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);

      // 사용자 입력 몇 개 넣기
      container.read(gameStateProvider.notifier).selectCell(9);
      container.read(gameStateProvider.notifier).placeNumber(6);
      container.read(gameStateProvider.notifier).selectCell(10);
      container.read(gameStateProvider.notifier).placeNumber(2);

      container.read(gameStateProvider.notifier).resetGame();

      final state = container.read(gameStateProvider)!;
      // given 셀은 값 유지
      for (int i = 0; i < 9; i++) {
        expect(state.board[i].isGiven, isTrue);
        expect(state.board[i].value, puzzle.givens[i]);
      }
      // 사용자 입력 셀은 0으로 초기화
      expect(state.board[9].value, 0);
      expect(state.board[10].value, 0);
      expect(state.isComplete, isFalse);
      expect(state.selectedIndex, isNull);
    });

    // -----------------------------------------------------------------------
    // 5. 클리어 감지 → 모든 칸 정답 입력 시 isComplete = true
    // -----------------------------------------------------------------------
    test('모든 빈 칸에 정답 입력 시 isComplete = true', () async {
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);

      // givens가 아닌 셀(인덱스 9~80)에 모두 정답 입력
      for (int i = 9; i < 81; i++) {
        container.read(gameStateProvider.notifier).selectCell(i);
        container
            .read(gameStateProvider.notifier)
            .placeNumber(puzzle.solution[i]);
      }

      expect(container.read(gameStateProvider)!.isComplete, isTrue);
    });

    // -----------------------------------------------------------------------
    // 6. restoreGame corrupt 데이터 → clearGame() 호출 후 state = null 유지
    // -----------------------------------------------------------------------
    test('restoreGame — corrupt 데이터 → clearGame 호출 후 state null', () async {
      mockStorage.throwOnLoad = true;
      // state가 null인 상태에서 복원 시도
      await container.read(gameStateProvider.notifier).restoreGame();

      expect(container.read(gameStateProvider), isNull);
      expect(mockStorage.clearGameCallCount, 1);
    });

    test('restoreGame — 저장된 게임 있으면 state 복원', () async {
      // 먼저 게임 시작 후 저장
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);
      final savedState = container.read(gameStateProvider)!;

      // 새 container 생성하여 복원 테스트
      final container2 = _makeContainer(
        mockRepo: mockRepo,
        mockStorage: mockStorage,
      );
      addTearDown(container2.dispose);

      expect(container2.read(gameStateProvider), isNull);
      await container2.read(gameStateProvider.notifier).restoreGame();
      expect(container2.read(gameStateProvider), savedState);
    });

    // -----------------------------------------------------------------------
    // 7. selectCell → selectedIndex 갱신
    // -----------------------------------------------------------------------
    test('selectCell(index) → selectedIndex 갱신', () async {
      await container
          .read(gameStateProvider.notifier)
          .startNewGame(Difficulty.easy);

      expect(container.read(gameStateProvider)!.selectedIndex, isNull);

      container.read(gameStateProvider.notifier).selectCell(20);
      expect(container.read(gameStateProvider)!.selectedIndex, 20);

      container.read(gameStateProvider.notifier).selectCell(50);
      expect(container.read(gameStateProvider)!.selectedIndex, 50);
    });

    test('selectCell — state null이면 아무 변화 없음', () {
      expect(container.read(gameStateProvider), isNull);
      container.read(gameStateProvider.notifier).selectCell(5);
      expect(container.read(gameStateProvider), isNull);
    });
  });
}
