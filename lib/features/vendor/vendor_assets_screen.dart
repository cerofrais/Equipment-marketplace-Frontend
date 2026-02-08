import 'package:flutter/material.dart';
import 'package:equip_verse/core/models/asset.dart';
import 'package:equip_verse/core/services/vendor_service.dart';
import 'package:equip_verse/core/widgets/logout_icon_button.dart';
import 'package:equip_verse/features/vendor/vendor_profile_screen.dart';

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
        return _AssetCard(asset: asset);
      },
    );
  }
}

class _AssetCard extends StatelessWidget {
  final Asset asset;

  const _AssetCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to asset details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: asset.photoUrls.isNotEmpty
                    ? Image.network(
                        asset.photoUrls.first,
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
