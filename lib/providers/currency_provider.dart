import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_store.dart';

enum AppCurrency { usd, iqd }

const double _kIqdPerUsd = 1300.0;

extension CurrencyX on AppCurrency {
  String format(double usdAmount) {
    switch (this) {
      case AppCurrency.usd:
        return '\$${usdAmount.toStringAsFixed(0)}';
      case AppCurrency.iqd:
        final iqd = (usdAmount * _kIqdPerUsd).round();
        return '${_commify(iqd)} د.ع';
    }
  }

  String get label =>
      this == AppCurrency.usd ? 'دولار أمريكي (\$)' : 'دينار عراقي (د.ع)';
  String get symbol => this == AppCurrency.usd ? '\$' : 'د.ع';
  String get code => this == AppCurrency.usd ? 'USD' : 'IQD';
}

String _commify(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class CurrencyNotifier extends StateNotifier<AppCurrency> {
  CurrencyNotifier()
      : super(LocalStore.currencyCodeCache == 'iqd'
            ? AppCurrency.iqd
            : AppCurrency.usd);
  void set(AppCurrency c) {
    state = c;
    LocalStore.persistCurrency(c == AppCurrency.usd ? 'usd' : 'iqd');
  }

  void toggle() =>
      set(state == AppCurrency.usd ? AppCurrency.iqd : AppCurrency.usd);
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, AppCurrency>(
  (ref) => CurrencyNotifier(),
);
