// أداة استخراج النصوص العربية الفريدة من الكود → JSON
// الاستخدام: dart run tool/extract_ar.dart > ar_strings.json
import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('lib');
  final strings = <String>{};

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains(RegExp(r'l10n|tool'))) continue;

    final content = entity.readAsStringSync();
    // نصوص بين ' ' أو " " تحتوي حروف عربية
    final reg = RegExp(r"""(['"])((?:\\.|(?!\1)[^\\\r\n])*?[\u0600-\u06FF](?:\\.|(?!\1)[^\\\r\n])*?)\1""");
    for (final m in reg.allMatches(content)) {
      final s = m.group(2);
      if (s == null || s.isEmpty) continue;
      // نستبعد النصوص الطويلة جداً (فقرة/تنسيق) والقوالب المعقدة
      if (s.length > 80) continue;
      if (s.contains(r'${') && s.length > 40) continue;
      strings.add(s);
    }
  }

  final list = strings.toList()..sort();
  stdout.writeln(jsonEncode(list));
  stderr.writeln('Extracted ${list.length} unique Arabic strings');
}
