import 'package:flutter/material.dart';
import 'translations.dart';

/// نظام الترجمة الموحّد
///
/// الاستخدام:  Text(S.t('نص عربي'))
/// إذا لم توجد الترجمة → يعيد النص العربي الأصلي (fallback آمن)
class S {
  const S._();

  /// ترجمة نص — تستخدم اللغة المفعّلة حالياً
  static String t(String arabic) => translate(arabic);

  /// ترجمة نص مع سياق — تقرأ اللغة من الـ context (أدق)
  static String tc(BuildContext context, String arabic) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return arabic;
    return translations[arabic] ?? arabic;
  }

  /// هل الترجمة متوفرة لهذه العبارة
  static bool has(String arabic) => translations.containsKey(arabic);

  /// اللغة الحالية
  static String get currentLanguage => _currentLanguage;
  static String _currentLanguage = 'ar';
}

/// دالة الترجمة الأساسية — تُحدَّث عند تغيير اللغة
String Function(String) translate = (s) => s;

/// تفعيل الترجمة حسب اللغة الحالية
void applyLocale(String languageCode) {
  S._currentLanguage = languageCode;
  translate = (s) {
    if (languageCode == 'ar') return s;
    return translations[s] ?? s;
  };
}

/// Widget يعرض نص مترجم — بديل مريح لـ Text
class T extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool softWrap;
  final Widget? child;

  const T(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // نقرأ اللغة من الـ context — أدق ويتحدث فوراً
    final t = S.tc(context, text);
    if (child != null) {
      return DefaultTextStyle(
        style: style ?? Theme.of(context).textTheme.bodyMedium!,
        child: child!,
      );
    }
    return Text(
      t,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}

