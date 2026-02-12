import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:eqp_rent/app.dart';
import 'package:eqp_rent/core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Load theme colors from JSON config
  await AppColors.loadColorsFromConfig();
  
  runApp(const MyApp());
}
