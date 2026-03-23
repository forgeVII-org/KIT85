import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeTokens {
  const AppThemeTokens._();

  // Core palette: retro hardware + modern dashboard.
  static const Color bg = Color(0xFF070B0E);
  static const Color bgAlt = Color(0xFF0D141A);
  static const Color surface = Color(0xFF111A21);
  static const Color surfaceRaised = Color(0xFF18242E);
  static const Color surfaceTint = Color(0xFF20303D);
  static const Color border = Color(0xFF2A3947);

  static const Color primary = Color(0xFF57E389);
  static const Color secondary = Color(0xFF56C8F5);
  static const Color accent = Color(0xFFFFB347);

  static const Color text = Color(0xFFE7EDF3);
  static const Color textMuted = Color(0xFF93A4B3);

  static const Color success = Color(0xFF51D88A);
  static const Color warning = Color(0xFFFF9F1A);
  static const Color error = Color(0xFFFF5A52);

  static const Color ledRunning = Color(0xFF73FF9D);
  static const Color ledHalted = Color(0xFFFF7065);

  static const String codeFontFamily = 'monospace';

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 340);
}

class AppTheme {
  const AppTheme._();

  static ThemeData darkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppThemeTokens.primary,
        onPrimary: Color(0xFF06250F),
        secondary: AppThemeTokens.secondary,
        onSecondary: Color(0xFF032433),
        tertiary: AppThemeTokens.accent,
        onTertiary: Color(0xFF2F1900),
        error: AppThemeTokens.error,
        onError: Color(0xFF2A0807),
        surface: AppThemeTokens.surface,
        onSurface: AppThemeTokens.text,
      ),
      scaffoldBackgroundColor: AppThemeTokens.bg,
      dividerColor: AppThemeTokens.border,
    );

    final textTheme = GoogleFonts.ibmPlexSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: AppThemeTokens.text,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        height: 1.2,
        color: AppThemeTokens.text,
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppThemeTokens.text,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppThemeTokens.text,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: AppThemeTokens.text,
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppThemeTokens.text,
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppThemeTokens.textMuted,
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      labelMedium: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.45,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppThemeTokens.surface,
        foregroundColor: AppThemeTokens.text,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: AppThemeTokens.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppThemeTokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          side: const BorderSide(color: AppThemeTokens.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppThemeTokens.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeTokens.surfaceRaised,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          borderSide: const BorderSide(color: AppThemeTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          borderSide: const BorderSide(color: AppThemeTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          borderSide: const BorderSide(color: AppThemeTokens.secondary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          borderSide: const BorderSide(color: AppThemeTokens.error),
        ),
        hintStyle: textTheme.bodySmall,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppThemeTokens.secondary,
          foregroundColor: const Color(0xFF032433),
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(88, 38),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppThemeTokens.surfaceRaised,
          foregroundColor: AppThemeTokens.text,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(88, 38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
            side: const BorderSide(color: AppThemeTokens.border),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppThemeTokens.text,
          textStyle: textTheme.labelLarge,
          side: const BorderSide(color: AppThemeTokens.border),
          minimumSize: const Size(88, 38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppThemeTokens.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          side: const BorderSide(color: AppThemeTokens.border),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppThemeTokens.surfaceRaised,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          side: const BorderSide(color: AppThemeTokens.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppThemeTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          side: const BorderSide(color: AppThemeTokens.border),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppThemeTokens.surface,
        modalBarrierColor: Color(0xD9080D11),
      ),
    );
  }
}
