import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:eqp_rent/core/services/vendor_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorProfileCreationScreen extends StatefulWidget {
  const VendorProfileCreationScreen({super.key});

  @override
  State<VendorProfileCreationScreen> createState() => _VendorProfileCreationScreenState();
}

class _VendorProfileCreationScreenState extends State<VendorProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vendorService = VendorService();
  
  final _businessNameController = TextEditingController();
  final _pocNameController = TextEditingController();
  final _pocContactController = TextEditingController(text: '+91');
  final _whatsappNumberController = TextEditingController(text: '+91');
  final _gstNumberController = TextEditingController();
  final _gstAddressController = TextEditingController();
  final _extraDetailsController = TextEditingController();
  final _warehouseZipController = TextEditingController();
  final _serviceRadiusController = TextEditingController(text: '50');
  
  bool _isLoading = false;
  String? _loginPhone;
  String _whatsappSelection = 'custom'; // 'custom', 'poc', 'login'
  bool _useSameAsLoginForPOC = false;

  @override
  void initState() {
    super.initState();
    _loadLoginPhone();
  }

  Future<void> _loadLoginPhone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginPhone = prefs.getString('phone_number');
    });
  }

  void _updateWhatsappNumber() {
    if (_whatsappSelection == 'poc') {
      _whatsappNumberController.text = _pocContactController.text;
    } else if (_whatsappSelection == 'login' && _loginPhone != null) {
      _whatsappNumberController.text = _loginPhone!;
    }
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _vendorService.createVendorProfile(
          businessName: _businessNameController.text,
          pocName: _pocNameController.text,
          pocContactNumber: _pocContactController.text,
          whatsappNumber: _whatsappNumberController.text,
          gstNumber: _gstNumberController.text.isNotEmpty ? _gstNumberController.text : null,
          gstRegisteredAddress: _gstAddressController.text.isNotEmpty ? _gstAddressController.text : null,
          extraDetails: _extraDetailsController.text.isNotEmpty ? _extraDetailsController.text : null,
          warehouseZipCode: _warehouseZipController.text,
          serviceRadiusKm: int.tryParse(_serviceRadiusController.text) ?? 50,
        );

        developer.log('Vendor Profile Created: $result', name: 'VendorProfile');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vendor profile created successfully!')),
          );
          // Navigate to vendor assets screen
          Navigator.pushReplacementNamed(context, '/vendor-assets');
        }
      } catch (e) {
        developer.log('Error creating vendor profile: $e', name: 'VendorProfile');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Vendor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tell us about your business',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide your business details to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              
              // Business Name
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  hintText: 'Enter your business name',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // POC Name
              TextFormField(
                controller: _pocNameController,
                decoration: const InputDecoration(
                  labelText: 'POC Name',
                  hintText: 'Point of Contact name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter POC name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // POC Contact
              TextFormField(
                controller: _pocContactController,
                decoration: const InputDecoration(
                  labelText: 'POC Contact Number',
                  hintText: '+919876543210',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_useSameAsLoginForPOC,
                onChanged: (value) {
                  if (_whatsappSelection == 'poc') {
                    _updateWhatsappNumber();
                  }
                },
                validator: (value) {
                  if (!_useSameAsLoginForPOC && (value == null || value.isEmpty)) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              
              // Same as Login Checkbox for POC
              if (_loginPhone != null)
                CheckboxListTile(
                  title: Text('Same as Login ($_loginPhone)'),
                  value: _useSameAsLoginForPOC,
                  onChanged: (value) {
                    setState(() {
                      _useSameAsLoginForPOC = value ?? false;
                      if (_useSameAsLoginForPOC && _loginPhone != null) {
                        _pocContactController.text = _loginPhone!;
                        // Also update WhatsApp if it's set to use POC
                        if (_whatsappSelection == 'poc') {
                          _updateWhatsappNumber();
                        }
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: 12),
              
              // WhatsApp Number Selection
              const Text(
                'WhatsApp Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                title: const Text('Same as POC Contact'),
                value: 'poc',
                groupValue: _whatsappSelection,
                onChanged: (value) {
                  setState(() {
                    _whatsappSelection = value!;
                    _updateWhatsappNumber();
                  });
                },
              ),
              if (_loginPhone != null)
                RadioListTile<String>(
                  title: Text('Same as Login (${ _loginPhone})'),
                  value: 'login',
                  groupValue: _whatsappSelection,
                  onChanged: (value) {
                    setState(() {
                      _whatsappSelection = value!;
                      _updateWhatsappNumber();
                    });
                  },
                ),
              RadioListTile<String>(
                title: const Text('Custom Number'),
                value: 'custom',
                groupValue: _whatsappSelection,
                onChanged: (value) {
                  setState(() {
                    _whatsappSelection = value!;
                  });
                },
              ),
              const SizedBox(height: 8),
              
              // WhatsApp Number
              TextFormField(
                controller: _whatsappNumberController,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp Number',
                  hintText: '+919876543211',
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: _whatsappSelection == 'custom',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter WhatsApp number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // GST Number (Optional)
              TextFormField(
                controller: _gstNumberController,
                decoration: const InputDecoration(
                  labelText: 'GST Number (Optional)',
                  hintText: '29ABCDE1234F1Z5',
                  prefixIcon: Icon(Icons.receipt_long),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 20),
              
              // GST Registered Address (Optional)
              TextFormField(
                controller: _gstAddressController,
                decoration: const InputDecoration(
                  labelText: 'GST Registered Address (Optional)',
                  hintText: 'Full registered address',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              
              // Warehouse Location (ZIP)
              TextFormField(
                controller: _warehouseZipController,
                decoration: const InputDecoration(
                  labelText: 'Warehouse ZIP Code',
                  hintText: '500084',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter warehouse ZIP code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Service Radius (km)
              TextFormField(
                controller: _serviceRadiusController,
                decoration: const InputDecoration(
                  labelText: 'Service Radius (km)',
                  hintText: '50',
                  prefixIcon: Icon(Icons.radar),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service radius';
                  }
                  final radius = int.tryParse(value);
                  if (radius == null || radius <= 0) {
                    return 'Please enter a valid radius';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Extra Details (Optional)
              TextFormField(
                controller: _extraDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Extra Details (Optional)',
                  hintText: 'Any additional information',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Create Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
