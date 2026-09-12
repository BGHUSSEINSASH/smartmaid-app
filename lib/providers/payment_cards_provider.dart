import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';

class PaymentCardsNotifier extends StateNotifier<List<PaymentCard>> {
  PaymentCardsNotifier() : super(const [
    PaymentCard(id: 'c1', lastFour: '4242', brand: CardBrand.visa,
        holderName: 'أحمد محمد', expiryMonth: '12', expiryYear: '27', isDefault: true),
    PaymentCard(id: 'c2', lastFour: '5555', brand: CardBrand.mastercard,
        holderName: 'أحمد محمد', expiryMonth: '06', expiryYear: '26'),
  ]);

  void add(PaymentCard card) {
    // إن كانت افتراضية، أزِل الافتراضية السابقة
    if (card.isDefault) {
      state = state.map((c) => c.copyWith(isDefault: false)).toList();
    }
    state = [card, ...state];
  }

  void remove(String id) => state = state.where((c) => c.id != id).toList();

  void setDefault(String id) {
    state = state.map((c) => c.copyWith(isDefault: c.id == id)).toList();
  }

  PaymentCard? get defaultCard =>
      state.where((c) => c.isDefault).firstOrNull ?? state.firstOrNull;
}

final paymentCardsProvider =
    StateNotifierProvider<PaymentCardsNotifier, List<PaymentCard>>(
  (ref) => PaymentCardsNotifier(),
);
