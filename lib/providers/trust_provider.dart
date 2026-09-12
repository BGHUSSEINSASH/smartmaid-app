import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository.dart';

// ---------------- SOS ----------------

enum SosPhase { idle, sending, sent }

class SosState {
  final SosPhase phase;
  final String message;
  final String alertId;
  final DateTime? sentAt;

  const SosState({
    this.phase = SosPhase.idle,
    this.message = '',
    this.alertId = '',
    this.sentAt,
  });

  SosState copyWith({
    SosPhase? phase,
    String? message,
    String? alertId,
    DateTime? sentAt,
  }) =>
      SosState(
        phase: phase ?? this.phase,
        message: message ?? this.message,
        alertId: alertId ?? this.alertId,
        sentAt: sentAt ?? this.sentAt,
      );
}

class SosNotifier extends StateNotifier<SosState> {
  SosNotifier() : super(const SosState());

  Future<void> trigger({required String location, String note = ''}) async {
    if (state.phase == SosPhase.sending) return;
    state = state.copyWith(phase: SosPhase.sending);
    final res = await TrustRepository.sendSos(
      location: location,
      message: note.isEmpty ? 'طلب طوارئ' : note,
    );
    state = SosState(
      phase: SosPhase.sent,
      message: res.message,
      alertId: res.alertId,
      sentAt: DateTime.now(),
    );
  }

  void reset() => state = const SosState();
}

final sosProvider = StateNotifierProvider<SosNotifier, SosState>(
  (ref) => SosNotifier(),
);

// ---------------- KYC ----------------

class KycState {
  final String status; // none | pending | approved | rejected
  final bool verified;
  final bool submitting;
  final String lastMessage;

  const KycState({
    this.status = 'none',
    this.verified = false,
    this.submitting = false,
    this.lastMessage = '',
  });

  KycState copyWith({
    String? status,
    bool? verified,
    bool? submitting,
    String? lastMessage,
  }) =>
      KycState(
        status: status ?? this.status,
        verified: verified ?? this.verified,
        submitting: submitting ?? this.submitting,
        lastMessage: lastMessage ?? this.lastMessage,
      );
}

class KycNotifier extends StateNotifier<KycState> {
  KycNotifier() : super(const KycState()) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final res = await TrustRepository.kycStatus();
    if (!mounted) return;
    state = state.copyWith(status: res.status, verified: res.verified);
  }

  Future<bool> submit({
    required String fullName,
    required String nationalId,
    String? selfieUrl,
  }) async {
    state = state.copyWith(submitting: true);
    final res = await TrustRepository.submitKyc(
      fullName: fullName,
      nationalId: nationalId,
      selfieUrl: selfieUrl,
    );
    state = state.copyWith(
      submitting: false,
      status: 'pending',
      verified: false,
      lastMessage: res.message,
    );
    return res.ok;
  }
}

final kycProvider = StateNotifierProvider<KycNotifier, KycState>(
  (ref) => KycNotifier(),
);

// ---------------- Settlements ----------------

class SettlementsState {
  final List<SettlementRecord> records;
  final bool loading;

  const SettlementsState({
    this.records = const [],
    this.loading = false,
  });

  SettlementsState copyWith({
    List<SettlementRecord>? records,
    bool? loading,
  }) =>
      SettlementsState(
        records: records ?? this.records,
        loading: loading ?? this.loading,
      );
}

class SettlementsNotifier extends StateNotifier<SettlementsState> {
  SettlementsNotifier() : super(const SettlementsState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true);
    final records = await TrustRepository.settlementHistory();
    if (!mounted) return;
    state = SettlementsState(records: records, loading: false);
  }

  Future<void> refresh() => _load();
}

final settlementsProvider =
    StateNotifierProvider<SettlementsNotifier, SettlementsState>(
  (ref) => SettlementsNotifier(),
);
