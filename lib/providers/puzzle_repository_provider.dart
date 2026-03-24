import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_puzzle_repository.dart';
import '../domain/puzzle_repository.dart';

final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  return LocalPuzzleRepository();
});
