import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:equip_verse/core/services/vendor_service.dart';
import 'package:equip_verse/core/theme/app_colors.dart';
import 'package:equip_verse/features/vendor/vendor_profile_creation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  Future<void> _handleVendorSelection(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final vendorService = VendorService();
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phone_number') ?? '14155551002';
      
      // Remove + from phone number for API call
      final cleanPhoneNumber = phoneNumber.replaceAll('+', '');
      
      // Fetch vendor details
      final vendorDetails = await vendorService.getVendorByWhatsapp(cleanPhoneNumber);
      
      if (!context.mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (vendorDetails == null) {
        // No vendor found, navigate to profile creation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorProfileCreationScreen(),
          ),
        );
      } else {
        // Vendor exists, save vendor data and navigate to vendor assets
        await prefs.setString('vendor_data', jsonEncode(vendorDetails));
        await prefs.setString('vendor_id', vendorDetails['id'].toString());
        
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/vendor-assets');
      }
    } catch (e) {
      if (!context.mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    -1, 0, 0, 0, 255,
                    0, -1, 0, 0, 255,
                    0, 0, -1, 0, 255,
                    0, 0, 0, 1, 0,
                  ]),
                  child: Image.asset(
                    'assets/images/eqp_logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  children: [
                    const TextSpan(text: 'Welcome to eqp '),
                    TextSpan(
                      text: 'Rent',
                      style: TextStyle(color: AppColors.primaryAction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please select your account type',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              _UserTypeCard(
                icon: Icons.shopping_bag,
                title: 'Customer',
                subtitle: 'Browse and rent equipment',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/equipment-list');
                },
              ),
              const SizedBox(height: 24),
              _UserTypeCard(
                icon: Icons.business,
                title: 'Vendor',
                subtitle: 'List and manage your equipment',
                color: Colors.green,
                onTap: () => _handleVendorSelection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
