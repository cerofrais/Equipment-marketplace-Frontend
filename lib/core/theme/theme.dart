import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eqp_rent/core/theme/app_colors.dart';

// Text theme using Google Fonts
TextTheme get appTextTheme => TextTheme(
  displayLarge: GoogleFonts.oswald(
    fontSize: 57,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryContent,
  ),
  displayMedium: GoogleFonts.oswald(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryContent,
  ),
  displaySmall: GoogleFonts.oswald(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryContent,
  ),
  headlineLarge: GoogleFonts.raleway(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryContent,
  ),
  headlineMedium: GoogleFonts.raleway(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryContent,
  ),
  headlineSmall: GoogleFonts.raleway(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryContent,
  ),
  titleLarge: GoogleFonts.raleway(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryContent,
  ),
  titleMedium: GoogleFonts.raleway(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryContent,
  ),
  titleSmall: GoogleFonts.raleway(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryContent,
  ),
  bodyLarge: GoogleFonts.raleway(
    fontSize: 16,
    color: AppColors.primaryContent,
  ),
  bodyMedium: GoogleFonts.raleway(
    fontSize: 14,
    color: AppColors.primaryContent,
  ),
  bodySmall: GoogleFonts.raleway(
    fontSize: 12,
    color: AppColors.secondaryContent,
  ),
  labelLarge: GoogleFonts.raleway(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryContent,
  ),
  labelMedium: GoogleFonts.raleway(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryContent,
  ),
  labelSmall: GoogleFonts.raleway(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.tertiaryContent,
  ),
);

// App theme using colors from JSON config
ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  
  // Color Scheme
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryAction,
    secondary: AppColors.primaryAction,
    surface: AppColors.secondaryBackground,
    background: AppColors.primaryBackground,
    error: AppColors.errorRed,
    onPrimary: AppColors.primaryContent,
    onSecondary: AppColors.primaryContent,
    onSurface: AppColors.primaryContent,
    onBackground: AppColors.primaryContent,
    onError: AppColors.primaryContent,
    surfaceVariant: AppColors.tertiaryBackground,
    outline: AppColors.subtleBorder,
    outlineVariant: AppColors.opaqueBorder,
  ),
  
  // Scaffold
  scaffoldBackgroundColor: AppColors.primaryBackground,
  
  // Text Theme
  textTheme: appTextTheme,
  
  // AppBar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.secondaryBackground,
    foregroundColor: AppColors.primaryContent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.raleway(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryContent,
    ),
    iconTheme: IconThemeData(color: AppColors.primaryContent),
  ),
  
  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.tertiaryBackground,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppColors.subtleBorder, width: 1),
    ),
  ),
  
  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: AppColors.primaryContent,
      backgroundColor: AppColors.primaryAction,
      disabledForegroundColor: AppColors.tertiaryContent,
      disabledBackgroundColor: AppColors.opaqueBorder,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.bold),
      elevation: 0,
    ),
  ),
  
  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryAction,
      textStyle: GoogleFonts.raleway(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),
  
  // Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryAction,
      side: BorderSide(color: AppColors.primaryAction, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.secondaryBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.opaqueBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.opaqueBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primaryAction, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.errorRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.errorRed, width: 2.0),
    ),
    labelStyle: TextStyle(color: AppColors.secondaryContent),
    hintStyle: TextStyle(color: AppColors.tertiaryContent),
    errorStyle: TextStyle(color: AppColors.errorRed),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  
  // Divider Theme
  dividerTheme: DividerThemeData(
    color: AppColors.subtleBorder,
    thickness: 1,
    space: 1,
  ),
  
  // Icon Theme
  iconTheme: IconThemeData(
    color: AppColors.primaryContent,
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.secondaryBackground,
    selectedItemColor: AppColors.primaryAction,
    unselectedItemColor: AppColors.secondaryContent,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  
  // Dialog Theme
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.tertiaryBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    titleTextStyle: GoogleFonts.raleway(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryContent,
    ),
    contentTextStyle: GoogleFonts.raleway(
      fontSize: 14,
      color: AppColors.primaryContent,
    ),
  ),
  
  // Snackbar Theme
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.tertiaryBackground,
    contentTextStyle: GoogleFonts.raleway(
      fontSize: 14,
      color: AppColors.primaryContent,
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  
  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.secondaryBackground,
    selectedColor: AppColors.primaryAction,
    disabledColor: AppColors.opaqueBorder,
    labelStyle: GoogleFonts.raleway(
      fontSize: 12,
      color: AppColors.primaryContent,
    ),
    secondaryLabelStyle: GoogleFonts.raleway(
      fontSize: 12,
      color: AppColors.primaryContent,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    side: BorderSide(color: AppColors.opaqueBorder),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
