import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_store.dart';

enum WalletTxType { topup, payment, withdrawal, earning, refund }

class WalletTransaction {
  final String id;
  final String title;
  final double amountUsd;
  final WalletTxType type;
  final DateTime date;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amountUsd,
    required this.type,
    required this.date,
  });

  bool get isCredit =>
      type == WalletTxType.topup ||
      type == WalletTxType.earning ||
      type == WalletTxType.refund;
}

class WalletState {
  final double balanceUsd;
  final List<WalletTransaction> transactions;

  const WalletState({
    this.balanceUsd = 240,
    this.transactions = const [],
  });

  WalletState copyWith({
    double? balanceUsd,
    List<WalletTransaction>? transactions,
  }) => WalletState(
    balanceUsd: balanceUsd ?? this.balanceUsd,
    transactions: transactions ?? this.transactions,
  );
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier()
    : super(
        WalletState(
          balanceUsd: LocalStore.walletBalanceCache ?? 240,
          transactions: LocalStore.walletTxCache ??
              [
                WalletTransaction(
                  id: 't1',
                  title: 'دفع حجز تنظيف منازل',
                  amountUsd: -150,
                  type: WalletTxType.payment,
                  date: DateTime.now().subtract(const Duration(days: 2)),
                ),
                WalletTransaction(
                  id: 't2',
                  title: 'شحن المحفظة',
                  amountUsd: 300,
                  type: WalletTxType.topup,
                  date: DateTime.now().subtract(const Duration(days: 4)),
                ),
                WalletTransaction(
                  id: 't3',
                  title: 'استرداد حجز ملغى',
                  amountUsd: 90,
                  type: WalletTxType.refund,
                  date: DateTime.now().subtract(const Duration(days: 6)),
                ),
              ],
        ),
      );

  void _push(WalletTransaction tx) {
    LocalStore.persistWallet(state.balanceUsd, [tx, ...state.transactions]);
    state = state.copyWith(transactions: [tx, ...state.transactions]);
  }

  bool topUp(double amount) {
    if (amount <= 0) return false;
    _push(WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'شحن المحفظة',
      amountUsd: amount,
      type: WalletTxType.topup,
      date: DateTime.now(),
    ));
    final next = state.copyWith(balanceUsd: state.balanceUsd + amount);
    state = next;
    LocalStore.persistWallet(next.balanceUsd, next.transactions);
    return true;
  }

  bool pay(double amount, String title) {
    if (amount <= 0 || amount > state.balanceUsd) return false;
    _push(WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amountUsd: -amount,
      type: WalletTxType.payment,
      date: DateTime.now(),
    ));
    final next = state.copyWith(balanceUsd: state.balanceUsd - amount);
    state = next;
    LocalStore.persistWallet(next.balanceUsd, next.transactions);
    return true;
  }

  bool withdraw(double amount) {
    if (amount <= 0 || amount > state.balanceUsd) return false;
    _push(WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'طلب سحب أرباح',
      amountUsd: -amount,
      type: WalletTxType.withdrawal,
      date: DateTime.now(),
    ));
    final next = state.copyWith(balanceUsd: state.balanceUsd - amount);
    state = next;
    LocalStore.persistWallet(next.balanceUsd, next.transactions);
    return true;
  }

  void addEarning(double amount, String title) {
    _push(WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amountUsd: amount,
      type: WalletTxType.earning,
      date: DateTime.now(),
    ));
    state = state.copyWith(balanceUsd: state.balanceUsd + amount);
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>(
  (ref) => WalletNotifier(),
);

class WithdrawRequest {
  final String id;
  final String requesterName;
  final double amountUsd;
  final DateTime date;
  bool approved;

  WithdrawRequest({
    required this.id,
    required this.requesterName,
    required this.amountUsd,
    required this.date,
    this.approved = false,
  });
}

class WithdrawalsNotifier extends StateNotifier<List<WithdrawRequest>> {
  WithdrawalsNotifier()
    : super([
        WithdrawRequest(
          id: 'wr1',
          requesterName: 'شركة النظافة المثالية',
          amountUsd: 1250,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        WithdrawRequest(
          id: 'wr2',
          requesterName: 'ماريا سانتوس',
          amountUsd: 430,
          date: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ]);

  void approve(String id) {
    state = state
        .map((w) => w.id == id ? (w..approved = true) : w)
        .toList();
  }
}

final withdrawalsProvider =
    StateNotifierProvider<WithdrawalsNotifier, List<WithdrawRequest>>(
      (ref) => WithdrawalsNotifier(),
    );

