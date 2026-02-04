import 'package:flutter/material.dart';
import 'package:equip_verse/core/models/equipment.dart';
import 'package:equip_verse/core/services/api_service.dart';
import 'package:equip_verse/core/widgets/equipment_image.dart';
import 'package:equip_verse/features/rental/equipment_detail_screen.dart';
import 'package:equip_verse/core/widgets/profile_icon_button.dart';
import 'package:equip_verse/core/widgets/logout_icon_button.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  final _apiService = ApiService();
  late Future<List<Equipment>> _equipmentFuture;

  @override
  void initState() {
    super.initState();
    _equipmentFuture = _apiService.getEquipmentTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ProfileIconButton(),
        title: const Text('Equipment'),
        actions: [
          const LogoutIconButton(),
        ],
      ),
      body: FutureBuilder<List<Equipment>>(
        future: _equipmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No equipment found.'));
          } else {
            final equipment = snapshot.data!;
            return ListView.builder(
              itemCount: equipment.length,
              itemBuilder: (context, index) {
                final item = equipment[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: EquipmentImage(
                        imagePath: item.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item.category),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EquipmentDetailScreen(equipment: item),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
