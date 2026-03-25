/// 새벽 시간대 차단 판별 유틸리티.
///
/// 차단 시간대: 02:00 이상 08:00 미만 (02:00 ~ 07:59)
class CurfewChecker {
  CurfewChecker._();

  /// 현재 시각이 차단 시간대인지 반환한다.
  ///
  /// [now]가 null이면 DateTime.now()를 사용한다.
  static bool isBlockedTime([DateTime? now]) {
    final DateTime current = now ?? DateTime.now();
    final int hour = current.hour;
    return hour >= 2 && hour < 8;
  }
}
