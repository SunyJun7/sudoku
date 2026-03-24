# Batch 1 구현 완료 요약

> 완료일: 2026-03-24
> 담당 배치: 도메인 모델 + 검증 로직

---

## 구현 파일 목록

| # | 파일 | 역할 |
|---|------|------|
| 1 | `lib/domain/models/difficulty.dart` | Difficulty enum (easy, normal, hard) |
| 2 | `lib/domain/models/puzzle_data.dart` | PuzzleData (id, givens, solution) + fromJson/toJson |
| 3 | `lib/domain/models/cell_state.dart` | CellState (value, isGiven, isError) + copyWith/toJson/fromJson |
| 4 | `lib/domain/models/game_state.dart` | GameState (puzzle, board, selectedIndex, difficulty, isComplete) + copyWith/toJson/fromJson |
| 5 | `lib/domain/sudoku_validator.dart` | SudokuValidator (isCorrect, isComplete 정적 메서드) |
| 6 | `lib/domain/puzzle_repository.dart` | PuzzleRepository 추상 클래스 |
| 7 | `test/domain/sudoku_validator_test.dart` | SudokuValidator 유닛 테스트 (11개) |
| 8 | `test/domain/game_state_test.dart` | GameState + CellState 직렬화/copyWith 테스트 (14개) |
| 9 | `test/domain/puzzle_data_test.dart` | PuzzleData fromJson/toJson/equality 테스트 (10개) |

---

## 테스트 결과

```
flutter test test/domain/
35 tests passed, 0 failed
```

---

## 주요 설계 결정

### GameState.copyWith의 nullable selectedIndex 처리
`selectedIndex`는 `int?` 타입으로, `copyWith`에서 `null`로 명시적 설정과 "전달하지 않음(기존 값 유지)"을 구별해야 한다. 이를 위해 내부 sentinel 객체(`const Object _sentinel`)를 사용하여 두 경우를 구분했다.

### SudokuValidator.isComplete 검증 전략
`isError` 플래그 체크와 `solution` 직접 비교를 모두 수행한다. `isError`가 false라도 `solution`과 다를 수 있는 엣지 케이스를 방어한다.

### CellState.copyWith에서 isGiven 제외
`isGiven`은 힌트 여부로 게임 중 변경되지 않는 불변 속성이다. `copyWith` 시그니처에서 제외하여 실수로 변경하는 것을 방지한다.

---

## 다음 배치 (Batch 2) 사전 조건

- `lib/domain/` 전체 모델 사용 가능
- `PuzzleData.fromJson`으로 JSON 에셋 파싱 가능
- `GameState.toJson/fromJson`으로 SharedPreferences 저장/복원 가능
