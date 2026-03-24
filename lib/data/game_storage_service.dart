import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/difficulty.dart';
import '../domain/models/game_state.dart';

class GameStorageService {
  static const String _currentGameKey = 'current_game';

  static String _playedIdsKey(Difficulty difficulty) =>
      'played_ids_${difficulty.name}';

  /// 현재 진행 중인 게임 저장
  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentGameKey, jsonEncode(state.toJson()));
  }

  /// 저장된 게임 복원 (없으면 null 반환)
  Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_currentGameKey);
    if (jsonString == null) return null;
    return GameState.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// 저장된 게임 삭제
  Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentGameKey);
  }

  /// 저장된 게임 존재 여부
  Future<bool> hasSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentGameKey);
  }

  /// 플레이 완료한 퍼즐 ID 목록 조회
  Future<List<String>> getPlayedIds(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_playedIdsKey(difficulty));
    if (jsonString == null) return [];
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list.cast<String>();
  }

  /// 플레이 완료한 퍼즐 ID 추가
  Future<void> savePlayedId(Difficulty difficulty, String puzzleId) async {
    final ids = await getPlayedIds(difficulty);
    if (!ids.contains(puzzleId)) {
      ids.add(puzzleId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playedIdsKey(difficulty), jsonEncode(ids));
  }

  /// 플레이 ID 목록 초기화
  Future<void> clearPlayedIds(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playedIdsKey(difficulty));
  }
}
