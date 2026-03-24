import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/cell_state.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/puzzle_data.dart';
import 'package:sudoku/providers/game_state_provider.dart';
import 'package:sudoku/providers/game_storage_provider.dart';
import 'package:sudoku/ui/screens/difficulty_screen.dart';
import 'package:sudoku/ui/screens/home_screen.dart';

// ─── 헬퍼 ──────────────────────────────────────────────────────────────────────

PuzzleData _emptyPuzzle() => PuzzleData(
      id: 'test',
      givens: List.filled(81, 0),
      solution: List.filled(81, 1),
    );

GameState _defaultGameState() => GameState(
      puzzle: _emptyPuzzle(),
      board: List.filled(
        81,
        const CellState(value: 0, isGiven: false, isError: false),
      ),
      selectedIndex: null,
      difficulty: Difficulty.easy,
      isComplete: false,
    );

// ─── Mock Notifiers ────────────────────────────────────────────────────────────

class _MockGameStateNotifier extends GameStateNotifier {
  bool restoreCalled = false;

  @override
  GameState? build() => null;

  @override
  Future<void> restoreGame() async {
    restoreCalled = true;
    state = _defaultGameState();
  }
}

// ─── 테스트 ────────────────────────────────────────────────────────────────────

Widget _buildApp({required bool hasSaved}) {
  return ProviderScope(
    overrides: [
      hasSavedGameProvider.overrideWith((ref) async => hasSaved),
    ],
    child: MaterialApp(
      routes: {
        '/': (context) => const HomeScreen(),
        '/difficulty': (context) => const DifficultyScreen(),
      },
      initialRoute: '/',
    ),
  );
}

Widget _buildAppWithMockNotifier({
  required bool hasSaved,
  required _MockGameStateNotifier notifier,
}) {
  return ProviderScope(
    overrides: [
      hasSavedGameProvider.overrideWith((ref) async => hasSaved),
      gameStateProvider.overrideWith(() => notifier),
    ],
    child: MaterialApp(
      routes: {
        '/': (context) => const HomeScreen(),
        '/difficulty': (context) => const DifficultyScreen(),
        '/game': (context) => const Scaffold(body: Text('게임 화면')),
      },
      initialRoute: '/',
    ),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('hasSavedGame=false 시 [이어하기] 버튼이 없다', (tester) async {
      await tester.pumpWidget(_buildApp(hasSaved: false));
      // FutureProvider 완료 대기
      await tester.pump();
      await tester.pump();

      expect(find.text('이어하기'), findsNothing);
    });

    testWidgets('hasSavedGame=true 시 [이어하기] 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(_buildApp(hasSaved: true));
      await tester.pump();
      await tester.pump();

      expect(find.text('이어하기'), findsOneWidget);
    });

    testWidgets('[시작] 버튼 탭 시 /difficulty 라우트로 이동한다', (tester) async {
      await tester.pumpWidget(_buildApp(hasSaved: false));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('시작'));
      await tester.pumpAndSettle();

      // DifficultyScreen의 AppBar 제목으로 이동 확인
      expect(find.text('난이도 선택'), findsOneWidget);
    });

    testWidgets('[이어하기] 탭 시 restoreGame()이 호출된다', (tester) async {
      final mockNotifier = _MockGameStateNotifier();

      await tester.pumpWidget(
        _buildAppWithMockNotifier(hasSaved: true, notifier: mockNotifier),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('이어하기'));
      await tester.pumpAndSettle();

      expect(mockNotifier.restoreCalled, isTrue);
    });
  });
}
