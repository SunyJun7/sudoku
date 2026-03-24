# Batch 4 완료 요약

## 구현된 파일

### 위젯
- `lib/ui/widgets/sudoku_cell.dart`: 개별 셀 위젯. cellSize 외부 주입, isGiven/isError/selected/highlighted 상태별 색상 처리
- `lib/ui/widgets/sudoku_grid.dart`: 9x9 그리드. LayoutBuilder로 정사각형 셀 크기 계산, 3x3 박스 경계선 굵은선/얇은선 구분
- `lib/ui/widgets/number_pad.dart`: 1~9 + 지우기 버튼 10개, 2행 Wrap 레이아웃, isComplete 시 비활성화
- `lib/ui/widgets/game_control_bar.dart`: 다시 시작(확인 다이얼로그) + 새 게임(clearSavedState 후 /difficulty 이동)

### 화면
- `lib/ui/screens/game_screen.dart`: ConsumerStatefulWidget, WidgetsBindingObserver로 앱 백그라운드 진입 시 saveState, PopScope로 뒤로가기 시 상태 저장 후 / 이동, isComplete 감지 시 /clear 이동

### 테스트
- `test/ui/widgets/sudoku_grid_test.dart`: 셀 탭 selectCell 호출, 힌트 셀 탭 허용, 81개 렌더링, null 상태 처리
- `test/ui/widgets/number_pad_test.dart`: placeNumber/eraseNumber 호출, isComplete 시 비활성화 확인

## 핵심 인터페이스 / 타입

```dart
// SudokuCell — cellSize를 외부에서 주입받음 (SudokuGrid의 LayoutBuilder가 계산)
SudokuCell({
  required int index,
  required CellState cell,
  required double cellSize,   // ← LayoutBuilder 기반 계산값
  required bool isSelected,
  required bool isHighlighted,
  required VoidCallback onTap,
})

// SudokuGrid — ConsumerWidget, gameStateProvider watch
// NumberPad — ConsumerWidget, gameStateProvider watch
// GameControlBar — ConsumerWidget, gameStateProvider read
// GameScreen — ConsumerStatefulWidget
```

## 설계 결정 사항

- **그리드 크기 계산**: `min(maxWidth, maxHeight)` 기반 정사각형 → 테두리 14dp 공제 후 /9
  - 내부 테두리 합계: 굵은선 2개×2dp=4 + 얇은선 6개×1dp=6 + 외곽 border 4dp = 14dp
- **테스트에서 Notifier 상태**: `build()` 반환값으로 초기 상태 설정 (빌드 후 `state=` 직접 할당은 `_element` 미초기화 오류 발생)
- **PopScope**: `WillPopScope` 대신 Flutter 3.22+ `PopScope` + `onPopInvokedWithResult` 사용

## 알려진 제약사항

- `test/widget_test.dart`: Flutter 기본 생성 scaffold 파일. `MyApp` → `SudokuApp`으로 변경된 이전 배치 영향으로 lint error 존재 (Batch 4 범위 외)
- `test/data/local_puzzle_repository_test.dart`: unnecessary_cast warning (이전 배치)
- `test/providers/game_state_provider_test.dart`: unused_import warning (이전 배치)
- 다음 배치에서 `/clear`, `/difficulty`, `/` 라우트가 실제로 구현되어야 GameScreen 전체 플로우 동작
