import 'package:flutter/material.dart';

/// تنفيذ FileImage على الويب — غير مدعوم، نستخدم صورة بديلة
ImageProvider buildLocalFileImage(String path) =>
    const AssetImage('assets/icon/icon.png');

/// الويب لا يدعم حفظ الملفات مباشرة
bool get platformCanSaveFiles => false;

/// اسم النظام
String get platformNameRaw => 'web';

/// الويب ليس Apple
bool get platformIsApple => false;

/// كتابة PDF على الويب — غير مدعوم، نعيد رسالة
Future<String> writePdfFile(String dirPath, String fileName, List<int> bytes) async {
  throw UnsupportedError('حفظ PDF غير مدعوم على الويب');
}
