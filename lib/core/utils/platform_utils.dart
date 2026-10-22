import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show ImageProvider;
import 'file_ops_native.dart'
    if (dart.library.js_interop) 'file_ops_web.dart'
    if (dart.library.html) 'file_ops_web.dart'
    as ops;

/// مسار صورة محلية → ImageProvider يعمل على كل المنصات
///
/// native: FileImage (يعرض الصورة التي اختارها المستخدم)
/// web:    AssetImage بديل (المتصفح لا يدعم ملفات محلية)
ImageProvider localImageProvider(String path) => ops.buildLocalFileImage(path);

/// هل يدعم النظام حفظ/مشاركة الملفات بشكل كامل
bool get canSaveFiles => ops.platformCanSaveFiles;

/// اسم النظام
String get platformName => ops.platformNameRaw;

/// هل النظام iOS/macOS — للاهتزاز (haptic feedback)
bool get isApplePlatform => ops.platformIsApple;

/// كتابة ملف PDF في مجلد التطبيق — يعيد المسار
/// على الويب: يرمي UnsupportedError
Future<String> writePdfFile(
  String dirPath,
  String fileName,
  List<int> bytes,
) =>
    ops.writePdfFile(dirPath, fileName, bytes);
