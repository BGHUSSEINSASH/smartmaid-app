import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../core/theme/app_theme.dart';
import '../providers/address_provider.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  List<({String display, double lat, double lon})> _osmResults = [];
  Timer? _debounce;
  bool _gpsLoading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ── Nominatim forward geocoding (search by text) ──────────────
  void _searchOsmDebounced(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => _searchOsm(q));
  }

  Future<void> _searchOsm(String q) async {
    if (q.trim().length < 3) { setState(() => _osmResults = []); return; }
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&limit=5&q=${Uri.encodeComponent(q.trim())}');
      final res = await http
          .get(uri, headers: {'User-Agent': 'SmartMaidApp/1.0'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        if (mounted) {
          setState(() {
            _osmResults = list.map((e) => (
              display: e['display_name'].toString(),
              lat: double.parse(e['lat'].toString()),
              lon: double.parse(e['lon'].toString()),
            )).toList();
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _osmResults = []);
    }
  }

  // ── GPS current location + reverse geocoding ──────────────────
  Future<({String display, String city, double lat, double lon})?> _getGpsLocation() async {
    // 1. تحقق من الإذن
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('يرجى تفعيل خدمة الموقع GPS في إعدادات الجهاز'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ));
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('لم يتم منح إذن الموقع'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ));
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('إذن الموقع محجوب — يرجى تفعيله من إعدادات التطبيق'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ));
      }
      return null;
    }

    // 2. الحصول على الإحداثيات
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    // 3. Reverse geocoding عبر Nominatim
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&accept-language=ar');
      final res = await http
          .get(uri, headers: {'User-Agent': 'SmartMaidApp/1.0'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final address = data['address'] as Map<String, dynamic>? ?? {};
        final display = data['display_name']?.toString() ?? '';
        final city = (address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? '').toString();
        return (display: display, city: city, lat: pos.latitude, lon: pos.longitude);
      }
    } catch (_) {}

    // fallback — بدون reverse geocoding
    return (
      display: 'موقعي الحالي (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
      city: '',
      lat: pos.latitude,
      lon: pos.longitude,
    );
  }

  // ── Form: إضافة/تعديل عنوان ──────────────────────────────────
  void _showForm({
    AddressModel? existing,
    ({String display, double lat, double lon})? prefill,
    String? prefillCity,
  }) {
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? prefillCity ?? '');
    final detailsCtrl = TextEditingController(text: existing?.details ?? prefill?.display ?? '');
    double? lat = existing?.lat ?? prefill?.lat;
    double? lon = existing?.lon ?? prefill?.lon;
    bool isGpsLoading = false;
    List<({String display, double lat, double lon})> localResults = [];
    Timer? localDebounce;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        void searchLocal(String q) {
          localDebounce?.cancel();
          localDebounce = Timer(const Duration(milliseconds: 600), () async {
            if (q.trim().length < 3) { setSt(() => localResults = []); return; }
            try {
              final uri = Uri.parse(
                  'https://nominatim.openstreetmap.org/search?format=json&limit=5&q=${Uri.encodeComponent(q.trim())}');
              final res = await http.get(uri, headers: {'User-Agent': 'SmartMaidApp/1.0'}).timeout(const Duration(seconds: 8));
              if (res.statusCode == 200) {
                final list = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
                if (ctx.mounted) setSt(() => localResults = list.map((e) => (
                  display: e['display_name'].toString(),
                  lat: double.parse(e['lat'].toString()),
                  lon: double.parse(e['lon'].toString()),
                )).toList());
              }
            } catch (_) { if (ctx.mounted) setSt(() => localResults = []); }
          });
        }

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(existing == null ? 'إضافة عنوان' : 'تعديل العنوان',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  // ── زر GPS ──────────────────────────
                  Material(
                    color: AppColors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        setSt(() => isGpsLoading = true);
                        try {
                          final result = await _getGpsLocation();
                          if (result != null && ctx.mounted) {
                            setSt(() {
                              detailsCtrl.text = result.display;
                              if (result.city.isNotEmpty) cityCtrl.text = result.city;
                              lat = result.lat;
                              lon = result.lon;
                              localResults = [];
                              isGpsLoading = false;
                            });
                          } else {
                            setSt(() => isGpsLoading = false);
                          }
                        } catch (_) {
                          setSt(() => isGpsLoading = false);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: isGpsLoading
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.my_location_rounded, size: 18, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text('موقعي الحالي',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              ]),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                // حقل الاسم
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم العنوان (المنزل، العمل...)',
                    prefixIcon: Icon(Icons.label_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                // حقل المدينة
                TextField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'المدينة',
                    prefixIcon: Icon(Icons.location_city_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                // حقل التفاصيل مع بحث
                TextField(
                  controller: detailsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'التفاصيل / ابحث عن عنوان...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                  ),
                  onChanged: (v) { setSt(() => lat = null); searchLocal(v); },
                ),
                // نتائج البحث
                if (localResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(maxHeight: 150),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.stroke),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(ctx).scaffoldBackgroundColor,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: localResults.length,
                      itemBuilder: (_, i) {
                        final r = localResults[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place_rounded, size: 17, color: AppColors.primary),
                          title: Text(r.display, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5)),
                          onTap: () => setSt(() {
                            detailsCtrl.text = r.display;
                            lat = r.lat; lon = r.lon;
                            localResults = [];
                          }),
                        );
                      },
                    ),
                  ),
                // مؤشر GPS
                if (lat != null && lon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withValues(alpha: .3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.gps_fixed_rounded, size: 14, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          'تم تحديد الموقع: ${lat!.toStringAsFixed(4)}, ${lon!.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setSt(() { lat = null; lon = null; }),
                          child: const Icon(Icons.close_rounded, size: 14, color: AppColors.success),
                        ),
                      ]),
                    ),
                  ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: Icon(existing == null ? Icons.add_location_alt_rounded : Icons.save_rounded, size: 18),
                    label: Text(existing == null ? 'إضافة العنوان' : 'حفظ التعديلات'),
                    onPressed: () {
                      if (labelCtrl.text.trim().isEmpty || cityCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                          content: Text('يرجى إدخال اسم العنوان والمدينة'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ));
                        return;
                      }
                      final notifier = ref.read(addressProvider.notifier);
                      if (existing == null) {
                        notifier.add(labelCtrl.text.trim(), cityCtrl.text.trim(),
                            detailsCtrl.text.trim(), lat: lat, lon: lon);
                      } else {
                        notifier.update(existing.copyWith(
                          label: labelCtrl.text.trim(),
                          city: cityCtrl.text.trim(),
                          details: detailsCtrl.text.trim(),
                          lat: lat, lon: lon,
                        ));
                      }
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('عناويني')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded, size: 19),
        label: const Text('إضافة عنوان'),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.location_off_rounded, size: 42, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                const Text('لا توجد عناوين محفوظة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('اضغط "إضافة عنوان" لإضافة موقعك', style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ]),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = addresses[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: a.isDefault ? AppColors.primary : AppColors.stroke,
                        width: a.isDefault ? 1.8 : 1),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: a.isDefault ? .08 : .0), blurRadius: 12, offset: const Offset(0,4))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: a.isDefault ? AppColors.primary.withValues(alpha: .12) : AppColors.stroke,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          a.isDefault ? Icons.home_rounded : Icons.location_on_rounded,
                          color: a.isDefault ? AppColors.primary : AppColors.muted,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${a.label} — ${a.city}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        if (a.lat != null && a.lon != null)
                          Row(children: [
                            const Icon(Icons.gps_fixed_rounded, size: 11, color: AppColors.success),
                            const SizedBox(width: 3),
                            Text('${a.lat!.toStringAsFixed(4)}, ${a.lon!.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 10, color: AppColors.success)),
                          ]),
                      ])),
                      if (a.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text('افتراضي',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ),
                    ]),
                    const SizedBox(height: 8),
                    Text(a.details, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.muted), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Row(children: [
                      if (!a.isDefault)
                        TextButton.icon(
                          onPressed: () => ref.read(addressProvider.notifier).setDefault(a.id),
                          icon: const Icon(Icons.star_border_rounded, size: 16),
                          label: const Text('تعيين افتراضي', style: TextStyle(fontSize: 12)),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _showForm(existing: a),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        onPressed: () => ref.read(addressProvider.notifier).remove(a.id),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        tooltip: 'حذف',
                      ),
                    ]),
                  ]),
                );
              },
            ),
    );
  }
}
