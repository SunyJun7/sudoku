# 아키텍처 설계 문서 - 스도쿠 앱

> 작성일: 2026-03-24
> 기반 문서: `docs/requirements.md`

---

## 기술 스택

| 항목 | 선택 | 버전 | 선택 이유 |
|------|------|------|----------|
| 언어 | Dart | 3.x (Flutter SDK 동봉) | Flutter 공식 언어, 타입 안전성 |
| 프레임워크 | Flutter | 3.27 stable | Android/iOS 단일 코드베이스, 위젯 기반 UI |
| 상태 관리 | flutter_riverpod | 2.x | Provider 대비 테스트 용이, 컴파일 타임 안전성, Notifier 패턴으로 게임 상태 관리에 적합 |
| 로컬 저장 | shared_preferences | 2.x | 게임 상태 JSON 직렬화 저장, 단순한 key-value로 충분 |
| 다국어 | flutter_localizations + intl | 공식 | ARB 파일 기반 다국어, Flutter 공식 지원 |
| 테스트 | flutter_test (내장) | - | 위젯 테스트 + 유닛 테스트 |
| 린트 | flutter_lints | - | 코드 일관성 |

**대안 비교 - 상태 관리:**

| 후보 | 장점 | 단점 | 결론 |
|------|------|------|------|
| Provider | 단순, 학습 곡선 낮음 | 타입 안전성 부족, 테스트 시 ProviderScope 설정 번거로움 | 탈락 |
| Riverpod | 컴파일 타임 안전성, 테스트 용이, Provider 의존 제거 | Provider 대비 약간의 학습 곡선 | **채택** |
| Bloc | 대규모 앱에 적합 | 보일러플레이트 과다, 소규모 앱에 과도한 설계 | 탈락 |

**대안 비교 - 로컬 저장:**

| 후보 | 장점 | 단점 | 결론 |
|------|------|------|------|
| SharedPreferences | 단순, 의존성 최소 | 복잡한 쿼리 불가 | **채택** (게임 상태 1건 저장으로 충분) |
| Hive | 빠른 NoSQL | 이 규모에 과도한 의존성 | 탈락 |
| SQLite (sqflite) | 관계형 쿼리 | 랭킹/통계 없으므로 불필요 | 탈락 |

---

