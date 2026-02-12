import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eqp_rent/core/services/auth_service.dart';
import 'package:eqp_rent/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _authService.sendOtp(_phoneController.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      context.go('/otp', extra: _phoneController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://picsum.photos/seed/equipment/300/200', 
                  height: 200,
                ),
                const SizedBox(height: 40),
                ColorFiltered(
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
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    children: [
                      const TextSpan(text: 'eqp '),
                      TextSpan(
                        text: 'Rent',
                        style: TextStyle(color: AppColors.primaryAction),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'Login to continue renting equipment',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _sendOtp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Send OTP'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
