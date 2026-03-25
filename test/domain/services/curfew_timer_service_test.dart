import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/services/curfew_timer_service.dart';

void main() {
  group('CurfewTimerService', () {
    late CurfewTimerService service;

    setUp(() {
      service = CurfewTimerService();
    });

    tearDown(() {
      service.dispose();
    });

    test('낮 13:00 기준 — 익일 01:50까지 올바른 duration으로 warning 타이머가 발동된다', () {
      fakeAsync((async) {
        // 2024-01-01 13:00:00
        final now = DateTime(2024, 1, 1, 13, 0, 0);
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
          now: now,
        );

        // 13:00 → 익일 01:50 = 12시간 50분
        final expectedWarningDelay = const Duration(hours: 12, minutes: 50);

        // 아직 미발동
        async.elapse(expectedWarningDelay - const Duration(seconds: 1));
        expect(warningCalled, isFalse);

        // 정확히 만료 시각에 발동
        async.elapse(const Duration(seconds: 1));
        expect(warningCalled, isTrue);
        expect(shutdownCalled, isFalse);
      });
    });

    test('낮 13:00 기준 — 익일 02:00까지 올바른 duration으로 shutdown 타이머가 발동된다', () {
      fakeAsync((async) {
        final now = DateTime(2024, 1, 1, 13, 0, 0);
        bool shutdownCalled = false;

        service.start(
          onWarningTime: () {},
          onShutdownTime: () => shutdownCalled = true,
          now: now,
        );

        // 13:00 → 익일 02:00 = 13시간
        async.elapse(const Duration(hours: 13));
        expect(shutdownCalled, isTrue);
      });
    });

    test('새벽 01:55 기준 — 01:50 타이머는 skip되고 02:00까지 5분 타이머가 설정된다', () {
      fakeAsync((async) {
        // 01:50은 이미 지났으므로 warning은 다음날로 넘어감
        final now = DateTime(2024, 1, 1, 1, 55, 0);
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
          now: now,
        );

        // 5분 후 shutdown 발동 (02:00)
        async.elapse(const Duration(minutes: 5));
        expect(shutdownCalled, isTrue);

        // warning은 이번 사이클에서 발동하지 않음 (다음날 01:50)
        expect(warningCalled, isFalse);
      });
    });

    test('새벽 01:55 기준 — warning 타이머는 익일 01:50에 발동된다', () {
      fakeAsync((async) {
        final now = DateTime(2024, 1, 1, 1, 55, 0);
        bool warningCalled = false;

        service.start(
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () {},
          now: now,
        );

        // 01:55 → 익일 01:50 = 23시간 55분
        async.elapse(const Duration(hours: 23, minutes: 55));
        expect(warningCalled, isTrue);
      });
    });

    test('새벽 02:05 기준 — 두 타이머 모두 이번 사이클에서는 설정되지 않는다 (다음날)', () {
      fakeAsync((async) {
        // 01:50, 02:00 모두 이미 지남 → 둘 다 다음날로
        final now = DateTime(2024, 1, 1, 2, 5, 0);
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
          now: now,
        );

        // 단기간에는 어떤 타이머도 발동하지 않음
        async.elapse(const Duration(hours: 1));
        expect(warningCalled, isFalse);
        expect(shutdownCalled, isFalse);
      });
    });

    test('새벽 02:05 기준 — warning 타이머는 익일 01:50에, shutdown은 익일 02:00에 발동된다', () {
      fakeAsync((async) {
        final now = DateTime(2024, 1, 1, 2, 5, 0);
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
          now: now,
        );

        // 02:05 → 익일 01:50 = 23시간 45분
        async.elapse(const Duration(hours: 23, minutes: 45));
        expect(warningCalled, isTrue);
        expect(shutdownCalled, isFalse);

        // 추가 10분 후 → 익일 02:00
        async.elapse(const Duration(minutes: 10));
        expect(shutdownCalled, isTrue);
      });
    });

    test('dispose() 후에는 타이머가 발동하지 않는다', () {
      fakeAsync((async) {
        final now = DateTime(2024, 1, 1, 1, 45, 0);
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
          now: now,
        );

        async.elapse(const Duration(minutes: 3));
        service.dispose();

        // dispose 후 충분한 시간이 흘러도 발동 없음
        async.elapse(const Duration(hours: 1));
        expect(warningCalled, isFalse);
        expect(shutdownCalled, isFalse);
      });
    });
  });
}
