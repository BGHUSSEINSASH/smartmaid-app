import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ──────── Brand: Deep Navy Blue #03045A ──────────────────────
  static const Color primary     = Color(0xFF03045A);
  static const Color primaryDark = Color(0xFF020342);
  static const Color primarySoft = Color(0xFFCCDDFF);
  static const Color accent      = Color(0xFF0353A4);   // رفيق سيان
  static const Color aquaSoft    = Color(0xFFE8F0FF);
  static const Color aquaStrong  = Color(0xFF023E8A);

  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF5F8FF);
  static const Color stroke      = Color(0xFFDDE4F0);
  static const Color primaryLight= Color(0xFFDEE9FF);
  static const Color error       = Color(0xFFEF4444);
  static const Color errorLight  = Color(0xFFEF4444);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color warningLight= Color(0xFFF59E0B);
  static const Color success     = Color(0xFF16A34A);
  static const Color danger      = Color(0xFFDC2626);
  static const Color bg          = Color(0xFFEFF4FF);
  static const Color bgDeep      = Color(0xFF02021E);
  static const Color backgroundLight = bg;
  static const Color backgroundDark  = bgDeep;
  static const Color darkSurface = Color(0xFF0A0A2E);
  static const Color surfaceDark = darkSurface;
  static const Color cardDark    = Color(0xFF0D0D35);
  static const Color panel       = Color(0xFFFFFFFF);
  static const Color panelAlt    = Color(0xFFF5F8FF);
  static const Color ink         = Color(0xFF03045A);
  static const Color textPrimary = ink;
  static const Color muted       = Color(0xFF5A6882);
  static const Color textSecondary = muted;
  static const Color textHint    = Color(0xFF94A3B8);
  static const Color amber       = warning;
  static const Color border      = stroke;

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF03045A), Color(0xFF0353A4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient aquaGradient = greenGradient;
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF03045A), Color(0xFF023E8A), Color(0xFF0353A4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient assistantGradient = LinearGradient(
    colors: [Color(0xFF03045A), Color(0xFF0353A4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF03045A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient deductionGradient = LinearGradient(
    colors: [Color(0xFF02021E), Color(0xFF03045A)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
  static const LinearGradient savingsGradient = LinearGradient(
    colors: [Color(0xFF023E8A), Color(0xFF0353A4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadii {
  static const BorderRadius card = BorderRadius.all(Radius.circular(24));
  static const BorderRadius input = BorderRadius.all(Radius.circular(16));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 10)),
  ];
}

class AppShadow {
  static const List<BoxShadow> soft = AppShadows.soft;
}

class AppTheme {
  static ThemeData get lightTheme {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.primaryDark,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.cairo().fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: const Color(0x140F172A),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        labelStyle: const TextStyle(
          color: AppColors.textHint,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: AppColors.primary, width: 1.3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(140, 52),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pill),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: AppColors.textPrimary, height: 1.35),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primarySoft,
        shadowColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.muted,
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surfaceDark,
          onSurface: Colors.white,
          error: AppColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.cairo().fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide.none,
        ),
        // إصلاح: حدود بيضاء شفافة أوضح من البنفسجي
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(140, 52),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.pill),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: Colors.white, height: 1.35),
      ),
      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF08082A),
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.10),
        thickness: 0.8,
      ),
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1C1C4E),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
        iconColor: Colors.white70,
        textColor: Colors.white,
      ),
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : Colors.white54),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.accent.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.15)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withValues(alpha: 0.25),
        shadowColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Colors.white : Colors.white60,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? Colors.white : Colors.white54,
            size: 22,
          );
        }),
      ),
    );
  }
}

