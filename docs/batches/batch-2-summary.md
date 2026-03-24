# Batch 2 구현 완료 요약

> 완료일: 2026-03-24
> 담당 배치: 데이터 레이어 — 퍼즐 JSON 에셋 로드와 게임 상태 저장/복원

---

## 구현 파일 목록

| # | 파일 | 역할 |
|---|------|------|
| 1 | `assets/puzzles/easy.json` | 쉬움 퍼즐 20개 (givens 38개) |
| 2 | `assets/puzzles/normal.json` | 보통 퍼즐 20개 (givens 30개) |
| 3 | `assets/puzzles/hard.json` | 어려움 퍼즐 20개 (givens 24~26개) |
| 4 | `lib/data/local_puzzle_repository.dart` | LocalPuzzleRepository 구현 |
| 5 | `lib/data/game_storage_service.dart` | GameStorageService 구현 |
| 6 | `test/data/local_puzzle_repository_test.dart` | Repository 테스트 8개 |
| 7 | `test/data/game_storage_service_test.dart` | Storage 테스트 17개 |

---

## 테스트 결과

```
flutter test test/data/
25 tests passed, 0 failed
```

---

## 퍼즐 데이터 생성 방법

Python 백트래킹 솔버로 완전한 스도쿠 보드를 생성한 뒤, 유일해 검증(count_solutions == 1)을 통과한 셀만 제거하는 방식으로 퍼즐을 만들었다. 모든 퍼즐은 아래 조건을 만족한다.

- `solution`: 행/열/3x3박스에서 1~9 중복 없는 유효한 스도쿠
- `givens`: 0이 아닌 값은 모두 `solution`과 일치
- 유일해: 주어진 `givens`에서 `solution` 외의 정답이 없음

---

## 주요 설계 결정

### LocalPuzzleRepository AssetBundle 주입
`rootBundle`을 기본값으로 사용하고, 생성자에서 `AssetBundle?`을 받아 테스트 시 mock으로 교체할 수 있게 했다. flutter_test의 `CachingAssetBundle`을 상속한 `_MockAssetBundle`을 테스트에서 직접 구현하여 외부 mock 라이브러리 의존 없이 테스트한다.

### GameStorageService SharedPreferences 키 규약
- `"current_game"` — GameState JSON 문자열
- `"played_ids_easy"` / `"played_ids_normal"` / `"played_ids_hard"` — JSON 배열 (`List<String>`)

`Difficulty.name`을 활용하여 키를 동적 생성하므로 난이도가 추가되어도 코드 변경 없이 대응된다.

### savePlayedId 중복 방지
`getPlayedIds`로 기존 목록을 조회한 후 포함 여부를 확인하고 추가한다. 동일 ID를 두 번 저장해도 중복 없이 한 번만 저장된다.

---

## pubspec.yaml 변경 사항

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  shared_preferences: ^2.3.5

flutter:
  assets:
    - assets/puzzles/
```

---

## 다음 배치 (Batch 3) 사전 조건

- `LocalPuzzleRepository` 사용 가능 (생성자 주입으로 Provider에서 인스턴스 생성)
- `GameStorageService` 사용 가능 (SharedPreferences 기반 저장/복원)
- `assets/puzzles/` 에셋 등록 완료 — `LocalPuzzleRepository`가 런타임에 JSON 로드 가능
- `flutter_riverpod` 설치 완료 — Batch 3의 Provider 정의 즉시 가능
