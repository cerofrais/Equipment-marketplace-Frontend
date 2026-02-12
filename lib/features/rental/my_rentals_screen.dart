import 'package:flutter/material.dart';
import 'package:eqp_rent/core/widgets/profile_icon_button.dart';
import 'package:eqp_rent/core/widgets/logout_icon_button.dart';

class MyRentalsScreen extends StatelessWidget {
  const MyRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ProfileIconButton(),
        title: const Text('My Rentals'),
        actions: [
          const LogoutIconButton(),
        ],
      ),
      body: const Center(
        child: Text('You have no rentals yet.'),
      ),
    );
  }
}
