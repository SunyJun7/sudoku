import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/services/play_timer_service.dart';

void main() {
  group('PlayTimerService', () {
    late PlayTimerService service;

    setUp(() {
      service = PlayTimerService();
    });

    tearDown(() {
      service.dispose();
    });

    test('start() 후 60분에 onRestTime 콜백이 발동된다', () {
      fakeAsync((async) {
        bool restCalled = false;
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onRestTime: () => restCalled = true,
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
        );

        async.elapse(const Duration(minutes: 60));

        expect(restCalled, isTrue);
        expect(warningCalled, isFalse);
        expect(shutdownCalled, isFalse);
      });
    });

    test('start() 후 110분에 onWarningTime 콜백이 발동된다', () {
      fakeAsync((async) {
        bool restCalled = false;
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onRestTime: () => restCalled = true,
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
        );

        async.elapse(const Duration(minutes: 110));

        expect(restCalled, isTrue);
        expect(warningCalled, isTrue);
        expect(shutdownCalled, isFalse);
      });
    });

    test('start() 후 120분에 onShutdownTime 콜백이 발동된다', () {
      fakeAsync((async) {
        bool restCalled = false;
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onRestTime: () => restCalled = true,
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
        );

        async.elapse(const Duration(minutes: 120));

        expect(restCalled, isTrue);
        expect(warningCalled, isTrue);
        expect(shutdownCalled, isTrue);
      });
    });

    test('stop() 후에는 모든 타이머가 발동하지 않는다', () {
      fakeAsync((async) {
        bool restCalled = false;
        bool warningCalled = false;
        bool shutdownCalled = false;

        service.start(
          onRestTime: () => restCalled = true,
          onWarningTime: () => warningCalled = true,
          onShutdownTime: () => shutdownCalled = true,
        );

        async.elapse(const Duration(minutes: 30));
        service.stop();
        async.elapse(const Duration(minutes: 120));

        expect(restCalled, isFalse);
        expect(warningCalled, isFalse);
        expect(shutdownCalled, isFalse);
      });
    });

    test('start() 중복 호출 시 이전 타이머가 취소되고 새 타이머가 시작된다', () {
      fakeAsync((async) {
        // 첫 번째 start()
        int firstRestCount = 0;
        service.start(
          onRestTime: () => firstRestCount++,
          onWarningTime: () {},
          onShutdownTime: () {},
        );

        async.elapse(const Duration(minutes: 30));

        // 두 번째 start() — 기존 타이머 취소 후 재시작
        int secondRestCount = 0;
        service.start(
          onRestTime: () => secondRestCount++,
          onWarningTime: () {},
          onShutdownTime: () {},
        );

        // 첫 번째 타이머의 원래 만료 시각(start 후 60분)을 넘겨도 첫 번째 콜백 미발동
        async.elapse(const Duration(minutes: 60));

        expect(firstRestCount, 0, reason: '이전 타이머 콜백은 발동하지 않아야 한다');
        expect(secondRestCount, 1, reason: '새 타이머 콜백은 발동해야 한다');
      });
    });
  });
}
