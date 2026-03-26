import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/play_timer_service.dart';

final playTimerProvider = Provider<PlayTimerService>((ref) {
  final service = PlayTimerService();
  ref.onDispose(service.dispose);
  return service;
});
