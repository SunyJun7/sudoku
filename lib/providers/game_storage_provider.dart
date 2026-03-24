import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_storage_service.dart';

final gameStorageProvider = Provider<GameStorageService>((ref) {
  return GameStorageService();
});

final hasSavedGameProvider = FutureProvider<bool>((ref) async {
  final storage = ref.read(gameStorageProvider);
  return storage.hasSavedGame();
});
