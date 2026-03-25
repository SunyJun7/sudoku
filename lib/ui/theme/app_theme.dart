import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFAFAFA);
  static const Color givenNumber = Color(0xFF212121);
  static const Color userNumber = Color(0xFF1565C0);
  static const Color errorBackground = Color(0xFFFFCDD2);
  static const Color errorNumber = Color(0xFFD32F2F);
  static const Color selectedBackground = Color(0xFFBBDEFB);
  static const Color highlightBackground = Color(0xFFE3F2FD);
  static const Color boxBorder = Color(0xFF424242);
  static const Color gridBorder = Color(0xFFBDBDBD);
  static const Color primaryButton = Color(0xFF1976D2);
  static const Color primaryButtonText = Color(0xFFFFFFFF);

  /// 마지막으로 입력한 셀 강조 색상 (연한 초록)
  static const Color lastPlacedColor = Color(0xFFC8E6C9);
}

class AppTextStyles {
  AppTextStyles._();

  /// 셀 숫자 크기 (20sp)
  static const double cellNumber = 20.0;

  /// 숫자 패드 숫자 크기 (28sp)
  static const double numberPad = 28.0;

  /// 버튼 텍스트 크기 (20sp)
  static const double button = 20.0;

  /// 화면 제목 크기 (28sp)
  static const double title = 28.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryButton,
        surface: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.givenNumber,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.givenNumber,
          fontSize: AppTextStyles.title,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: AppColors.primaryButtonText,
          textStyle: const TextStyle(
            fontSize: AppTextStyles.button,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(120, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryButton,
          textStyle: const TextStyle(
            fontSize: AppTextStyles.button,
            fontWeight: FontWeight.w500,
          ),
          minimumSize: const Size(80, 48),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppTextStyles.title,
          fontWeight: FontWeight.bold,
          color: AppColors.givenNumber,
        ),
        titleLarge: TextStyle(
          fontSize: AppTextStyles.title,
          fontWeight: FontWeight.bold,
          color: AppColors.givenNumber,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTextStyles.button,
          color: AppColors.givenNumber,
        ),
        labelLarge: TextStyle(
          fontSize: AppTextStyles.button,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryButtonText,
        ),
      ),
    );
  }
}