## 시스템 구조

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                   │
│                                                       │
│  HomeScreen    DifficultyScreen   GameScreen   ClearScreen │
│       │              │                │            │  │
│       └──────────────┴────────┬───────┴────────────┘  │
│                               │ watch/read providers  │
├───────────────────────────────┼───────────────────────┤
│                  Application Layer (Riverpod)          │
│                               │                       │
│  gameStateProvider ◄──── GameStateNotifier             │
│  puzzleRepositoryProvider                              │
│  savedGameProvider                                     │
├───────────────────────────────┼───────────────────────┤
│                  Domain Layer                          │
│                               │                       │
│  PuzzleData    CellState    Difficulty(enum)          │
│  SudokuValidator             GameState                │
│  PuzzleRepository (abstract)                          │
├───────────────────────────────┼───────────────────────┤
│                  Data Layer                            │
│                               │                       │
│  LocalPuzzleRepository ──► assets/puzzles/*.json      │
│  GameStorageService    ──► SharedPreferences           │
└───────────────────────────────────────────────────────┘
```

**데이터 흐름:**

```
사용자 탭 → Widget → ref.read(gameStateProvider.notifier).placeNumber(index, value)
                                    │
                                    ▼
                          GameStateNotifier
                            ├── SudokuValidator.isCorrect(index, value) → 오류 여부 판단
                            ├── state = state.copyWith(board 갱신)
                            ├── SudokuValidator.isComplete(board) → 클리어 감지
                            └── GameStorageService.save(state) → SharedPreferences 저장
                                    │
                                    ▼ (state 변경 → 자동 리빌드)
                          Widget 갱신 (오류 색상, 클리어 화면 전환)
```

---

## 폴더 구조

```
lib/
├── main.dart                          # 앱 진입점, ProviderScope 래핑
├── app.dart                           # MaterialApp, 라우팅, 테마 정의
│
├── domain/                            # 도메인 모델 및 인터페이스
│   ├── models/
│   │   ├── puzzle_data.dart           # PuzzleData (id, givens, solution)
│   │   ├── cell_state.dart            # CellState (value, isGiven, isError)
│   │   ├── game_state.dart            # GameState (board, selectedIndex, difficulty, isComplete)
│   │   └── difficulty.dart            # Difficulty enum (easy, normal, hard)
│   ├── puzzle_repository.dart         # PuzzleRepository 추상 클래스
│   └── sudoku_validator.dart          # 정답 검증 로직
│
├── data/                              # 데이터 레이어 구현체
│   ├── local_puzzle_repository.dart   # LocalPuzzleRepository (JSON 에셋 로드)
│   └── game_storage_service.dart      # SharedPreferences 저장/복원
│
├── providers/                         # Riverpod Provider 정의
│   ├── puzzle_repository_provider.dart
│   ├── game_state_provider.dart       # GameStateNotifier + gameStateProvider
│   └── game_storage_provider.dart
│
├── ui/                                # 화면 및 위젯
│   ├── screens/
│   │   ├── home_screen.dart           # 홈 화면 (앱 제목 + 시작/이어하기)
│   │   ├── difficulty_screen.dart     # 난이도 선택 화면
│   │   ├── game_screen.dart           # 게임 플레이 화면
│   │   └── clear_screen.dart          # 클리어 화면
│   ├── widgets/
│   │   ├── sudoku_grid.dart           # 9x9 그리드 위젯
│   │   ├── sudoku_cell.dart           # 개별 셀 위젯
│   │   ├── number_pad.dart            # 1~9 + 지우기 버튼
│   │   └── game_control_bar.dart      # 다시시작/새게임 버튼
│   └── theme/
│       └── app_theme.dart             # 시니어 친화 테마 (폰트 크기, 색상)
│
└── l10n/                              # 다국어 리소스
    ├── app_ko.arb                     # 한국어 (기본)
    └── app_en.arb                     # 영어 (구조만 준비)

assets/
└── puzzles/
    ├── easy.json                      # 쉬움 퍼즐 20개+
    ├── normal.json                    # 보통 퍼즐 20개+
    └── hard.json                      # 어려움 퍼즐 20개+

test/
├── domain/
│   ├── sudoku_validator_test.dart
│   ├── puzzle_data_test.dart
│   └── game_state_test.dart
├── data/
│   ├── local_puzzle_repository_test.dart
│   └── game_storage_service_test.dart
├── providers/
│   └── game_state_provider_test.dart
└── ui/
    ├── widgets/
    │   ├── sudoku_grid_test.dart
    │   └── number_pad_test.dart
    └── screens/
        ├── home_screen_test.dart
        ├── difficulty_screen_test.dart
        ├── game_screen_test.dart
        └── clear_screen_test.dart
```

---

## 데이터 모델

### Difficulty (enum)

```dart
enum Difficulty { easy, normal, hard }
```

### PuzzleData

```dart
class PuzzleData {
  final String id;           // 퍼즐 고유 식별자 (예: "easy_001")
  final List<int> givens;    // 81개 정수, 0 = 빈 칸, 1~9 = 힌트 숫자
  final List<int> solution;  // 81개 정수, 완성된 정답

  // JSON 직렬화/역직렬화
  factory PuzzleData.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**JSON 포맷 (assets/puzzles/easy.json):**

```json
{
  "puzzles": [
    {
      "id": "easy_001",
      "givens": [5,3,0,0,7,0,0,0,0, 6,0,0,1,9,5,0,0,0, ...],
      "solution": [5,3,4,6,7,8,9,1,2, 6,7,2,1,9,5,3,4,8, ...]
    }
  ]
}
```

### CellState

```dart
class CellState {
  final int value;       // 0 = 빈 칸, 1~9 = 숫자
  final bool isGiven;    // true = 힌트 (수정 불가)
  final bool isError;    // true = 정답과 불일치

  CellState copyWith({int? value, bool? isError});
}
```

### GameState

```dart
class GameState {
  final PuzzleData puzzle;
  final List<CellState> board;  // 81칸 현재 상태
  final int? selectedIndex;     // 현재 선택된 셀 (0~80, null = 미선택)
  final Difficulty difficulty;
  final bool isComplete;        // 모든 칸 정답 여부

  GameState copyWith({...});

  // SharedPreferences 저장/복원용 직렬화
  Map<String, dynamic> toJson();
  factory GameState.fromJson(Map<String, dynamic> json);
}
```

### PuzzleRepository (추상)

```dart
abstract class PuzzleRepository {
  /// 해당 난이도에서 excludeIds를 제외한 퍼즐 1개를 랜덤 반환.
  /// 모두 소진 시 excludeIds 무시하고 랜덤 반환.
  Future<PuzzleData> getPuzzle(Difficulty difficulty, {List<String> excludeIds = const []});
}
```

### SudokuValidator

```dart
class SudokuValidator {
  /// 특정 인덱스의 사용자 입력이 정답과 일치하는지 확인
  static bool isCorrect(PuzzleData puzzle, int index, int value);

  /// 보드가 완성 상태인지 확인 (모든 칸이 채워지고 모두 정답)
  static bool isComplete(PuzzleData puzzle, List<CellState> board);
}
```

---

## 화면 흐름 및 라우팅

```
'/'           → HomeScreen
'/difficulty' → DifficultyScreen
'/game'       → GameScreen
'/clear'      → ClearScreen
```

Flutter의 `Navigator 2.0` 대신 단순한 `Navigator.pushNamed` / `Navigator.pushReplacementNamed`를 사용한다.
이유: 화면 수가 4개로 적고, 딥링크/웹 라우팅이 불필요하여 선언적 라우팅은 과도한 설계이다.

| 화면 전환 | 방식 | 비고 |
|----------|------|------|
| Home → Difficulty | push | 뒤로가기 시 Home 복귀 |
| Difficulty → Game | pushReplacement | 난이도 선택 후 뒤로가기 시 Home으로 (중간 화면 스킵) |
| Game → Clear | push | 클리어 화면에서 뒤로 가면 안됨 → WillPopScope로 차단 |
| Clear → Difficulty | pushAndRemoveUntil('/') 후 push('/difficulty') | 스택 정리 |
| Clear → Home | pushAndRemoveUntil('/') | 스택 정리 |
| Home (이어하기) → Game | pushReplacement | 저장된 상태 복원 |

---

## Riverpod Provider 설계

```dart
// 1. PuzzleRepository 인스턴스 제공
final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  return LocalPuzzleRepository();
});

// 2. GameStorage 인스턴스 제공
final gameStorageProvider = Provider<GameStorageService>((ref) {
  return GameStorageService();
});

// 3. 저장된 게임 존재 여부 (HomeScreen에서 "이어하기" 버튼 표시용)
final hasSavedGameProvider = FutureProvider<bool>((ref) async {
  final storage = ref.read(gameStorageProvider);
  return storage.hasSavedGame();
});

// 4. 핵심 게임 상태 (NotifierProvider — Riverpod 2.x 표준)
final gameStateProvider = NotifierProvider<GameStateNotifier, GameState?>(() {
  return GameStateNotifier();
});
```

### GameStorageService 메서드 (전체)

```dart
class GameStorageService {
  /// 현재 진행 중인 게임 저장
  Future<void> saveGame(GameState state);

  /// 저장된 게임 복원 (없으면 null 반환)
  Future<GameState?> loadGame();

  /// 저장된 게임 삭제
  Future<void> clearGame();

  /// 저장된 게임 존재 여부
  Future<bool> hasSavedGame();

  /// 플레이 완료한 퍼즐 ID 목록 조회
  Future<List<String>> getPlayedIds(Difficulty difficulty);

  /// 플레이 완료한 퍼즐 ID 추가
  Future<void> savePlayedId(Difficulty difficulty, String puzzleId);

  /// 플레이 ID 목록 초기화 (소진 시 반복 출제를 위해 내부적으로 호출)
  Future<void> clearPlayedIds(Difficulty difficulty);
}
```

**SharedPreferences 키 규약:**
- 현재 게임: `"current_game"` (GameState JSON 문자열)
- 난이도별 플레이 ID: `"played_ids_easy"`, `"played_ids_normal"`, `"played_ids_hard"` (JSON 배열)

---

### GameStateNotifier 주요 메서드

```dart
class GameStateNotifier extends Notifier<GameState?> {
  /// Riverpod 2.x: build()가 초기 상태를 반환 (null = 게임 미시작)
  @override
  GameState? build() => null;

  // ref.read(puzzleRepositoryProvider), ref.read(gameStorageProvider) 로 접근

  /// 새 게임 시작
  Future<void> startNewGame(Difficulty difficulty);

  /// 저장된 게임 복원
  Future<void> restoreGame();

  /// 셀 선택
  void selectCell(int index);

  /// 숫자 입력 (오류 검증 포함)
  void placeNumber(int value);

  /// 숫자 지우기
  void eraseNumber();

  /// 게임 재시작 (사용자 입력만 초기화)
  void resetGame();

  /// 상태 저장 (앱 라이프사이클에서 호출)
  Future<void> saveState();

  /// 저장 상태 삭제
  Future<void> clearSavedState();
}
```

---

## 시니어 친화 UI 설계 가이드

### 크기 기준

| 요소 | 최소 크기 | 권장 크기 |
|------|----------|----------|
| 스도쿠 셀 | 44dp x 44dp | 화면 너비 / 9 (약 40~44dp, 패딩 포함) |
| 숫자 패드 버튼 | 48dp x 48dp | 56dp x 56dp |
| 셀 내 숫자 | 18sp | 20sp |
| 숫자 패드 숫자 | 24sp | 28sp |
| 일반 버튼 텍스트 | 18sp | 20sp |
| 화면 제목 | 24sp | 28sp |

### 색상 팔레트

| 용도 | 색상 | Hex | 비고 |
|------|------|-----|------|
| 배경 | 밝은 흰색 | #FAFAFA | 눈 피로 최소화 |
| 힌트 숫자 | 검정 | #212121 | 고대비 |
| 사용자 입력 숫자 | 남색 | #1565C0 | 힌트와 구분 |
| 오류 셀 배경 | 연한 빨강 | #FFCDD2 | 강렬하지 않되 명확히 구분 |
| 오류 숫자 | 빨강 | #D32F2F | |
| 선택 셀 배경 | 연한 파랑 | #BBDEFB | |
| 같은 행/열/박스 하이라이트 | 매우 연한 파랑 | #E3F2FD | |
| 3x3 박스 구분선 | 진한 회색 | #424242 | 2dp 두께 |
| 일반 그리드 선 | 연한 회색 | #BDBDBD | 1dp 두께 |
| 주요 버튼 | 파랑 | #1976D2 | |
| 주요 버튼 텍스트 | 흰색 | #FFFFFF | |

### 레이아웃 (GameScreen)

```
┌──────────────────────────────┐
│  [< 뒤로] 스도쿠 - 쉬움       │  AppBar (56dp)
├──────────────────────────────┤
│                              │
│    ┌───┬───┬───┬───┬...─┐   │
│    │ 5 │ 3 │   │   │    │   │  9x9 Grid
│    ├───┼───┼───┼───┼    │   │  (화면 너비 - 32dp 패딩)
│    │   │   │   │   │    │   │
│    │   ...                   │
│    └───┴───┴───┴───┴...─┘   │
│                              │
│  ┌───────────────────────┐   │
│  │  1  2  3  4  5        │   │  NumberPad
│  │  6  7  8  9  지우기    │   │  (2행 5열 배치)
│  └───────────────────────┘   │
│                              │
│  [  다시 시작  ] [ 새 게임 ]   │  GameControlBar
│                              │
└──────────────────────────────┘
```

---

## 구현 순서 (배치 계획)

### Batch 1: 도메인 모델 + 검증 로직 (의존 배치: 없음)

순수 Dart 코드만으로 구성. Flutter 의존 없이 `dart test`로 검증 가능.

| # | 파일 | 역할 |
|---|------|------|
| 1 | `lib/domain/models/difficulty.dart` | Difficulty enum 정의 |
| 2 | `lib/domain/models/puzzle_data.dart` | PuzzleData 모델 (fromJson/toJson 포함) |
| 3 | `lib/domain/models/cell_state.dart` | CellState 모델 |
| 4 | `lib/domain/models/game_state.dart` | GameState 모델 (toJson/fromJson 포함) |
| 5 | `lib/domain/sudoku_validator.dart` | isCorrect, isComplete 정적 메서드 |
| 6 | `lib/domain/puzzle_repository.dart` | PuzzleRepository 추상 클래스 |
| 7 | `test/domain/sudoku_validator_test.dart` | Validator 유닛 테스트 |
| 8 | `test/domain/game_state_test.dart` | GameState 직렬화/역직렬화 + CellState 테스트 |
| 9 | `test/domain/puzzle_data_test.dart` | PuzzleData fromJson/toJson 테스트 |

**파일 수: 9개**
**완료 기준:** `flutter test test/domain/` 명령으로 모든 테스트 통과. 모델 클래스 인스턴스 생성, JSON 직렬화 왕복, 검증 로직 정상 동작 확인.

---

### Batch 2: 데이터 레이어 (의존 배치: Batch 1)

퍼즐 JSON 에셋 로드와 게임 상태 저장/복원 구현.

| # | 파일 | 역할 |
|---|------|------|
| 1 | `assets/puzzles/easy.json` | 쉬움 퍼즐 데이터 20개 |
| 2 | `assets/puzzles/normal.json` | 보통 퍼즐 데이터 20개 |
| 3 | `assets/puzzles/hard.json` | 어려움 퍼즐 데이터 20개 |
| 4 | `lib/data/local_puzzle_repository.dart` | LocalPuzzleRepository 구현 (에셋 JSON 로드, 랜덤 선택, 소진 시 반복) |
| 5 | `lib/data/game_storage_service.dart` | GameStorageService (SharedPreferences 저장/복원/삭제/존재확인) |
| 6 | `test/data/local_puzzle_repository_test.dart` | Repository 테스트 (mock AssetBundle 사용) |
| 7 | `test/data/game_storage_service_test.dart` | Storage 테스트 (SharedPreferences mock) |

**파일 수: 7개**
**완료 기준:** `flutter test test/data/` 명령으로 모든 테스트 통과. JSON 파일이 올바른 형식이고 파싱 가능. Repository가 난이도별 퍼즐을 반환하고, StorageService가 GameState를 저장/복원할 수 있음.

---

### Batch 3: 상태 관리 + 앱 셸 (의존 배치: Batch 1, Batch 2)

Riverpod Provider 구성 및 앱 기본 골격. 화면은 빈 Scaffold로 라우팅만 확인.

| # | 파일 | 역할 |
|---|------|------|
| 1 | `lib/providers/puzzle_repository_provider.dart` | puzzleRepositoryProvider 정의 |
| 2 | `lib/providers/game_storage_provider.dart` | gameStorageProvider, hasSavedGameProvider 정의 |
| 3 | `lib/providers/game_state_provider.dart` | GameStateNotifier + gameStateProvider 정의 |
| 4 | `lib/app.dart` | MaterialApp, 라우팅 테이블, 테마 설정 |
| 5 | `lib/main.dart` | ProviderScope 래핑, runApp |
| 6 | `lib/ui/theme/app_theme.dart` | 시니어 친화 ThemeData 정의 |
| 7 | `test/providers/game_state_provider_test.dart` | GameStateNotifier 유닛 테스트 (startNewGame, placeNumber, eraseNumber, resetGame, 클리어 감지) |

**파일 수: 7개**
**완료 기준:** `flutter test test/providers/` 통과. `flutter run`으로 앱 실행 시 빈 화면이라도 크래시 없이 기동됨. GameStateNotifier의 모든 핵심 메서드가 테스트로 검증됨.

---

### Batch 4: 게임 화면 위젯 (의존 배치: Batch 3)

핵심 게임 플레이 UI 구현. 이 배치 완료 후 실제 스도쿠 플레이가 가능.

| # | 파일 | 역할 |
|---|------|------|
| 1 | `lib/ui/widgets/sudoku_cell.dart` | 개별 셀 위젯 (힌트/사용자입력/오류/선택 상태 표현) |
| 2 | `lib/ui/widgets/sudoku_grid.dart` | 9x9 그리드 위젯 (3x3 박스 구분선 포함) |
| 3 | `lib/ui/widgets/number_pad.dart` | 1~9 + 지우기 버튼 패드 |
| 4 | `lib/ui/widgets/game_control_bar.dart` | 다시시작/새게임 버튼 바 |
| 5 | `lib/ui/screens/game_screen.dart` | GameScreen (Grid + NumberPad + ControlBar 조합) |
| 6 | `test/ui/widgets/sudoku_grid_test.dart` | 그리드 위젯 테스트 (셀 탭, 힌트 셀 탭 무시) |
| 7 | `test/ui/widgets/number_pad_test.dart` | 넘버패드 위젯 테스트 (버튼 탭 콜백) |

**파일 수: 7개**
**완료 기준:** `flutter test test/ui/widgets/` 통과. `flutter run` 후 난이도를 하드코딩하여 GameScreen 진입 시 9x9 그리드 표시, 셀 탭으로 선택, 숫자 입력, 오류 색상 표시, 지우기, 다시시작이 동작함.

---

### Batch 5: 나머지 화면 + 다국어 + 마무리 (의존 배치: Batch 4)

홈, 난이도 선택, 클리어 화면 구현. 다국어 리소스 분리. 전체 화면 흐름 완성.

| # | 파일 | 역할 |
|---|------|------|
| 1 | `lib/ui/screens/home_screen.dart` | 홈 화면 (시작/이어하기 버튼) |
| 2 | `lib/ui/screens/difficulty_screen.dart` | 난이도 선택 화면 (쉬움/보통/어려움) |
| 3 | `lib/ui/screens/clear_screen.dart` | 클리어 화면 (완료 메시지 + 다시하기/새게임) |
| 4 | `lib/l10n/app_ko.arb` | 한국어 문자열 리소스 |
| 5 | `lib/l10n/app_en.arb` | 영어 문자열 리소스 (구조 준비) |
| 6 | `test/ui/screens/home_screen_test.dart` | 홈 화면 테스트 (이어하기 버튼 조건부 표시) |
| 7 | `test/ui/screens/difficulty_screen_test.dart` | 난이도 선택 화면 테스트 (버튼 탭 → 게임 시작) |
| 8 | `test/ui/screens/game_screen_test.dart` | 게임 화면 통합 테스트 (플레이 시나리오) |
| 9 | `test/ui/screens/clear_screen_test.dart` | 클리어 화면 테스트 (버튼 동작) |

**파일 수: 9개**
**완료 기준:** `flutter test` (전체 테스트) 통과. `flutter run`으로 전체 화면 흐름 동작: 홈 → 난이도 선택 → 게임 플레이 → 클리어 → 홈 복귀. 모든 UI 텍스트가 ARB 파일에서 로드됨. 앱 종료 후 재실행 시 "이어하기"로 게임 복원 동작.

---

## 배치 의존성 다이어그램

```
Batch 1 (도메인 모델)
    │
    ▼
Batch 2 (데이터 레이어)
    │
    ▼
Batch 3 (상태 관리 + 앱 셸)
    │
    ▼
Batch 4 (게임 화면 위젯)
    │
    ▼
Batch 5 (나머지 화면 + 다국어)
```

---

## 주요 결정사항 및 트레이드오프

### 1. 실시간 정답 검증 방식 선택

**결정:** solution 배열과 직접 비교하는 단순 검증 방식 채택.

| 방식 | 장점 | 단점 |
|------|------|------|
| 행/열/박스 규칙 검증 | 스도쿠 규칙에 충실 | 유효하지만 정답이 아닌 값을 허용할 수 있음 |
| **solution 직접 비교** | 구현 단순, 오답 즉시 감지 | solution 데이터 필수 |

채택 이유: 시니어 사용자에게는 "틀린 숫자를 즉시 알려주는 것"이 핵심 가치(FR-004). 규칙 기반 검증은 같은 행에 중복이 없더라도 최종 정답이 아닌 경우를 허용하여 혼란을 줄 수 있다. solution 데이터는 어차피 퍼즐 생성 시 확보되므로 추가 비용이 없다.

### 2. 퍼즐 데이터 포맷: 81개 정수 배열

**결정:** 9x9 2차원 배열 대신 81개 1차원 배열 사용.

이유: `index ~/ 9`로 행, `index % 9`로 열, `(index ~/ 27) * 3 + (index % 9) ~/ 3`으로 박스를 계산할 수 있어 별도 변환 없이 flat index로 모든 연산이 가능하다. JSON 크기도 더 작고, `List<CellState>` board와 인덱스가 1:1 매핑되어 코드가 단순해진다.

### 3. Navigator 1.0 (명령형 라우팅) 사용

**결정:** go_router 등 선언적 라우팅 패키지를 사용하지 않음.

이유: 화면 4개, 딥링크 불필요, 웹 지원 불필요. 의존성 최소화가 유지보수에 유리하다. 추후 Play Store 출시 시 화면 수가 늘어나면 그때 마이그레이션해도 비용이 크지 않다.

### 4. 퍼즐 소진 처리 전략

**결정:** 모든 퍼즐 플레이 후 ID 기록을 초기화하고 랜덤 반복 출제.

이유: 플레이 기록(사용한 퍼즐 ID 목록)을 SharedPreferences에 저장하고, getPuzzle 호출 시 excludeIds로 전달한다. 모두 소진되면 excludeIds를 무시하고 랜덤 반환한다. 난이도당 20개 퍼즐이면 일반적 사용 패턴에서 상당 기간 중복 없이 플레이 가능하다.

### 5. 앱 상태 저장 타이밍

**결정:** 숫자 입력/지우기/리셋 시마다 즉시 저장 (매 조작마다 저장).

트레이드오프: 빈번한 SharedPreferences 쓰기가 발생하지만, 저장 데이터가 JSON 문자열 1개(수 KB)에 불과하여 성능 영향이 무시 가능하다. WidgetsBindingObserver의 `didChangeAppLifecycleState`만으로 저장하면 강제 종료(kill) 시 데이터가 유실될 수 있다. 시니어 사용자가 의도치 않게 앱을 종료하는 경우가 빈번할 수 있으므로 안전한 쪽을 선택한다.

### 6. 화면 방향 고정 (세로)

**결정:** `SystemChrome.setPreferredOrientations`로 portrait 고정.

이유: NFR-002 요구사항. 가로 모드 레이아웃을 별도 설계/테스트할 필요가 없어 개발 공수 절감. 시니어 사용자에게 화면 회전은 혼란 요소다.

---

## 배치 검증 체크리스트

| 검증 항목 | 결과 |
|----------|------|
| 배치당 파일 수 <= 10개 | PASS (B1: 9, B2: 7, B3: 7, B4: 7, B5: 9) |
| Batch 1은 의존 배치 없음 | PASS (순수 Dart 도메인 모델, 외부 의존 없음) |
| 의존성 단방향 (순환 없음) | PASS (B1 <- B2 <- B3 <- B4 <- B5, 단방향 체인) |
| 각 배치 완료 기준이 "실행/컴파일 가능한 상태"로 기술됨 | PASS (각 배치에 flutter test 또는 flutter run 기준 명시) |
| 각 배치에 테스트 파일 포함 | PASS (B1: 3개, B2: 2개, B3: 1개, B4: 2개, B5: 4개) |

---

## GSTACK ENG REVIEW REPORT

| 항목 | 결과 | 내용 |
|------|------|------|
| Riverpod API | ✅ 수정 완료 | StateNotifierProvider → NotifierProvider (Riverpod 2.x 표준) |
| 배치 누락 테스트 | ✅ 수정 완료 | puzzle_data_test.dart (B1), difficulty_screen_test.dart (B5) 추가 |
| GameStorageService | ✅ 수정 완료 | 플레이 ID 저장 메서드 + SharedPreferences 키 규약 명시 |
| 아키텍처 | ✅ 승인 | 4계층 구조, 단방향 의존성, 배치 의존성 PASS |
| 테스트 커버리지 | ✅ 승인 | 모든 핵심 경로 커버 |

**VERDICT: ✅ 승인 — Batch 1 구현 시작 가능**

> 리뷰 일자: 2026-03-24 | 리뷰어: /plan-eng-review (gstack)
