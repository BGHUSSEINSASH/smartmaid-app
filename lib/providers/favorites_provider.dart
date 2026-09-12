import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_store.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(LocalStore.favoritesCache ?? {'w1', 'w3'});

  void toggle(String workerId) {
    final s = Set<String>.from(state);
    if (s.contains(workerId)) {
      s.remove(workerId);
    } else {
      s.add(workerId);
    }
    state = s;
    LocalStore.persistFavorites(s);
  }

  bool isFavorite(String workerId) => state.contains(workerId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
      (ref) => FavoritesNotifier(),
    );
