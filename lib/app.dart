import 'package:flutter/material.dart';

import 'domain/services/curfew_checker.dart';
import 'ui/screens/blocked_screen.dart';
import 'ui/screens/clear_screen.dart';
import 'ui/screens/difficulty_screen.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '스도쿠',
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => CurfewChecker.isBlockedTime()
            ? const BlockedScreen()
            : const HomeScreen(),
        '/difficulty': (context) => const DifficultyScreen(),
        '/game': (context) => const GameScreen(),
        '/clear': (context) => const ClearScreen(),
      },
    );
  }
}
