import 'package:flutter/material.dart';
import 'package:eqp_rent/features/profile/profile_screen.dart';

class ProfileIconButton extends StatelessWidget {
  const ProfileIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: IconButton(
        icon: const CircleAvatar(
          radius: 18,
          child: Icon(Icons.person, size: 20),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        tooltip: 'Profile',
      ),
    );
  }
}
