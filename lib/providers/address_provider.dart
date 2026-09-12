import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_store.dart';

class AddressModel {
  final String id;
  final String label;
  final String city;
  final String details;
  final bool isDefault;
  final double? lat;
  final double? lon;

  const AddressModel({
    required this.id,
    required this.label,
    required this.city,
    required this.details,
    this.isDefault = false,
    this.lat,
    this.lon,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? city,
    String? details,
    bool? isDefault,
    double? lat,
    double? lon,
  }) =>
      AddressModel(
        id: id ?? this.id,
        label: label ?? this.label,
        city: city ?? this.city,
        details: details ?? this.details,
        isDefault: isDefault ?? this.isDefault,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );
}

class AddressNotifier extends StateNotifier<List<AddressModel>> {
  AddressNotifier()
      : super(LocalStore.addressesCache ??
            const [
              AddressModel(
                id: 'a1',
                label: 'المنزل',
                city: 'الرياض',
                details: 'حي النزهة، شارع الأمير سلطان، مبنى 12، شقة 3',
                isDefault: true,
              ),
              AddressModel(
                id: 'a2',
                label: 'المكتب',
                city: 'الرياض',
                details: 'طريق الملك فهد، برج المملكة، الدور 14',
              ),
            ]);

  void add(String label, String city, String details,
      {double? lat, double? lon}) {
    state = [
      ...state.map((a) => a.copyWith(isDefault: false)),
      AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: label,
        city: city,
        details: details,
        isDefault: state.isEmpty,
        lat: lat,
        lon: lon,
      ),
    ];
    LocalStore.persistAddresses(state);
  }

  void update(AddressModel updated) {
    state = state
        .map((a) => a.id == updated.id ? updated : a)
        .toList();
    LocalStore.persistAddresses(state);
  }

  void remove(String id) {
    state = state.where((a) => a.id != id).toList();
    if (state.isNotEmpty && !state.any((a) => a.isDefault)) {
      state = [state.first.copyWith(isDefault: true), ...state.skip(1)];
    }
    LocalStore.persistAddresses(state);
  }

  void setDefault(String id) {
    state = state
        .map((a) => a.copyWith(isDefault: a.id == id))
        .toList();
    LocalStore.persistAddresses(state);
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, List<AddressModel>>(
      (ref) => AddressNotifier(),
    );

final selectedAddressIdProvider = StateProvider<String?>((ref) => null);

final selectedAddressProvider = Provider<AddressModel?>((ref) {
  final list = ref.watch(addressProvider);
  final sel = ref.watch(selectedAddressIdProvider);
  return list.where((a) => a.id == sel).firstOrNull ??
      list.where((a) => a.isDefault).firstOrNull ??
      list.firstOrNull;
});
