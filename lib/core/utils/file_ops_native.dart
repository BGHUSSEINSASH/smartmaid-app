import 'dart:io';
import 'package:flutter/material.dart';

/// تنفيذ FileImage على المنصات الداعمة (native)
ImageProvider buildLocalFileImage(String path) => FileImage(File(path));

/// هل يمكن حفظ الملفات
bool get platformCanSaveFiles => true;

/// اسم النظام
String get platformNameRaw => Platform.isIOS
    ? 'ios'
    : Platform.isMacOS
        ? 'macos'
        : Platform.isAndroid
            ? 'android'
            : Platform.isWindows
                ? 'windows'
                : Platform.isLinux
                    ? 'linux'
                    : 'unknown';

/// هل النظام Apple
bool get platformIsApple => Platform.isIOS || Platform.isMacOS;

/// كتابة ملف PDF على native — يعيد المسار
Future<String> writePdfFile(String dirPath, String fileName, List<int> bytes) async {
  final file = File('$dirPath/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}
