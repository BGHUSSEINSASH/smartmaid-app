import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/demo_data.dart';

class ServiceItem {
  final String id;
  final String name;
  final String icon;
  final double price;
  final bool isActive;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    this.isActive = true,
  });

  ServiceItem copyWith({String? id, String? name, String? icon, double? price, bool? isActive}) =>
      ServiceItem(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        price: price ?? this.price,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'icon': icon, 'price': price, 'isActive': isActive};
  factory ServiceItem.fromJson(Map<String, dynamic> j) => ServiceItem(
    id: j['id'], name: j['name'], icon: j['icon'], price: (j['price'] as num).toDouble(), isActive: j['isActive'] ?? true,
  );
}

class CompanyServicesNotifier extends StateNotifier<List<ServiceItem>> {
  CompanyServicesNotifier() : super([]) {
    _load();
  }

  static const _key = 'company.services';

  Future<void> _load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_key);
      if (raw != null) {
        final list = (jsonDecode(raw) as List).map((e) => ServiceItem.fromJson(e)).toList();
        state = list;
        return;
      }
    } catch (_) {}
    // fallback — من DemoData
    state = DemoData.extraServices.map((s) => ServiceItem(
      id: s.id, name: s.name, icon: s.icon, price: s.priceUsd,
    )).toList();
  }

  Future<void> _persist() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_key, jsonEncode(state.map((s) => s.toJson()).toList()));
    } catch (_) {}
  }

  void updatePrice(String id, double price) {
    state = state.map((s) => s.id == id ? s.copyWith(price: price) : s).toList();
    _persist();
  }

  void toggleActive(String id) {
    state = state.map((s) => s.id == id ? s.copyWith(isActive: !s.isActive) : s).toList();
    _persist();
  }

  void add(ServiceItem service) {
    state = [...state, service];
    _persist();
  }

  void remove(String id) {
    state = state.where((s) => s.id != id).toList();
    _persist();
  }

  void update(ServiceItem updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
    _persist();
  }
}

final companyServicesProvider =
    StateNotifierProvider<CompanyServicesNotifier, List<ServiceItem>>(
  (ref) => CompanyServicesNotifier(),
);
