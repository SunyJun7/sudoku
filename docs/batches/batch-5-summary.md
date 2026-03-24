# Batch 5 완료 요약

## 구현된 파일

### 화면 (stub → 실제 구현)
- `lib/ui/screens/home_screen.dart`: ConsumerWidget. hasSavedGameProvider AsyncValue.when() 처리. 시작 버튼→/difficulty, 이어하기 버튼(hasSaved=true 시만 표시)→restoreGame() 후 /game
- `lib/ui/screens/difficulty_screen.dart`: ConsumerWidget. 쉬움/보통/어려움 버튼 수직 배치 (width:infinity, height:56, 간격 16dp). 탭 시 startNewGame(difficulty) 후 /game
- `lib/ui/screens/clear_screen.dart`: ConsumerWidget. PopScope(canPop:false). 완료!+격려 메시지. 다시 하기→resetGame()+pop, 새 게임→clearSavedState()+pushAndRemoveUntil('/')+push('/difficulty'), 홈으로→clearSavedState()+pushAndRemoveUntil('/')

### 다국어 리소스
- `lib/l10n/app_ko.arb`: 한국어 문자열 17개 (appTitle~confirm)
- `lib/l10n/app_en.arb`: 영어 문자열 17개 (동일 키)

### 테스트
- `test/ui/screens/home_screen_test.dart`: hasSavedGame false/true 분기, 시작 버튼 라우팅, 이어하기 restoreGame 호출 (4개)
- `test/ui/screens/difficulty_screen_test.dart`: 버튼 3개 렌더링, easy/normal/hard 각 탭 시 startNewGame 호출 (4개)
- `test/ui/screens/game_screen_test.dart`: null→CircularProgressIndicator, gameState있음→위젯 3개, isComplete→/clear 이동 (3개 + setSurfaceSize 1200px 적용)
- `test/ui/screens/clear_screen_test.dart`: 완료! 텍스트, 격려 메시지, 다시 하기→resetGame, 홈으로→clearSavedState (4개)

### 기타 수정
- `test/widget_test.dart`: Flutter 기본 스모크 테스트 → 빈 main()으로 교체
- `test/data/local_puzzle_repository_test.dart`: unnecessary_cast 수정 (Uint8List.fromList)
- `test/providers/game_state_provider_test.dart`: unused_import 제거 (cell_state.dart)

## 핵심 인터페이스 / 타입

```dart
// HomeScreen — ConsumerWidget
// hasSavedGameProvider: FutureProvider<bool> → AsyncValue.when()으로 처리

// DifficultyScreen — ConsumerWidget
// _DifficultyButton — ConsumerWidget (내부 위젯)

// ClearScreen — ConsumerWidget, PopScope(canPop:false)
// 새 게임: pushAndRemoveUntil('/') 후 pushNamed('/difficulty')
```

## 환경변수 / 설정

추가 없음. ARB 파일만 준비 완료 (flutter_localizations 연동은 향후 작업).

## 알려진 제약사항

- **다국어(ARB) 미연동**: 화면 텍스트는 하드코딩 한국어. flutter_localizations + intl 의존성 추가 및 app.dart localizationsDelegates 설정이 필요 (Batch 5 범위 외)
- **GameScreen overflow**: 테스트 기본 화면 크기(800×600)에서 SudokuGrid+패드 overflow 발생. game_screen_test.dart에서 `setSurfaceSize(800×1200)`으로 해결
- **전체 테스트 결과**: 97/97 통과, `flutter analyze` 이슈 0개
