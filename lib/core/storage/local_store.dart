import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models.dart';
import '../../data/demo_data.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/address_provider.dart';

class BookingJson {
  static Map<String, dynamic> toJson(BookingModel b) => {
        'id': b.id,
        'workerId': b.workerId,
        'workerName': b.workerName,
        'workerImage': b.workerImage,
        'userId': b.userId,
        'date': b.date.millisecondsSinceEpoch,
        'timeSlot': b.timeSlot,
        'service': b.service,
        'total': b.total,
        'status': b.status.index,
        'paymentStatus': b.paymentStatus.index,
        'notes': b.notes,
        'cancelReason': b.cancelReason,
      };

  static BookingModel fromJson(Map<String, dynamic> j) => BookingModel(
        id: j['id'],
        workerId: j['workerId'],
        workerName: j['workerName'],
        workerImage: j['workerImage'],
        userId: j['userId'],
        date: DateTime.fromMillisecondsSinceEpoch(j['date']),
        timeSlot: j['timeSlot'],
        service: j['service'],
        total: (j['total'] as num).toDouble(),
        status: BookingStatus.values[j['status'] ?? 0],
        paymentStatus: PaymentStatus.values[j['paymentStatus'] ?? 0],
        notes: j['notes']?.toString() ?? '',
        cancelReason: j['cancelReason']?.toString() ?? '',
      );
}

class WalletTxJson {
  static Map<String, dynamic> toJson(WalletTransaction t) => {
        'id': t.id,
        'title': t.title,
        'amountUsd': t.amountUsd,
        'type': t.type.index,
        'date': t.date.millisecondsSinceEpoch,
      };

  static WalletTransaction fromJson(Map<String, dynamic> j) =>
      WalletTransaction(
        id: j['id'],
        title: j['title'],
        amountUsd: (j['amountUsd'] as num).toDouble(),
        type: WalletTxType.values[j['type'] ?? 0],
        date: DateTime.fromMillisecondsSinceEpoch(j['date']),
      );
}

class AddressJson {
  static Map<String, dynamic> toJson(AddressModel a) => {
        'id': a.id,
        'label': a.label,
        'city': a.city,
        'details': a.details,
        'isDefault': a.isDefault,
        if (a.lat != null) 'lat': a.lat,
        if (a.lon != null) 'lon': a.lon,
      };

  static AddressModel fromJson(Map<String, dynamic> j) => AddressModel(
        id: j['id'],
        label: j['label'],
        city: j['city'],
        details: j['details'],
        isDefault: j['isDefault'] ?? false,
        lat: j['lat'] != null ? (j['lat'] as num).toDouble() : null,
        lon: j['lon'] != null ? (j['lon'] as num).toDouble() : null,
      );
}

class LoyaltyHistJson {
  static Map<String, dynamic> toJson(
          ({String title, int points, DateTime date}) h) =>
      {'title': h.title, 'points': h.points, 'date': h.date.millisecondsSinceEpoch};

  static ({String title, int points, DateTime date}) fromJson(
          Map<String, dynamic> j) =>
      (
        title: j['title'],
        points: j['points'],
        date: DateTime.fromMillisecondsSinceEpoch(j['date']),
      );
}

/// In-memory caches hydrated once at startup; providers read them
/// synchronously in their constructors and write through on every change.
class LocalStore {
  LocalStore._();

  static List<BookingModel>? bookingsCache;
  static Set<String>? favoritesCache;
  static double? walletBalanceCache;
  static List<WalletTransaction>? walletTxCache;
  static int? loyaltyPointsCache;
  static List<({String title, int points, DateTime date})>? loyaltyHistCache;
  static List<AddressModel>? addressesCache;
  static String? currencyCodeCache;

  static Future<void> hydrate() async {
    try {
      final sp = await SharedPreferences.getInstance();
      bookingsCache = _decodeList(sp, 'sm.bookings')
          ?.map(BookingJson.fromJson)
          .toList();
      favoritesCache =
          (sp.getStringList('sm.favorites'))?.toSet();
      walletBalanceCache = sp.getDouble('sm.wallet.balance');
      walletTxCache = _decodeList(sp, 'sm.wallet.tx')
          ?.map(WalletTxJson.fromJson)
          .toList();
      loyaltyPointsCache = sp.getInt('sm.loyalty.points');
      loyaltyHistCache = _decodeList(sp, 'sm.loyalty.hist')
          ?.map(LoyaltyHistJson.fromJson)
          .toList();
      addressesCache = _decodeList(sp, 'sm.addresses')
          ?.map(AddressJson.fromJson)
          .toList();
      currencyCodeCache = sp.getString('sm.currency');
    } catch (_) {}
  }

  static List<Map<String, dynamic>>? _decodeList(
      SharedPreferences sp, String key) {
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> persistBookings(List<BookingModel> list) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(
          'sm.bookings',
          jsonEncode(list.take(50).map(BookingJson.toJson).toList()));
    } catch (_) {}
  }

  static Future<void> persistFavorites(Set<String> set) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList('sm.favorites', set.toList());
    } catch (_) {}
  }

  static Future<void> persistWallet(
      double balance, List<WalletTransaction> txs) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setDouble('sm.wallet.balance', balance);
      await sp.setString('sm.wallet.tx',
          jsonEncode(txs.take(100).map(WalletTxJson.toJson).toList()));
    } catch (_) {}
  }

  static Future<void> persistLoyalty(int points,
      List<({String title, int points, DateTime date})> hist) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setInt('sm.loyalty.points', points);
      await sp.setString('sm.loyalty.hist',
          jsonEncode(hist.take(60).map(LoyaltyHistJson.toJson).toList()));
    } catch (_) {}
  }

  static Future<void> persistAddresses(List<AddressModel> list) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('sm.addresses',
          jsonEncode(list.map(AddressJson.toJson).toList()));
    } catch (_) {}
  }

  static Future<void> persistCurrency(String code) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('sm.currency', code);
    } catch (_) {}
  }

  static Future<void> saveBookingDraft(Map<String, dynamic> draft) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('sm.booking.draft', jsonEncode(draft));
    } catch (_) {}
  }

  static Map<String, dynamic>? loadBookingDraftSyncCache;

  static Future<Map<String, dynamic>?> loadBookingDraft() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('sm.booking.draft');
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearBookingDraft() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove('sm.booking.draft');
    } catch (_) {}
  }

  static Future<void> saveProfileFields(
      {String? name, String? phone, String? location, String? imageUrl}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      if (name != null) await sp.setString('sm.profile.name', name);
      if (phone != null) await sp.setString('sm.profile.phone', phone);
      if (location != null) await sp.setString('sm.profile.location', location);
      if (imageUrl != null) await sp.setString('sm.profile.image', imageUrl);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> loadProfileFields() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return {
        if (sp.getString('sm.profile.name') != null)
          'name': sp.getString('sm.profile.name'),
        if (sp.getString('sm.profile.phone') != null)
          'phone': sp.getString('sm.profile.phone'),
        if (sp.getString('sm.profile.location') != null)
          'location': sp.getString('sm.profile.location'),
        if (sp.getString('sm.profile.image') != null)
          'imageUrl': sp.getString('sm.profile.image'),
      };
    } catch (_) {
      return {};
    }
  }
}

final hydratedProvider = Provider<bool>((ref) => true);

BookingModel demoBookingSeed() => DemoData.bookings.first;
