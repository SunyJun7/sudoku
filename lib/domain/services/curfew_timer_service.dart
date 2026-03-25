import 'dart:async';

typedef VoidCallback = void Function();

/// 새벽 시각 타이머 서비스.
///
/// 두 가지 단발 타이머를 관리한다:
/// - 01:50: 종료 경고 알림
/// - 02:00: 강제 종료 알림
///
/// target 시각이 현재 시각보다 이미 지난 경우 다음날로 계산한다.
class CurfewTimerService {
  Timer? _warningTimer;
  Timer? _shutdownTimer;

  /// 타이머를 시작한다. 이미 실행 중이면 기존 타이머를 dispose 후 재시작한다.
  ///
  /// [now]가 null이면 DateTime.now()를 사용한다.
  void start({
    required VoidCallback onWarningTime,
    required VoidCallback onShutdownTime,
    DateTime? now,
  }) {
    dispose();

    final DateTime current = now ?? DateTime.now();

    final Duration? warningDelay = _durationUntil(
      hour: 1,
      minute: 50,
      from: current,
    );
    final Duration? shutdownDelay = _durationUntil(
      hour: 2,
      minute: 0,
      from: current,
    );

    // target이 이미 지난 경우 null이 반환되므로 타이머 설정 안 함
    if (warningDelay != null) {
      _warningTimer = Timer(warningDelay, onWarningTime);
    }
    if (shutdownDelay != null) {
      _shutdownTimer = Timer(shutdownDelay, onShutdownTime);
    }
  }

  /// 모든 타이머를 취소하고 리소스를 해제한다.
  void dispose() {
    _warningTimer?.cancel();
    _shutdownTimer?.cancel();
    _warningTimer = null;
    _shutdownTimer = null;
  }

  /// [from] 기준으로 오늘의 [hour]:[minute]까지 남은 Duration을 반환한다.
  ///
  /// target 시각이 이미 지났으면 다음날로 계산한다.
  /// target 시각이 현재와 동일하거나 이전이면 null을 반환한다.
  Duration? _durationUntil({
    required int hour,
    required int minute,
    required DateTime from,
  }) {
    // 오늘의 target 시각
    DateTime target = DateTime(
      from.year,
      from.month,
      from.day,
      hour,
      minute,
    );

    // target이 현재 시각과 같거나 이전이면 다음날로 이동
    if (!target.isAfter(from)) {
      target = target.add(const Duration(days: 1));
    }

    final Duration delay = target.difference(from);

    // 이론상 항상 양수지만 방어적으로 체크
    if (delay <= Duration.zero) return null;

    return delay;
  }
}
