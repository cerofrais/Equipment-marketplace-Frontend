import 'package:flutter/material.dart';
import 'package:eqp_rent/core/services/vendor_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final _vendorService = VendorService();
  Map<String, dynamic>? _vendorData;
  bool _isLoading = true;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _pocNameController = TextEditingController();
  final _pocContactController = TextEditingController();
  final _whatsappNumberController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _gstAddressController = TextEditingController();
  final _extraDetailsController = TextEditingController();
  final _warehouseZipController = TextEditingController();
  final _serviceRadiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVendorProfile();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _pocNameController.dispose();
    _pocContactController.dispose();
    _whatsappNumberController.dispose();
    _gstNumberController.dispose();
    _gstAddressController.dispose();
    _extraDetailsController.dispose();
    _warehouseZipController.dispose();
    _serviceRadiusController.dispose();
    super.dispose();
  }

  Future<void> _loadVendorProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vendorData = await _vendorService.getSavedVendorData();
      if (vendorData != null) {
        setState(() {
          _vendorData = vendorData;
          _populateFields();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields() {
    if (_vendorData != null) {
      _businessNameController.text = _vendorData!['business_name'] ?? '';
      _pocNameController.text = _vendorData!['poc_name'] ?? '';
      _pocContactController.text = _vendorData!['poc_contact_number'] ?? '';
      _whatsappNumberController.text = _vendorData!['whatsapp_number'] ?? '';
      _gstNumberController.text = _vendorData!['gst_number'] ?? '';
      _gstAddressController.text = _vendorData!['gst_registered_address'] ?? '';
      _extraDetailsController.text = _vendorData!['extra_details'] ?? '';
      _warehouseZipController.text = _vendorData!['warehouse_zip_code'] ?? '';
      _serviceRadiusController.text = _vendorData!['service_radius_km']?.toString() ?? '50';
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _populateFields(); // Reset fields if canceling edit
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement update vendor API call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile update coming soon!')),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
        backgroundColor: Colors.green,
        actions: [
          if (!_isEditing && _vendorData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vendorData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No vendor profile found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : _isEditing
                  ? _buildEditForm()
                  : _buildProfileView(),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Text(
                _vendorData!['business_name']?.substring(0, 1).toUpperCase() ?? 'V',
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard('Business Information', [
            _buildInfoRow('Business Name', _vendorData!['business_name']),
            _buildInfoRow('Vendor ID', _vendorData!['id']),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Contact Information', [
            _buildInfoRow('POC Name', _vendorData!['poc_name']),
            _buildInfoRow('POC Contact', _vendorData!['poc_contact_number']),
            _buildInfoRow('WhatsApp', _vendorData!['whatsapp_number']),
          ]),
          const SizedBox(height: 16),
          if (_vendorData!['gst_number'] != null)
            _buildInfoCard('GST Information', [
              _buildInfoRow('GST Number', _vendorData!['gst_number']),
              if (_vendorData!['gst_registered_address'] != null)
                _buildInfoRow('Registered Address', _vendorData!['gst_registered_address']),
            ]),
          const SizedBox(height: 16),
          _buildInfoCard('Location & Service', [
            _buildInfoRow('Warehouse ZIP', _vendorData!['warehouse_zip_code']),
            _buildInfoRow('Service Radius', '${_vendorData!['service_radius_km']} km'),
          ]),
          if (_vendorData!['extra_details'] != null) ...[
            const SizedBox(height: 16),
            _buildInfoCard('Additional Details', [
              _buildInfoRow('Notes', _vendorData!['extra_details']),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pocNameController,
            decoration: const InputDecoration(
              labelText: 'POC Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pocContactController,
            decoration: const InputDecoration(
              labelText: 'POC Contact',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _whatsappNumberController,
            decoration: const InputDecoration(
              labelText: 'WhatsApp Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.message),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _gstNumberController,
            decoration: const InputDecoration(
              labelText: 'GST Number (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.receipt_long),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _gstAddressController,
            decoration: const InputDecoration(
              labelText: 'GST Address (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _warehouseZipController,
            decoration: const InputDecoration(
              labelText: 'Warehouse ZIP',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _serviceRadiusController,
            decoration: const InputDecoration(
              labelText: 'Service Radius (km)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.radar),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _extraDetailsController,
            decoration: const InputDecoration(
              labelText: 'Extra Details (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleEdit,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
