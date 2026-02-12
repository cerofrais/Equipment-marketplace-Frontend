import 'package:flutter/material.dart';
import 'package:eqp_rent/core/models/asset.dart';
import 'package:eqp_rent/core/services/vendor_service.dart';
import 'package:eqp_rent/core/services/file_service.dart';
import 'package:eqp_rent/core/widgets/logout_icon_button.dart';
import 'package:eqp_rent/features/vendor/vendor_profile_screen.dart';
import 'package:eqp_rent/features/vendor/asset_details_screen.dart';
import 'package:eqp_rent/features/vendor/schedule_list_screen.dart';
import 'package:eqp_rent/features/vendor/schedule_form_screen.dart';

class VendorAssetsScreen extends StatefulWidget {
  const VendorAssetsScreen({super.key});

  @override
  State<VendorAssetsScreen> createState() => _VendorAssetsScreenState();
}

class _VendorAssetsScreenState extends State<VendorAssetsScreen> {
  List<Asset> _assets = [];
  bool _isLoading = false;
  final _vendorService = VendorService();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  void _loadAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get vendor ID from saved vendor data
      final vendorData = await _vendorService.getSavedVendorData();
      if (vendorData == null || vendorData['id'] == null) {
        setState(() {
          _errorMessage = 'Vendor ID not found. Please create a vendor profile.';
          _isLoading = false;
        });
        return;
      }

      final vendorId = vendorData['id'];
      final equipmentList = await _vendorService.getVendorEquipment(vendorId);
      
      setState(() {
        _assets = equipmentList.map((item) => Asset.fromJson(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load equipment: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _navigateToAddAsset() async {
    final result = await Navigator.pushNamed(context, '/add-asset');
    if (result == true) {
      _loadAssets();
    }
  }

  Future<void> _deleteAsset(Asset asset) async {
    // Check if asset has an ID
    if (asset.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete asset: ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Asset'),
          content: Text(
            'Are you sure you want to delete ${asset.manufacturer} ${asset.model}?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Deleting asset...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }

    try {
      await _vendorService.deleteEquipment(asset.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload assets list
        _loadAssets();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete asset: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eqp Rent - My Assets'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.green),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VendorProfileScreen(),
              ),
            );
          },
          tooltip: 'View Profile',
        ),
        actions: [
          const LogoutIconButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _assets.isEmpty
                  ? _buildEmptyState()
                  : _buildAssetsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAsset,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAssets,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No assets yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first asset',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return _AssetCard(
          asset: asset,
          onDelete: () => _deleteAsset(asset),
          onViewSchedule: () => _viewSchedule(asset),
          onScheduleEquipment: () => _scheduleEquipment(asset),
        );
      },
    );
  }

  void _viewSchedule(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleListScreen(asset: asset),
      ),
    );
  }

  void _scheduleEquipment(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleFormScreen(asset: asset),
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onDelete;
  final VoidCallback onViewSchedule;
  final VoidCallback onScheduleEquipment;

  const _AssetCard({
    required this.asset,
    required this.onDelete,
    required this.onViewSchedule,
    required this.onScheduleEquipment,
  });

  @override
  Widget build(BuildContext context) {
    final fileService = FileService();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssetDetailsScreen(asset: asset),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: asset.photoUrls.isNotEmpty
                        ? Image.network(
                            fileService.getImageUrl(asset.photoUrls.first),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                  const SizedBox(width: 16),
                  // Asset details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.category,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${asset.manufacturer} - ${asset.model}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reg: ${asset.registrationNumber}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        if (asset.rentalRatePerDay != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '₹${asset.rentalRatePerDay}/day',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        onViewSchedule();
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('View Schedule'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        onScheduleEquipment();
                      },
                      icon: const Icon(Icons.add_box, size: 18),
                      label: const Text('Schedule'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: Icon(
        Icons.construction,
        size: 40,
        color: Colors.grey[600],
      ),
    );
  }
}
