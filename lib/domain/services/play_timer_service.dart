import 'dart:async';

typedef VoidCallback = void Function();

/// 플레이 시간 타이머 서비스.
///
/// 3단계 알림 타이머를 관리한다:
/// - 60분: 휴식 시간 알림
/// - 110분: 종료 경고 알림
/// - 120분: 강제 종료 알림
class PlayTimerService {
  Timer? _restTimer;
  Timer? _warningTimer;
  Timer? _shutdownTimer;

  static const Duration _restDuration = Duration(minutes: 60);
  static const Duration _warningDuration = Duration(minutes: 110);
  static const Duration _shutdownDuration = Duration(minutes: 120);

  /// 타이머를 시작한다. 이미 실행 중이면 기존 타이머를 취소하고 재시작한다.
  void start({
    required VoidCallback onRestTime,
    required VoidCallback onWarningTime,
    required VoidCallback onShutdownTime,
  }) {
    stop();

    _restTimer = Timer(_restDuration, onRestTime);
    _warningTimer = Timer(_warningDuration, onWarningTime);
    _shutdownTimer = Timer(_shutdownDuration, onShutdownTime);
  }

  /// 모든 타이머를 취소한다.
  void stop() {
    _restTimer?.cancel();
    _warningTimer?.cancel();
    _shutdownTimer?.cancel();
    _restTimer = null;
    _warningTimer = null;
    _shutdownTimer = null;
  }

  /// 리소스를 명시적으로 해제한다.
  void dispose() => stop();
}
