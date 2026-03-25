# Review: Batch A (도메인 서비스 계층) — 승인 ✅

**날짜:** 2026-03-25
**반려 이력:** 0회

## 카테고리별 결과

| 카테고리 | 결과 |
|---|---|
| Blueprint 일치 | ✅ |
| 코드 정확성 | ✅ |
| 효율성 | ✅ |
| 보안 | ✅ |
| 코드 품질 | ⚠️ |

## 강점

- `lib/domain/services/curfew_timer_service.dart:60-85` — `_durationUntil()` 날짜 경계 처리가 깔끔. `!target.isAfter(from)` → `add(1 day)` → 방어적 zero 체크 순서 명확
- `lib/domain/services/curfew_checker.dart:5` — `CurfewChecker._()` private 생성자로 인스턴스화 방지. 정적 유틸리티 패턴 정석
- `test/domain/services/play_timer_service_test.dart:99-125` — 중복 start() 테스트에서 firstRestCount/secondRestCount 카운터로 콜백 발동 여부를 명확히 구분
- 테스트 19/19 전체 통과. fake_async 사용으로 실시간 대기 없이 타이머 검증

## Critical

없음

## Important

없음

## Minor

- `lib/domain/services/play_timer_service.dart:3` / `lib/domain/services/curfew_timer_service.dart:3` — `typedef VoidCallback = void Function();` 두 파일에 중복 정의. 런타임 문제는 없으나 관리 부담. 공용 파일 추출 또는 `dart:ui` VoidCallback import 권장
- `lib/domain/services/curfew_timer_service.dart:61` — 주석 "이전이면 null을 반환한다"와 실제 코드(항상 1일 추가 후 양수 반환) 불일치. dead code path + 오해 유발

## 최종 판정

**결과:** 승인
**근거:** 3개 서비스 클래스 모두 Blueprint 구조와 일치하고, 날짜 경계 케이스·경계값 테스트를 포함한 19개 테스트가 전부 통과. Critical/Important 이슈 없음. Minor 2건은 다음 배치 진행 중 병행 수정 가능.
