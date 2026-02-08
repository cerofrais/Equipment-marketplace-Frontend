import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized color management class that loads colors from JSON config
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Background Colors
  static Color primaryBackground = const Color(0xFF000000);
  static Color secondaryBackground = const Color(0xFF121212);
  static Color tertiaryBackground = const Color(0xFF1F1F1F);

  // Content Colors
  static Color primaryContent = const Color(0xFFFFFFFF);
  static Color secondaryContent = const Color(0xFFAFAFAF);
  static Color tertiaryContent = const Color(0xFF6B6B6B);

  // Action Colors
  static Color primaryAction = const Color(0xFF276EF1);

  // Border Colors
  static Color subtleBorder = const Color(0xFF292929);
  static Color opaqueBorder = const Color(0xFF333333);

  // Status Colors
  static Color successGreen = const Color(0xFF05A35B);
  static Color warningYellow = const Color(0xFFFFC043);
  static Color errorRed = const Color(0xFFE11900);

  // Special Colors
  static Color illustrativeBrown = const Color(0xFF99644C);

  /// Load colors from JSON config file
  static Future<void> loadColorsFromConfig() async {
    try {
      final String response = await rootBundle.loadString('assets/config/theme_config.json');
      final Map<String, dynamic> data = json.decode(response);
      
      if (data.containsKey('colors')) {
        final List<dynamic> colors = data['colors'];
        
        for (var colorConfig in colors) {
          final String element = colorConfig['Element'];
          final String hexCode = colorConfig['HexCode'];
          final Color color = _hexToColor(hexCode);

          switch (element) {
            case 'Primary Background':
              primaryBackground = color;
              break;
            case 'Secondary Background':
              secondaryBackground = color;
              break;
            case 'Tertiary Background':
              tertiaryBackground = color;
              break;
            case 'Primary Content':
              primaryContent = color;
              break;
            case 'Secondary Content':
              secondaryContent = color;
              break;
            case 'Tertiary Content':
              tertiaryContent = color;
              break;
            case 'Primary Action / Safety Blue':
              primaryAction = color;
              break;
            case 'Subtle Border':
              subtleBorder = color;
              break;
            case 'Opaque Border':
              opaqueBorder = color;
              break;
            case 'Success Green':
              successGreen = color;
              break;
            case 'Warning Yellow':
              warningYellow = color;
              break;
            case 'Error Red':
              errorRed = color;
              break;
            case 'Illustrative Brown':
              illustrativeBrown = color;
              break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading theme config: $e');
      // Colors will use default values if config fails to load
    }
  }

  /// Convert hex string to Color
  static Color _hexToColor(String hexCode) {
    hexCode = hexCode.replaceAll('#', '');
    if (hexCode.length == 6) {
      hexCode = 'FF$hexCode'; // Add alpha if not present
    }
    return Color(int.parse(hexCode, radix: 16));
  }
}
