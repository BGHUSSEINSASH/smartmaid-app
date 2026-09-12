import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/password_strength.dart';

/// شريط تقدم الخطوات
class RegStepBar extends StatelessWidget {
  final int steps;
  final int current;
  const RegStepBar({super.key, required this.steps, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: List.generate(steps, (i) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(left: i == steps - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: i <= current ? AppColors.primary : AppColors.stroke,
              borderRadius: BorderRadius.circular(4)),
          ),
        )),
      ),
    );
  }
}

/// عنوان قسم
class RegSectionTitle extends StatelessWidget {
  final String text;
  const RegSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900));
}

/// بلاط رفع مستند
class RegDocUploadTile extends StatefulWidget {
  final IconData icon;
  final String label;
  const RegDocUploadTile({super.key, required this.icon, required this.label});

  @override
  State<RegDocUploadTile> createState() => _RegDocUploadTileState();
}

class _RegDocUploadTileState extends State<RegDocUploadTile> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(widget.icon, color: AppColors.primary),
    title: Text(widget.label),
    trailing: _uploaded
        ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
        : ElevatedButton.icon(
            onPressed: () => setState(() => _uploaded = true),
            icon: const Icon(Icons.upload_rounded, size: 16),
            label: const Text('رفع', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
          ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    tileColor: AppColors.surfaceSoft,
  );
}

/// مؤشر قوة كلمة المرور
class RegStrengthBar extends StatelessWidget {
  final PasswordStrength s;
  const RegStrengthBar(this.s, {super.key});
  static const _colors = [
    Color(0xFFEF4444), Color(0xFFF59E0B), Color(0xFFF59E0B),
    Color(0xFF16A34A), Color(0xFF16A34A),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(children: [
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (s.score + 1) / 5,
            minHeight: 5,
            backgroundColor: AppColors.stroke,
            color: _colors[s.score]),
        )),
        const SizedBox(width: 8),
        Text(s.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: _colors[s.score])),
      ]),
    );
  }
}
