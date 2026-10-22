// أداة إزالة المفاتيح المكررة من قاموس الترجمة
// الاستخدام: dart run tool/dedupe_translations.dart
import 'dart:io';

void main() {
  final path = 'lib/l10n/strings/translations.dart';
  final lines = File(path).readAsLinesSync();

  final seen = <String>{};
  final out = <String>[];

  for (final line in lines) {
    final m = RegExp(r"^\s*'([^']*)':\s*'").firstMatch(line);
    if (m != null) {
      final key = m.group(1)!;
      if (!seen.add(key)) {
        continue; // تكرار — تخطّاه
      }
    }
    out.add(line);
  }

  File(path).writeAsStringSync(out.join('\n'));
  stderr.writeln('Removed ${lines.length - out.length} duplicate entries');
}
