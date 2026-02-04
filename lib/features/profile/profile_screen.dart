import 'package:flutter/material.dart';
import 'package:equip_verse/core/services/auth_service.dart';
import 'package:equip_verse/core/services/user_service.dart';
import 'package:equip_verse/core/services/rental_service.dart';
import 'package:equip_verse/core/models/user.dart';
import 'package:equip_verse/core/models/rental_request.dart';
import 'package:intl/intl.dart';
import 'package:equip_verse/ui/screens/login_screen.dart';
import 'package:equip_verse/features/profile/rental_request_detail_screen.dart';
import 'package:equip_verse/core/widgets/logout_icon_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = AuthService();
  final userService = UserService();
  final rentalService = RentalService();
  
  User? currentUser;
  List<RentalRequest>? rentalRequests;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final user = await userService.getCurrentUser();
      final requests = await rentalService.getRentalRequestsByUserId(user.id);
      
      setState(() {
        currentUser = user;
        rentalRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            const LogoutIconButton(),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details', icon: Icon(Icons.person)),
              Tab(text: 'Request History', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    children: [
                      _buildProfileTab(),
                      _buildRequestHistoryTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildProfileTab() {
    if (currentUser == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showEditProfileDialog(),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await authService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.phone, 'Phone', currentUser!.phoneNumber),
            if (currentUser!.fullName != null) ...[
              const Divider(),
              _buildInfoRow(Icons.person, 'Full Name', currentUser!.fullName!),
            ],
            if (currentUser!.email != null) ...[
              const Divider(),
              _buildInfoRow(Icons.email, 'Email', currentUser!.email!),
            ],
            if (currentUser!.companyName != null) ...[
              const Divider(),
              _buildInfoRow(Icons.business, 'Company', currentUser!.companyName!),
            ],
            if (currentUser!.address != null) ...[
              const Divider(),
              _buildInfoRow(Icons.location_on, 'Address', currentUser!.address!),
            ],
            if (currentUser!.city != null || currentUser!.state != null) ...[
              const Divider(),
              _buildInfoRow(
                Icons.location_city,
                'City, State',
                '${currentUser!.city ?? ''}, ${currentUser!.state ?? ''}'.trim(),
              ),
            ],
            if (currentUser!.zipCode != null) ...[
              const Divider(),
              _buildInfoRow(Icons.pin_drop, 'ZIP Code', currentUser!.zipCode!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestHistoryTab() {
    if (rentalRequests == null || rentalRequests!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No rental requests yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: rentalRequests!.length,
        itemBuilder: (context, index) {
          final request = rentalRequests![index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(RentalRequest request) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    Color statusColor;
    IconData statusIcon;
    
    switch (request.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'quoted':
        statusColor = Colors.blue;
        statusIcon = Icons.request_quote;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          'Request #${request.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${dateFormat.format(request.startDate)} - ${dateFormat.format(request.endDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  request.zipCode,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (request.reason != null && request.reason!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.reason!.length > 50
                          ? '${request.reason!.substring(0, 50)}...'
                          : request.reason!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (request.desiredPrice != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Budget: \$${request.desiredPrice!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RentalRequestDetailScreen(request: request),
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog() {
    final fullNameController = TextEditingController(text: currentUser?.fullName);
    final emailController = TextEditingController(text: currentUser?.email);
    final companyController = TextEditingController(text: currentUser?.companyName);
    final addressController = TextEditingController(text: currentUser?.address);
    final cityController = TextEditingController(text: currentUser?.city);
    final stateController = TextEditingController(text: currentUser?.state);
    final zipCodeController = TextEditingController(text: currentUser?.zipCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: zipCodeController,
                decoration: const InputDecoration(
                  labelText: 'ZIP Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateProfile({
                'full_name': fullNameController.text.trim(),
                'email': emailController.text.trim(),
                'company_name': companyController.text.trim(),
                'address': addressController.text.trim(),
                'city': cityController.text.trim(),
                'state': stateController.text.trim(),
                'zip_code': zipCodeController.text.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(Map<String, dynamic> updates) async {
    try {
      final updatedUser = await userService.updateUser(currentUser!.id, updates);
      setState(() {
        currentUser = updatedUser;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }
}
