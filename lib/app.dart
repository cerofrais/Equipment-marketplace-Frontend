import 'package:flutter/material.dart';
import 'package:eqp_rent/core/services/auth_service.dart';
import 'package:eqp_rent/core/theme/theme.dart';
import 'package:eqp_rent/ui/screens/equipment_list_screen.dart';
import 'package:eqp_rent/ui/screens/login_screen.dart';
import 'package:eqp_rent/features/auth/user_type_selection_screen.dart';
import 'package:eqp_rent/features/vendor/vendor_assets_screen.dart';
import 'package:eqp_rent/features/vendor/add_asset_screen.dart';
import 'package:eqp_rent/features/vendor/supplier_onboarding_screen.dart';
import 'package:eqp_rent/features/vendor/supplier_equipment_onboarding_screen.dart';
import 'package:eqp_rent/core/models/organisation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eqp Rent',
      theme: appTheme,
      darkTheme: appTheme, // Using the same theme for both light and dark mode
      themeMode: ThemeMode.dark, // Force dark mode
      home: const AuthChecker(),
      routes: {
        '/user-type-selection': (context) => const UserTypeSelectionScreen(),
        '/equipment-list': (context) => const EquipmentListScreen(),
        '/vendor-assets': (context) => const VendorAssetsScreen(),
        '/add-asset': (context) => const AddAssetScreen(),
        '/supplier-onboarding': (context) => const SupplierOnboardingScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes that need arguments
        if (settings.name == '/supplier-equipment-onboarding') {
          final args = settings.arguments as Organisation?;
          return MaterialPageRoute(
            builder: (context) => SupplierEquipmentOnboardingScreen(organisation: args),
          );
        }
        return null;
      },
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final _authService = AuthService();
  late Future<bool> _isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = _authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data!) {
          return const UserTypeSelectionScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
