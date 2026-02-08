import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:equip_verse/app.dart';
import 'package:equip_verse/core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Load theme colors from JSON config
  await AppColors.loadColorsFromConfig();
  
  runApp(const MyApp());
}
