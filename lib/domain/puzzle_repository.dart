import 'models/difficulty.dart';
import 'models/puzzle_data.dart';

abstract class PuzzleRepository {
  /// 해당 난이도에서 excludeIds를 제외한 퍼즐 1개를 랜덤 반환.
  /// 모두 소진 시 excludeIds 무시하고 랜덤 반환.
  Future<PuzzleData> getPuzzle(
    Difficulty difficulty, {
    List<String> excludeIds = const [],
  });
}
