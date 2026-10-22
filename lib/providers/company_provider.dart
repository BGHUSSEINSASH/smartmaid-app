import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import '../data/demo_data.dart';

// ── Companies list state (with isPro toggling) ────────────────────────────────

class CompaniesNotifier extends StateNotifier<List<CompanyModel>> {
  CompaniesNotifier() : super(List.of(DemoData.companies));

  void togglePro(String companyId) {
    state = state.map((c) {
      if (c.id == companyId) return c.copyWith(isPro: !c.isPro);
      return c;
    }).toList();
  }
}

final companiesProvider =
    StateNotifierProvider<CompaniesNotifier, List<CompanyModel>>(
      (ref) => CompaniesNotifier(),
    );

// ── Company workers state ─────────────────────────────────────────────────────

class CompanyWorkersNotifier extends StateNotifier<List<WorkerModel>> {
  CompanyWorkersNotifier() : super(DemoData.companyWorkers);

  void addWorker(WorkerModel worker) => state = [...state, worker];
  void removeWorker(String id) =>
      state = state.where((w) => w.id != id).toList();

  /// تبديل حالة التوفّر — يحافظ على كل بيانات العاملة
  /// (بما فيها الدولة و verified — لا يُفقدان)
  void toggleAvailability(String id) {
    state = state
        .map((w) => w.id == id ? w.copyWith(isAvailable: !w.isAvailable) : w)
        .toList();
  }
}

final companyWorkersProvider =
    StateNotifierProvider<CompanyWorkersNotifier, List<WorkerModel>>(
      (ref) => CompanyWorkersNotifier(),
    );

// ── Company bookings (simulated earnings) ─────────────────────────────────────

class CompanyBookingStats {
  final int totalBookings;
  final double totalRevenue; // what customer paid
  final double netRevenue; // 80% after 20% platform commission
  final double platformCommission; // 20% = platform keeps

  const CompanyBookingStats({
    required this.totalBookings,
    required this.totalRevenue,
    required this.netRevenue,
    required this.platformCommission,
  });
}

CompanyBookingStats companyStatsForId(String companyId) {
  // Simulated stats per company
  const data = {
    'co1': (bookings: 142, revenue: 18460.0),
    'co2': (bookings: 98, revenue: 12250.0),
    'co3': (bookings: 76, revenue: 9870.0),
  };
  final d = data[companyId] ?? (bookings: 0, revenue: 0.0);
  final platform = d.revenue * AppCommission.platformRate;
  return CompanyBookingStats(
    totalBookings: d.bookings,
    totalRevenue: d.revenue,
    netRevenue: d.revenue - platform,
    platformCommission: platform,
  );
}
