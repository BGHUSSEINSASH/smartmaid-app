import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import 'booking_provider.dart';

/// Analyzes user's booking history to suggest similar workers
final recommendationsProvider = Provider<List<WorkerModel>>((ref) {
  final bookings = ref.watch(myBookingsProvider);
  if (bookings.isEmpty) {
    // No history — suggest top-rated workers
    return DemoData.workers
        .where((w) => w.isAvailable)
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // Get categories and locations from past bookings
  final bookedCategories = bookings.map((b) => b.service).toSet();
  final bookedWorkerIds = bookings.map((b) => b.workerId).toSet();

  // Find workers in similar categories that weren't booked yet
  final candidates = DemoData.workers
      .where((w) =>
          w.isAvailable &&
          !bookedWorkerIds.contains(w.id) &&
          bookedCategories.contains(w.category))
      .toList()
    ..sort((a, b) => b.rating.compareTo(a.rating));

  if (candidates.isNotEmpty) return candidates.take(3).toList();

  // Fallback: top-rated available workers not yet booked
  return DemoData.workers
      .where((w) => w.isAvailable && !bookedWorkerIds.contains(w.id))
      .toList()
    ..sort((a, b) => b.rating.compareTo(a.rating));
});

/// Get similar workers to a specific worker (same category)
List<WorkerModel> getSimilarWorkers(WorkerModel worker) {
  return DemoData.workers
      .where((w) =>
          w.id != worker.id &&
          w.isAvailable &&
          w.category == worker.category)
      .toList()
    ..sort((a, b) => b.rating.compareTo(a.rating));
}
