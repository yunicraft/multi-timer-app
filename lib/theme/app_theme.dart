import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// 항목은 변경하지 말 것.

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.notoSansKrTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: AppColors.onSurface),
          displayMedium: TextStyle(color: AppColors.onSurface),
          displaySmall: TextStyle(color: AppColors.onSurface),
          headlineLarge: TextStyle(color: AppColors.onSurface),
          headlineMedium: TextStyle(color: AppColors.onSurface),
          headlineSmall: TextStyle(color: AppColors.onSurface),
          titleLarge: TextStyle(color: AppColors.onSurface),
          titleMedium: TextStyle(color: AppColors.onSurface),
          titleSmall: TextStyle(color: AppColors.onSurface),
          bodyLarge: TextStyle(color: AppColors.onSurface),
          bodyMedium: TextStyle(color: AppColors.onSurface),
          bodySmall: TextStyle(color: AppColors.onSurface),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.onSurface),
        titleTextStyle: GoogleFonts.notoSansKr(
          color: AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

final primaryFontFamily = GoogleFonts.notoSansKr().fontFamily;
final secondaryFontFamily = GoogleFonts.notoSansKr().fontFamily;
