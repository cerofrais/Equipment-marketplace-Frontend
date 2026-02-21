import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eqp_rent/core/models/equipment.dart';
import 'package:eqp_rent/core/widgets/profile_icon_button.dart';
import 'package:eqp_rent/core/widgets/logout_icon_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  List<Equipment> _filteredEquipmentList = [];

  final List<Equipment> _equipmentList = [
    Equipment(
      regNumber: 'EXC001',
      make: 'CAT',
      model: '320',
      category: 'EXCAVATOR',
      image: 'https://picsum.photos/seed/excavator/200/300',
      ratePerDay: 250,
    ),
    Equipment(
      regNumber: 'BUL001',
      make: 'Caterpillar',
      model: 'D6T',
      category: 'OTHER',
      image: 'https://picsum.photos/seed/bulldozer/200/300',
      ratePerDay: 350,
    ),
    Equipment(
      regNumber: 'CRN001',
      make: 'Liebherr',
      model: 'LTM 1350',
      category: 'CRANE',
      image: 'https://picsum.photos/seed/crane/200/300',
      ratePerDay: 500,
    ),
    Equipment(
      regNumber: 'TRC001',
      make: 'John Deere',
      model: '5075E',
      category: 'OTHER',
      image: 'https://picsum.photos/seed/tractor/200/300',
      ratePerDay: 150,
    ),
    Equipment(
      regNumber: 'HRV001',
      make: 'Case IH',
      model: 'Axial-Flow',
      category: 'OTHER',
      image: 'https://picsum.photos/seed/harvester/200/300',
      ratePerDay: 400,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredEquipmentList = _equipmentList;
    _searchController.addListener(_filterEquipment);
  }

  void _filterEquipment() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEquipmentList = _equipmentList.where((equipment) {
        return equipment.name.toLowerCase().contains(query) ||
            (equipment.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _navigateToDetail(Equipment equipment) {
    context.go('/equipment-detail', extra: equipment);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Already on the home screen
        break;
      case 1:
        context.go('/my-rentals');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ProfileIconButton(),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search Equipment...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          const LogoutIconButton(),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: _filteredEquipmentList.length,
        itemBuilder: (context, index) {
          final equipment = _filteredEquipmentList[index];
          return GestureDetector(
            onTap: () => _navigateToDetail(equipment),
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(equipment.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(equipment.name, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(equipment.categoryDisplay, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text('₹${equipment.ratePerDay?.toStringAsFixed(0) ?? "N/A"}/day', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'My Rentals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
