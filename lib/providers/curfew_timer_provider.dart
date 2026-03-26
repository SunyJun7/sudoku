import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/curfew_timer_service.dart';

final curfewTimerProvider = Provider<CurfewTimerService>((ref) {
  final service = CurfewTimerService();
  ref.onDispose(service.dispose);
  return service;
});
