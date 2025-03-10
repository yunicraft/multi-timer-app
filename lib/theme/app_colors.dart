import 'package:flutter/material.dart';

// 항목은 변경하지 말 것.

class AppColors {
  // Core Colors
  static const primary = Color(0xFFFFD700); // 골드 색상
  static const onPrimary = Colors.black; // 골드 위의 텍스트는 검정색
  static const primaryContainer = Color(0xFFF5E49C); // 더 연한 골드
  static const onPrimaryContainer =
      Color(0xFF5F4B00); // primaryContainer 위의 텍스트

  static const secondary = Color(0xFFE6C200); // 더 어두운 골드
  static const onSecondary = Colors.black;
  static const secondaryContainer = Color(0xFFFFF3B0); // 더 연한 secondary
  static const onSecondaryContainer =
      Color(0xFF4D3F00); // secondaryContainer 위의 텍스트

  // Surface Colors
  static const surface = Color(0xFF121212); // 어두운 배경
  static const onSurface = Color(0xFFFFFFFF); // 어두운 배경 위의 텍스트는 흰색
  static const surfaceVariant = Color(0xFF1E1E1E); // surface의 변형 (약간 밝은 어두운 배경)
  static const onSurfaceVariant = Color(0xFFE0E0E0); // 이전의 textLight

  // Additional Colors
  static const outline = Color(0xFF3A3A3A); // 어두운 테마의 경계선
  static const outlineVariant = Color(0xFF2A2A2A); // 더 어두운 경계선

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFE53935);
  static const onError = Colors.white;
  static const info = Color(0xFF2196F3);

  // 추가 색상
  static const gold = Color(0xFFFFD700); // 기본 골드
  static const lightGold = Color(0xFFF5E49C); // 연한 골드
  static const darkGold = Color(0xFFE6C200); // 어두운 골드

  static const darkBackground = Color(0xFF121212); // 기본 어두운 배경
  static const darkSurface = Color(0xFF1E1E1E); // 약간 밝은 어두운 배경
  static const darkCard = Color(0xFF2A2A2A); // 카드 배경
}
