import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/services/curfew_checker.dart';

void main() {
  group('CurfewChecker.isBlockedTime', () {
    test('01:59 — 차단 시간대가 아니다', () {
      final time = DateTime(2024, 1, 1, 1, 59);
      expect(CurfewChecker.isBlockedTime(time), isFalse);
    });

    test('02:00 — 차단 시간대이다 (경계 포함)', () {
      final time = DateTime(2024, 1, 1, 2, 0);
      expect(CurfewChecker.isBlockedTime(time), isTrue);
    });

    test('02:30 — 차단 시간대이다', () {
      final time = DateTime(2024, 1, 1, 2, 30);
      expect(CurfewChecker.isBlockedTime(time), isTrue);
    });

    test('07:59 — 차단 시간대이다 (상한 경계 직전)', () {
      final time = DateTime(2024, 1, 1, 7, 59);
      expect(CurfewChecker.isBlockedTime(time), isTrue);
    });

    test('08:00 — 차단 시간대가 아니다 (상한 경계 제외)', () {
      final time = DateTime(2024, 1, 1, 8, 0);
      expect(CurfewChecker.isBlockedTime(time), isFalse);
    });

    test('낮 12:00 — 차단 시간대가 아니다', () {
      final time = DateTime(2024, 1, 1, 12, 0);
      expect(CurfewChecker.isBlockedTime(time), isFalse);
    });

    test('자정 00:00 — 차단 시간대가 아니다', () {
      final time = DateTime(2024, 1, 1, 0, 0);
      expect(CurfewChecker.isBlockedTime(time), isFalse);
    });
  });
}
