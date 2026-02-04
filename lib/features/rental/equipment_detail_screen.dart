import 'package:flutter/material.dart';
import 'package:equip_verse/core/models/equipment.dart';
import 'package:equip_verse/features/rental/rental_request_form_screen.dart';
import 'package:equip_verse/core/widgets/equipment_image.dart';
import 'package:equip_verse/core/widgets/profile_icon_button.dart';
import 'package:equip_verse/core/widgets/logout_icon_button.dart';

class EquipmentDetailScreen extends StatelessWidget {
  final Equipment equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ProfileIconButton(),
        title: Text(equipment.name),
        actions: [
          const LogoutIconButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: EquipmentImage(
                imagePath: equipment.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(equipment.name, style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(equipment.category, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              equipment.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RentalRequestFormScreen(equipment: equipment),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // full width
              ),
              child: const Text('Rent Now'),
            ),
          ],
        ),
      ),
    );
  }
}
