import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import '../data/demo_data.dart';

class ReviewsNotifier extends StateNotifier<Map<String, List<ReviewModel>>> {
  ReviewsNotifier()
      : super({
          'w1': DemoData.reviews,
          'cw1': DemoData.reviews.sublist(0, 2),
          'w2': [DemoData.reviews[1], DemoData.reviews[2]],
        });

  List<ReviewModel> forWorker(String workerId) =>
      state[workerId] ?? const [];

  double averageFor(String workerId) {
    final list = forWorker(workerId);
    if (list.isEmpty) return 0;
    return list.fold(0.0, (s, r) => s + r.rating) / list.length;
  }

  void addReview({
    required String workerId,
    required String reviewerName,
    required String reviewerImage,
    required double rating,
    required String comment,
  }) {
    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reviewerName: reviewerName,
      reviewerImage: reviewerImage,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );
    state = {
      ...state,
      workerId: [review, ...forWorker(workerId)],
    };
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, Map<String, List<ReviewModel>>>(
      (ref) => ReviewsNotifier(),
    );

final reviewsCountProvider = Provider<int>((ref) {
  return ref
      .watch(reviewsProvider)
      .values
      .fold(0, (sum, list) => sum + list.length);
});

class WorkerAvailabilityNotifier extends StateNotifier<Map<String, bool>> {
  WorkerAvailabilityNotifier()
      : super({
          for (final w in [...DemoData.workers, ...DemoData.companyWorkers])
            w.id: w.isAvailable,
        });

  void toggle(String workerId) {
    state = {
      ...state,
      workerId: !(state[workerId] ?? true),
    };
  }
}

final workerAvailabilityProvider = StateNotifierProvider<
    WorkerAvailabilityNotifier, Map<String, bool>>(
  (ref) => WorkerAvailabilityNotifier(),
);
