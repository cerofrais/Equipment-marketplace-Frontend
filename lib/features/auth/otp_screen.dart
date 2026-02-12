import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eqp_rent/core/services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    final token = await _authService.verifyOtp(widget.phoneNumber, _otpController.text);

    setState(() {
      _isLoading = false;
    });

    if (token != null) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter OTP sent to ${widget.phoneNumber}'),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    child: const Text('Verify'),
                  ),
          ],
        ),
      ),
    );
  }
}
