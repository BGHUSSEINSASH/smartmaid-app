import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';

class BackendHealth {
  final bool reachable;
  final DateTime? checkedAt;

  const BackendHealth({
    required this.reachable,
    this.checkedAt,
  });
}

const BackendHealth _kUnknown = BackendHealth(reachable: true);

class BackendHealthNotifier extends StateNotifier<BackendHealth> {
  BackendHealthNotifier() : super(_kUnknown) {
    if (!ApiClient.likelyReachable) return;
    check();
    Timer.periodic(const Duration(seconds: 30), (_) => check());
  }

  Future<void> check() async {
    final res = await ApiClient.get('/health');
    state = BackendHealth(
      reachable: res != null && (res['status'] == 'ok'),
      checkedAt: DateTime.now(),
    );
  }
}

final backendHealthProvider =
    StateNotifierProvider<BackendHealthNotifier, BackendHealth>(
      (ref) => BackendHealthNotifier(),
    );
