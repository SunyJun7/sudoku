import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';

Map<String, dynamic> _validJson() {
  final solution = List.generate(81, (i) => (i % 9) + 1);
  final givens = List.generate(81, (i) => i < 9 ? solution[i] : 0);
  return {
    'id': 'easy_001',
    'givens': givens,
    'solution': solution,
  };
}

void main() {
  group('PuzzleData.fromJson', () {
    test('올바른 JSON에서 PuzzleData를 생성할 수 있다', () {
      final json = _validJson();
      final puzzle = PuzzleData.fromJson(json);

      expect(puzzle.id, 'easy_001');
      expect(puzzle.givens.length, 81);
      expect(puzzle.solution.length, 81);
    });

    test('givens의 각 값이 올바르게 파싱된다', () {
      final json = _validJson();
      final puzzle = PuzzleData.fromJson(json);

      // 처음 9칸은 힌트 (1~9)
      for (int i = 0; i < 9; i++) {
        expect(puzzle.givens[i], (i % 9) + 1);
      }
      // 나머지는 0
      for (int i = 9; i < 81; i++) {
        expect(puzzle.givens[i], 0);
      }
    });

    test('solution의 각 값이 올바르게 파싱된다', () {
      final json = _validJson();
      final puzzle = PuzzleData.fromJson(json);

      for (int i = 0; i < 81; i++) {
        expect(puzzle.solution[i], (i % 9) + 1);
      }
    });

    test('id가 올바르게 파싱된다', () {
      final json = _validJson();
      json['id'] = 'hard_099';
      final puzzle = PuzzleData.fromJson(json);
      expect(puzzle.id, 'hard_099');
    });

    test('JSON 내부 정수가 List<dynamic>으로 오더라도 파싱된다', () {
      // JSON 역직렬화 시 Dart는 기본적으로 List<dynamic>을 반환
      final json = <String, dynamic>{
        'id': 'normal_010',
        'givens': <dynamic>[1, 0, 0, 0, 0, 0, 0, 0, 0] +
            List<dynamic>.filled(72, 0),
        'solution': List<dynamic>.generate(81, (i) => (i % 9) + 1),
      };
      final puzzle = PuzzleData.fromJson(json);
      expect(puzzle.givens[0], 1);
      expect(puzzle.givens[1], 0);
    });
  });

  group('PuzzleData.toJson', () {
    test('toJson이 올바른 키와 값을 반환한다', () {
      final puzzle = PuzzleData(
        id: 'easy_001',
        givens: List.generate(81, (i) => i < 9 ? (i % 9) + 1 : 0),
        solution: List.generate(81, (i) => (i % 9) + 1),
      );

      final json = puzzle.toJson();

      expect(json['id'], 'easy_001');
      expect(json['givens'], isA<List>());
      expect(json['solution'], isA<List>());
      expect((json['givens'] as List).length, 81);
      expect((json['solution'] as List).length, 81);
    });

    test('toJson 후 fromJson 왕복 직렬화가 동일한 데이터를 반환한다', () {
      final original = PuzzleData(
        id: 'normal_005',
        givens: List.generate(81, (i) => i % 2 == 0 ? (i % 9) + 1 : 0),
        solution: List.generate(81, (i) => (i % 9) + 1),
      );

      final json = original.toJson();
      final restored = PuzzleData.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.givens, original.givens);
      expect(restored.solution, original.solution);
    });

    test('모든 0으로 이루어진 givens도 직렬화/역직렬화된다', () {
      final puzzle = PuzzleData(
        id: 'hard_001',
        givens: List.filled(81, 0),
        solution: List.generate(81, (i) => (i % 9) + 1),
      );

      final restored = PuzzleData.fromJson(puzzle.toJson());
      expect(restored.givens, List.filled(81, 0));
    });
  });

  group('PuzzleData equality', () {
    test('같은 id를 가진 PuzzleData는 동일하다', () {
      final a = PuzzleData(
        id: 'easy_001',
        givens: List.filled(81, 0),
        solution: List.generate(81, (i) => (i % 9) + 1),
      );
      final b = PuzzleData(
        id: 'easy_001',
        givens: List.filled(81, 1),
        solution: List.generate(81, (i) => i % 9 + 1),
      );
      expect(a, equals(b));
    });

    test('다른 id를 가진 PuzzleData는 다르다', () {
      final a = PuzzleData(
        id: 'easy_001',
        givens: List.filled(81, 0),
        solution: List.generate(81, (i) => (i % 9) + 1),
      );
      final b = PuzzleData(
        id: 'easy_002',
        givens: List.filled(81, 0),
        solution: List.generate(81, (i) => (i % 9) + 1),
      );
      expect(a, isNot(equals(b)));
    });
  });
}
