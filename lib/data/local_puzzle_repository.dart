import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../domain/models/difficulty.dart';
import '../domain/models/puzzle_data.dart';
import '../domain/puzzle_repository.dart';

class LocalPuzzleRepository implements PuzzleRepository {
  final AssetBundle _assetBundle;

  LocalPuzzleRepository({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  @override
  Future<PuzzleData> getPuzzle(
    Difficulty difficulty, {
    List<String> excludeIds = const [],
  }) async {
    final puzzles = await _loadPuzzles(difficulty);

    final available =
        puzzles.where((p) => !excludeIds.contains(p.id)).toList();

    // 모두 소진된 경우 excludeIds 무시하고 전체에서 랜덤 반환
    final pool = available.isNotEmpty ? available : puzzles;

    return pool[Random().nextInt(pool.length)];
  }

  Future<List<PuzzleData>> _loadPuzzles(Difficulty difficulty) async {
    final path = 'assets/puzzles/${difficulty.name}.json';
    final jsonString = await _assetBundle.loadString(path);
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final List<dynamic> rawList = json['puzzles'] as List<dynamic>;
    return rawList
        .map((e) => PuzzleData.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
