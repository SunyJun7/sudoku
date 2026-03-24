import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/data/game_storage_service.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';

// 테스트용 유효한 퍼즐 + 게임 상태 생성 헬퍼
GameState _makeGameState({
  String puzzleId = 'easy_001',
  Difficulty difficulty = Difficulty.easy,
  bool isComplete = false,
  int? selectedIndex,
}) {
  final solution = List<int>.generate(81, (i) => (i % 9) + 1);
  // givens: 앞 40칸은 solution 값, 나머지는 0
  final givens = List<int>.generate(81, (i) => i < 40 ? solution[i] : 0);

  final puzzle = PuzzleData(
    id: puzzleId,
    givens: givens,
    solution: solution,
  );

  final board = List<CellState>.generate(
    81,
    (i) => CellState(
      value: givens[i],
      isGiven: givens[i] != 0,
      isError: false,
    ),
  );

  return GameState(
    puzzle: puzzle,
    board: board,
    selectedIndex: selectedIndex,
    difficulty: difficulty,
    isComplete: isComplete,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameStorageService — 게임 저장/복원', () {
    late GameStorageService service;

    setUp(() {
      service = GameStorageService();
    });

    test('saveGame 후 hasSavedGame은 true를 반환한다', () async {
      final state = _makeGameState();
      await service.saveGame(state);
      expect(await service.hasSavedGame(), isTrue);
    });

    test('초기 상태에서 hasSavedGame은 false를 반환한다', () async {
      expect(await service.hasSavedGame(), isFalse);
    });

    test('loadGame은 저장된 GameState를 복원한다', () async {
      final state = _makeGameState(
        puzzleId: 'normal_005',
        difficulty: Difficulty.normal,
        selectedIndex: 42,
      );
      await service.saveGame(state);
      final loaded = await service.loadGame();

      expect(loaded, isNotNull);
      expect(loaded!.puzzle.id, 'normal_005');
      expect(loaded.difficulty, Difficulty.normal);
      expect(loaded.selectedIndex, 42);
      expect(loaded.board.length, 81);
    });

    test('저장된 게임이 없으면 loadGame은 null을 반환한다', () async {
      expect(await service.loadGame(), isNull);
    });

    test('clearGame 후 hasSavedGame은 false를 반환한다', () async {
      final state = _makeGameState();
      await service.saveGame(state);
      await service.clearGame();
      expect(await service.hasSavedGame(), isFalse);
    });

    test('clearGame 후 loadGame은 null을 반환한다', () async {
      final state = _makeGameState();
      await service.saveGame(state);
      await service.clearGame();
      expect(await service.loadGame(), isNull);
    });

    test('saveGame을 두 번 호출하면 최신 상태로 덮어쓴다', () async {
      await service.saveGame(_makeGameState(puzzleId: 'easy_001'));
      await service.saveGame(_makeGameState(puzzleId: 'easy_002'));
      final loaded = await service.loadGame();
      expect(loaded!.puzzle.id, 'easy_002');
    });

    test('isComplete=true 상태도 올바르게 저장/복원된다', () async {
      final state = _makeGameState(isComplete: true);
      await service.saveGame(state);
      final loaded = await service.loadGame();
      expect(loaded!.isComplete, isTrue);
    });

    test('selectedIndex=null 상태도 올바르게 저장/복원된다', () async {
      final state = _makeGameState(selectedIndex: null);
      await service.saveGame(state);
      final loaded = await service.loadGame();
      expect(loaded!.selectedIndex, isNull);
    });

    test('board의 isGiven/isError 상태가 보존된다', () async {
      final state = _makeGameState();
      await service.saveGame(state);
      final loaded = await service.loadGame();
      // 앞 40칸은 givens
      expect(loaded!.board[0].isGiven, isTrue);
      // 나머지는 givens=false
      expect(loaded.board[40].isGiven, isFalse);
    });
  });

  group('GameStorageService — 플레이 ID 관리', () {
    late GameStorageService service;

    setUp(() {
      service = GameStorageService();
    });

    test('초기 상태에서 getPlayedIds는 빈 목록을 반환한다', () async {
      final ids = await service.getPlayedIds(Difficulty.easy);
      expect(ids, isEmpty);
    });

    test('savePlayedId 후 getPlayedIds에 해당 ID가 포함된다', () async {
      await service.savePlayedId(Difficulty.easy, 'easy_001');
      final ids = await service.getPlayedIds(Difficulty.easy);
      expect(ids, contains('easy_001'));
    });

    test('동일 ID를 두 번 저장해도 중복 없이 한 번만 저장된다', () async {
      await service.savePlayedId(Difficulty.easy, 'easy_001');
      await service.savePlayedId(Difficulty.easy, 'easy_001');
      final ids = await service.getPlayedIds(Difficulty.easy);
      expect(ids.where((id) => id == 'easy_001').length, 1);
    });

    test('여러 ID를 순차적으로 저장하면 모두 조회된다', () async {
      await service.savePlayedId(Difficulty.normal, 'normal_001');
      await service.savePlayedId(Difficulty.normal, 'normal_002');
      await service.savePlayedId(Difficulty.normal, 'normal_003');
      final ids = await service.getPlayedIds(Difficulty.normal);
      expect(ids, containsAll(['normal_001', 'normal_002', 'normal_003']));
      expect(ids.length, 3);
    });

    test('clearPlayedIds 후 getPlayedIds는 빈 목록을 반환한다', () async {
      await service.savePlayedId(Difficulty.hard, 'hard_001');
      await service.savePlayedId(Difficulty.hard, 'hard_002');
      await service.clearPlayedIds(Difficulty.hard);
      final ids = await service.getPlayedIds(Difficulty.hard);
      expect(ids, isEmpty);
    });

    test('난이도별 플레이 ID가 독립적으로 관리된다', () async {
      await service.savePlayedId(Difficulty.easy, 'easy_001');
      await service.savePlayedId(Difficulty.normal, 'normal_001');
      await service.savePlayedId(Difficulty.hard, 'hard_001');

      final easyIds = await service.getPlayedIds(Difficulty.easy);
      final normalIds = await service.getPlayedIds(Difficulty.normal);
      final hardIds = await service.getPlayedIds(Difficulty.hard);

      expect(easyIds, contains('easy_001'));
      expect(easyIds, isNot(contains('normal_001')));
      expect(normalIds, contains('normal_001'));
      expect(normalIds, isNot(contains('hard_001')));
      expect(hardIds, contains('hard_001'));
    });

    test('easy clearPlayedIds가 normal/hard에 영향을 주지 않는다', () async {
      await service.savePlayedId(Difficulty.easy, 'easy_001');
      await service.savePlayedId(Difficulty.normal, 'normal_001');
      await service.clearPlayedIds(Difficulty.easy);

      expect(await service.getPlayedIds(Difficulty.easy), isEmpty);
      expect(await service.getPlayedIds(Difficulty.normal),
          contains('normal_001'));
    });
  });
}
