import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/local_puzzle_repository.dart';
import 'package:sudoku/domain/models/difficulty.dart';

// 유효한 테스트용 퍼즐 데이터 (givens/solution 각 81개)
const _validSolution = [
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

const _validGivens = [
  5, 3, 0, 0, 7, 0, 0, 0, 0,
  6, 0, 0, 1, 9, 5, 0, 0, 0,
  0, 9, 8, 0, 0, 0, 0, 6, 0,
  8, 0, 0, 0, 6, 0, 0, 0, 3,
  4, 0, 0, 8, 0, 3, 0, 0, 1,
  7, 0, 0, 0, 2, 0, 0, 0, 6,
  0, 6, 0, 0, 0, 7, 2, 8, 0,
  0, 0, 0, 4, 1, 9, 0, 0, 5,
  0, 0, 0, 0, 8, 0, 0, 7, 9,
];

/// 테스트용 AssetBundle — loadString만 오버라이드
class _MockAssetBundle extends CachingAssetBundle {
  final Map<String, String> _assets;

  _MockAssetBundle(this._assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _assets[key];
    if (value == null) throw FlutterError('Asset not found: $key');
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final str = _assets[key];
    if (str == null) throw FlutterError('Asset not found: $key');
    final bytes = utf8.encode(str);
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

String _makePuzzleJson(String prefix, int count) {
  final puzzles = List.generate(count, (i) {
    return {
      'id': '${prefix}_${(i + 1).toString().padLeft(3, '0')}',
      'givens': _validGivens,
      'solution': _validSolution,
    };
  });
  return jsonEncode({'puzzles': puzzles});
}

void main() {
  group('LocalPuzzleRepository', () {
    late _MockAssetBundle mockBundle;
    late LocalPuzzleRepository repository;

    setUp(() {
      mockBundle = _MockAssetBundle({
        'assets/puzzles/easy.json': _makePuzzleJson('easy', 5),
        'assets/puzzles/normal.json': _makePuzzleJson('normal', 5),
        'assets/puzzles/hard.json': _makePuzzleJson('hard', 5),
      });
      repository = LocalPuzzleRepository(assetBundle: mockBundle);
    });

    test('easy 난이도 퍼즐을 반환한다', () async {
      final puzzle = await repository.getPuzzle(Difficulty.easy);
      expect(puzzle.id, startsWith('easy_'));
      expect(puzzle.givens.length, 81);
      expect(puzzle.solution.length, 81);
    });

    test('normal 난이도 퍼즐을 반환한다', () async {
      final puzzle = await repository.getPuzzle(Difficulty.normal);
      expect(puzzle.id, startsWith('normal_'));
    });

    test('hard 난이도 퍼즐을 반환한다', () async {
      final puzzle = await repository.getPuzzle(Difficulty.hard);
      expect(puzzle.id, startsWith('hard_'));
    });

    test('excludeIds에 포함된 퍼즐은 반환하지 않는다', () async {
      // 5개 퍼즐 중 4개를 제외하면 나머지 1개만 반환
      final excludeIds = ['easy_001', 'easy_002', 'easy_003', 'easy_004'];
      final puzzle =
          await repository.getPuzzle(Difficulty.easy, excludeIds: excludeIds);
      expect(puzzle.id, 'easy_005');
    });

    test('모든 퍼즐이 excludeIds에 포함되면 excludeIds를 무시하고 임의 반환한다', () async {
      final allIds = List.generate(
          5, (i) => 'easy_${(i + 1).toString().padLeft(3, '0')}');
      // 전체 소진 — 에러 없이 퍼즐을 반환해야 함
      final puzzle =
          await repository.getPuzzle(Difficulty.easy, excludeIds: allIds);
      expect(puzzle.id, startsWith('easy_'));
    });

    test('excludeIds가 비어있으면 모든 퍼즐에서 선택한다', () async {
      final puzzle =
          await repository.getPuzzle(Difficulty.easy, excludeIds: []);
      expect(puzzle.id, startsWith('easy_'));
    });

    test('반환된 퍼즐의 givens 0이 아닌 값은 solution과 일치한다', () async {
      final puzzle = await repository.getPuzzle(Difficulty.easy);
      for (int i = 0; i < 81; i++) {
        if (puzzle.givens[i] != 0) {
          expect(puzzle.givens[i], puzzle.solution[i],
              reason: 'givens[$i] should match solution[$i]');
        }
      }
    });

    test('존재하지 않는 에셋 키는 FlutterError를 던진다', () async {
      final emptyBundle = _MockAssetBundle({});
      final badRepo = LocalPuzzleRepository(assetBundle: emptyBundle);
      expect(
        () => badRepo.getPuzzle(Difficulty.easy),
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
