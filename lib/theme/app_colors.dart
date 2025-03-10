import 'package:flutter/material.dart';

// 항목은 변경하지 말 것.

class AppColors {
  // Core Colors
  static const primary = Color(0xFFFFD700);
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFFBBDEFB); // 더 연한 primary
  static const onPrimaryContainer =
      Color(0xFF1976D2); // primaryContainer 위의 텍스트

  static const secondary = Color(0xFF03A9F4);
  static const onSecondary = Colors.white;
  static const secondaryContainer = Color(0xFFB3E5FC); // 더 연한 secondary
  static const onSecondaryContainer =
      Color(0xFF0288D1); // secondaryContainer 위의 텍스트

  // Surface Colors
  static const surface = Color(0xFFFAFAFA); // 이전의 background
  static const onSurface = Color(0xFF212121); // 이전의 text
  static const surfaceVariant = Color(0xFFEEEEEE); // surface의 변형
  static const onSurfaceVariant = Color(0xFF757575); // 이전의 textLight

  // Additional Colors
  static const outline = Color(0xFFBDBDBD); // 경계선
  static const outlineVariant = Color(0xFFE0E0E0); // 연한 경계선

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFE53935);
  static const onError = Colors.white;
  static const info = Color(0xFF2196F3);
}
