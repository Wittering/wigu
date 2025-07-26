import 'package:flutter/material.dart';

/// Career Insight Engine Theme
/// A calm, reflective colour palette with black background and two muted tones
class AppTheme {
  // Core colours - black background with two muted tones
  static const Color _backgroundBlack = Color(0xFF000000);
  static const Color _mutedTone1 = Color(0xFF4A5568); // Muted blue-grey
  static const Color _mutedTone2 = Color(0xFF718096); // Lighter muted grey
  
  // Supporting colours for better UX
  static const Color _accentTeal = Color(0xFF4FD1C7); // Soft teal for highlights
  static const Color _warningAmber = Color(0xFFED8936); // Warm amber for warnings
  static const Color _errorRed = Color(0xFFE53E3E); // Soft red for errors
  static const Color _successGreen = Color(0xFF38A169); // Muted green for success
  
  // Text colours
  static const Color _primaryText = Color(0xFFF7FAFC); // Very light grey
  static const Color _secondaryText = Color(0xFFE2E8F0); // Light grey
  static const Color _mutedText = Color(0xFFA0AEC0); // Medium grey
  
  // Career domain colours (muted and professional)
  static const Map<String, Color> careerDomainColours = {
    'technical': Color(0xFF4299E1), // Soft blue
    'leadership': Color(0xFF9F7AEA), // Soft purple
    'creative': Color(0xFFED8936), // Warm orange
    'analytical': Color(0xFF38B2AC), // Teal
    'social': Color(0xFF48BB78), // Soft green
    'entrepreneurial': Color(0xFFED64A6), // Soft pink
    'traditional': Color(0xFF4A5568), // Muted grey
    'investigative': Color(0xFF667EEA), // Soft indigo
  };

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      
      // Colour scheme
      colorScheme: const ColorScheme.dark(
        background: _backgroundBlack,
        surface: _mutedTone1,
        primary: _accentTeal,
        secondary: _mutedTone2,
        tertiary: _accentTeal,
        onBackground: _primaryText,
        onSurface: _primaryText,
        onPrimary: _backgroundBlack,
        onSecondary: _primaryText,
        error: _errorRed,
        onError: _primaryText,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: _backgroundBlack,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundBlack,
        foregroundColor: _primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Text theme - Australian English optimised
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _primaryText,
          fontSize: 32,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: _primaryText,
          fontSize: 28,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          color: _primaryText,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: _primaryText,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: TextStyle(
          color: _primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: TextStyle(
          color: _primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: _primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: _secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: _primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: _secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: _mutedText,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          color: _primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: _secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: _mutedText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: _mutedTone1,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentTeal,
          foregroundColor: _backgroundBlack,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentTeal,
          side: const BorderSide(color: _accentTeal, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _mutedTone1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _mutedTone2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _mutedTone2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accentTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _errorRed, width: 2),
        ),
        hintStyle: const TextStyle(color: _mutedText),
        labelStyle: const TextStyle(color: _secondaryText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: _mutedTone2,
        thickness: 1,
        space: 1,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: _secondaryText,
        size: 24,
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accentTeal,
        foregroundColor: _backgroundBlack,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _accentTeal;
          }
          return _mutedText;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _accentTeal.withOpacity(0.3);
          }
          return _mutedTone2;
        }),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _accentTeal;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(_backgroundBlack),
        side: const BorderSide(color: _mutedTone2, width: 2),
      ),
      
      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _accentTeal;
          }
          return _mutedTone2;
        }),
      ),
      
      // Slider theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: _accentTeal,
        inactiveTrackColor: _mutedTone2,
        thumbColor: _accentTeal,
        overlayColor: Color(0x294FD1C7), // 16% opacity
        valueIndicatorColor: _accentTeal,
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _accentTeal,
        linearTrackColor: _mutedTone2,
        circularTrackColor: _mutedTone2,
      ),
      
      // SnackBar theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _mutedTone1,
        contentTextStyle: TextStyle(color: _primaryText),
        actionTextColor: _accentTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      
      // BottomSheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _mutedTone1,
        modalBackgroundColor: _mutedTone1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      
      // Dialog theme
      dialogTheme: const DialogTheme(
        backgroundColor: _mutedTone1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        titleTextStyle: TextStyle(
          color: _primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        contentTextStyle: TextStyle(
          color: _secondaryText,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  // Helper methods for career-specific colours
  static Color getCareerDomainColour(String domain) {
    return careerDomainColours[domain.toLowerCase()] ?? _mutedTone2;
  }
  
  static Color get backgroundBlack => _backgroundBlack;
  static Color get mutedTone1 => _mutedTone1;
  static Color get mutedTone2 => _mutedTone2;
  static Color get accentTeal => _accentTeal;
  static Color get primaryText => _primaryText;
  static Color get secondaryText => _secondaryText;
  static Color get mutedText => _mutedText;
  static Color get successGreen => _successGreen;
  static Color get warningAmber => _warningAmber;
  static Color get errorRed => _errorRed;
}

/// Career-specific theme with Australian-friendly colors
class CareerTheme {
  // Primary colors for career domains
  static const Color primaryBlue = Color(0xFF4FC3F7);    // Joy & Energy / Strengths  
  static const Color primaryGreen = Color(0xFF4CAF50);   // Values & Impact
  static const Color accentYellow = Color(0xFFFFCA28);   // AI indicators
  static const Color accentOrange = Color(0xFFFF7043);   // Sought For
  static const Color accentPurple = Color(0xFF9C27B0);   // Life Design
  
  // Support colors
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFFBDBDBD);
  
  // Status colors with Australian context
  static const Color statusSuccess = Color(0xFF4CAF50);  // Green for progress
  static const Color statusWarning = Color(0xFFFF9800);  // Amber for attention
  static const Color statusError = Color(0xFFF44336);    // Red for errors
  static const Color statusInfo = Color(0xFF2196F3);     // Blue for information
}