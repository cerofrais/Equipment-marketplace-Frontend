import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eqp_rent/core/services/supplier_service.dart';
import 'package:eqp_rent/core/services/equipment_types_service.dart';
import 'package:eqp_rent/core/services/file_service.dart';
import 'package:eqp_rent/core/models/organisation.dart';
import 'package:image_picker/image_picker.dart';

class SupplierEquipmentOnboardingScreen extends StatefulWidget {
  final Organisation? organisation;

  const SupplierEquipmentOnboardingScreen({
    super.key,
    this.organisation,
  });

  @override
  State<SupplierEquipmentOnboardingScreen> createState() =>
      _SupplierEquipmentOnboardingScreenState();
}

class _SupplierEquipmentOnboardingScreenState
    extends State<SupplierEquipmentOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierService = SupplierService();
  final _equipmentTypesService = EquipmentTypesService();
  final _fileService = FileService();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingTypes = true;
  String? _selectedCategory;
  String? _selectedEquipmentTypeId;
  Map<String, dynamic>? _selectedEquipmentType;
  Map<String, dynamic> _payStructureData = {};
  String _selectedFuelType = 'DIESEL';
  String _selectedOperatorOption = 'OPTIONAL';
  String? _uploadedImageUrl;

  // Equipment types from API
  List<Map<String, dynamic>> _equipmentTypes = [];

  final List<String> _fuelTypes = [
    'DIESEL',
    'PETROL',
    'ELECTRIC',
    'HYBRID',
    'CNG',
  ];

  final List<String> _operatorOptions = [
    'YES',
    'NO',
    'OPTIONAL',
  ];

  // Form controllers
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _meterHoursController = TextEditingController(text: '0');
  final _baseCityController = TextEditingController();
  final _baseAreaController = TextEditingController();
  final _deployableRadiusController = TextEditingController(text: '50');
  final _ratePerHourController = TextEditingController();
  final _ratePerDayController = TextEditingController();
  final _ratePerMonthController = TextEditingController();
  final _mobilisationController = TextEditingController();
  final _minRentalDaysController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEquipmentTypes();
    // Pre-fill base city if organisation has city
    if (widget.organisation?.city != null) {
      _baseCityController.text = widget.organisation!.city;
    }
  }

  Future<void> _loadEquipmentTypes() async {
    try {
      final types = await _equipmentTypesService.getEquipmentTypes();
      setState(() {
        _equipmentTypes = types;
        _isLoadingTypes = false;
      });
    } catch (e) {
      setState(() => _isLoadingTypes = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading equipment types: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onEquipmentTypeSelected(String? equipmentTypeId) async {
    if (equipmentTypeId == null) return;

    setState(() {
      _selectedEquipmentTypeId = equipmentTypeId;
      _isLoading = true;
    });

    try {
      // Fetch full equipment type details including pay structure
      final equipmentType = await _equipmentTypesService.getEquipmentTypeById(equipmentTypeId);
      
      print('════════════════════════════════════════════════════════');
      print('EQUIPMENT TYPE SELECTED: ${equipmentType['name']}');
      print('Full API Response: $equipmentType');
      print('════════════════════════════════════════════════════════');
      
      setState(() {
        _selectedEquipmentType = equipmentType;
        _selectedCategory = equipmentType['category'];
        
        // Initialize pay structure data from template if available
        // Try different possible pay structure paths in the API response
        Map<String, dynamic> payStructureFromApi = {};
        
        // Path 1: equipmentType.pay_structure.pay_structure (nested)
        if (equipmentType['pay_structure'] != null) {
          print('✓ Found pay_structure key in response');
          print('  Type: ${equipmentType['pay_structure'].runtimeType}');
          print('  Value: ${equipmentType['pay_structure']}');
          
          if (equipmentType['pay_structure'] is Map && 
              equipmentType['pay_structure']['pay_structure'] != null) {
            payStructureFromApi = Map<String, dynamic>.from(
              equipmentType['pay_structure']['pay_structure'] as Map
            );
            print('✓ Using nested pay_structure.pay_structure');
            print('  Fields found: ${payStructureFromApi.keys.toList()}');
          }
          // Path 2: equipmentType.pay_structure (direct JSON field)
          else if (equipmentType['pay_structure'] is Map) {
            payStructureFromApi = Map<String, dynamic>.from(
              equipmentType['pay_structure'] as Map
            );
            print('✓ Using direct pay_structure map');
            print('  Fields found: ${payStructureFromApi.keys.toList()}');
          }
        }
        // Path 3: equipmentType.payStructure (camelCase)
        else if (equipmentType['payStructure'] != null) {
          print('✓ Found payStructure (camelCase)');
          payStructureFromApi = Map<String, dynamic>.from(
            equipmentType['payStructure'] as Map
          );
          print('  Fields found: ${payStructureFromApi.keys.toList()}');
        }
        else {
          print('✗ No pay_structure found in API response');
          print('  Available keys: ${equipmentType.keys.toList()}');
        }
        
        _payStructureData = payStructureFromApi;
        print('════════════════════════════════════════════════════════');
        print('FINAL PAY STRUCTURE DATA:');
        print('  Count: ${_payStructureData.length} fields');
        print('  Data: $_payStructureData');
        print('════════════════════════════════════════════════════════');
        
        _isLoading = false;
      });
      
      // Show user feedback
      if (mounted && _payStructureData.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${_payStructureData.length} pay structure fields'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted && _payStructureData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No pay structure defined for this equipment type'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('════════════════════════════════════════════════════════');
      print('ERROR LOADING EQUIPMENT TYPE:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('════════════════════════════════════════════════════════');
      
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _regNumberController.dispose();
    _serialNumberController.dispose();
    _capacityController.dispose();
    _meterHoursController.dispose();
    _baseCityController.dispose();
    _baseAreaController.dispose();
    _deployableRadiusController.dispose();
    _ratePerHourController.dispose();
    _ratePerDayController.dispose();
    _ratePerMonthController.dispose();
    _mobilisationController.dispose();
    _minRentalDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      final imagePath = await _fileService.uploadEquipmentImage(image);

      setState(() {
        _uploadedImageUrl = imagePath;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitEquipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null || _selectedEquipmentTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an equipment type'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supplierService.createEquipment(
        category: _selectedCategory!,
        make: _makeController.text.trim().isEmpty
            ? null
            : _makeController.text.trim(),
        model: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        year: _yearController.text.trim().isEmpty
            ? null
            : int.tryParse(_yearController.text.trim()),
        regNumber: _regNumberController.text.trim(),
        serialNumber: _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
        fuelType: _selectedFuelType,
        capacityDescription: _capacityController.text.trim().isEmpty
            ? null
            : _capacityController.text.trim(),
        meterHours: double.tryParse(_meterHoursController.text.trim()) ?? 0,
        baseCity: _baseCityController.text.trim().isEmpty
            ? null
            : _baseCityController.text.trim(),
        baseArea: _baseAreaController.text.trim().isEmpty
            ? null
            : _baseAreaController.text.trim(),
        deployableRadiusKm: int.tryParse(_deployableRadiusController.text.trim()),
        includesOperator: _selectedOperatorOption,
        ratePerHour: _ratePerHourController.text.trim().isEmpty
            ? null
            : double.tryParse(_ratePerHourController.text.trim()),
        ratePerDay: _ratePerDayController.text.trim().isEmpty
            ? null
            : double.tryParse(_ratePerDayController.text.trim()),
        ratePerMonth: _ratePerMonthController.text.trim().isEmpty
            ? null
            : double.tryParse(_ratePerMonthController.text.trim()),
        mobilisationCharge: _mobilisationController.text.trim().isEmpty
            ? null
            : double.tryParse(_mobilisationController.text.trim()),
        minRentalDays: int.tryParse(_minRentalDaysController.text.trim()) ?? 1,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        imageUrl: _uploadedImageUrl,
        payStructure: _payStructureData.isNotEmpty ? _payStructureData : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipment added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Show dialog asking if they want to add another or finish
      _showCompletionDialog();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equipment Added!'),
        content: const Text('Would you like to add another equipment or finish onboarding?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Add Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/vendor-assets');
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _makeController.clear();
    _modelController.clear();
    _yearController.clear();
    _regNumberController.clear();
    _serialNumberController.clear();
    _capacityController.clear();
    _meterHoursController.text = '0';
    _baseAreaController.clear();
    _deployableRadiusController.text = '50';
    _ratePerHourController.clear();
    _ratePerDayController.clear();
    _ratePerMonthController.clear();
    _mobilisationController.clear();
    _minRentalDaysController.text = '1';
    _notesController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedEquipmentTypeId = null;
      _selectedEquipmentType = null;
      _payStructureData = {};
      _selectedFuelType = 'DIESEL';
      _selectedOperatorOption = 'OPTIONAL';
      _uploadedImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Equipment'),
        centerTitle: true,
      ),
      body: _isLoadingTypes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Your Equipment',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Provide details about your equipment for rental',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Equipment Type Selection
              _buildSectionHeader('Equipment Type'),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedEquipmentTypeId,
                decoration: const InputDecoration(
                  labelText: 'Equipment Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                  helperText: 'Select the type of equipment',
                ),
                items: _equipmentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['id'].toString(),
                    child: Text(type['name'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: _isLoading ? null : _onEquipmentTypeSelected,
                validator: (value) {
                  if (value == null) {
                    return 'Please select an equipment type';
                  }
                  return null;
                },
              ),
              
              if (_selectedEquipmentType != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Category: ${_formatCategoryName(_selectedCategory ?? '')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _payStructureData.isNotEmpty ? Colors.green.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _payStructureData.isNotEmpty ? Colors.green.shade300 : Colors.grey.shade400,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _payStructureData.isNotEmpty ? Icons.check_circle : Icons.info_outline,
                            size: 14,
                            color: _payStructureData.isNotEmpty ? Colors.green.shade700 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _payStructureData.isNotEmpty 
                                ? '${_payStructureData.length} rates'
                                : 'No rates',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _payStructureData.isNotEmpty ? Colors.green.shade700 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Basic Information
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(
                        labelText: 'Make/Brand',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Caterpillar',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 320D',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                        hintText: '2020',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFuelType,
                      decoration: const InputDecoration(
                        labelText: 'Fuel Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _fuelTypes.map((fuel) {
                        return DropdownMenuItem(
                          value: fuel,
                          child: Text(fuel),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedFuelType = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _regNumberController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                  hintText: 'Unique registration number',
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Registration number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(
                  labelText: 'Serial Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity Description',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 20 tonne, 12m working height',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _meterHoursController,
                decoration: const InputDecoration(
                  labelText: 'Meter Hours',
                  border: OutlineInputBorder(),
                  hintText: 'Cumulative engine hours',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),

              // Location Information
              _buildSectionHeader('Location & Coverage'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _baseCityController,
                decoration: const InputDecoration(
                  labelText: 'Base City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _baseAreaController,
                decoration: const InputDecoration(
                  labelText: 'Base Area/Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Specific area or yard location',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _deployableRadiusController,
                decoration: const InputDecoration(
                  labelText: 'Deployable Radius (km)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.route),
                  helperText: 'How far can this equipment be deployed?',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedOperatorOption,
                decoration: const InputDecoration(
                  labelText: 'Includes Operator',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: _operatorOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedOperatorOption = value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Pricing Information
              _buildSectionHeader('Pricing Information (₹)'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ratePerHourController,
                decoration: const InputDecoration(
                  labelText: 'Rate Per Hour',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ratePerDayController,
                decoration: const InputDecoration(
                  labelText: 'Rate Per Day',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ratePerMonthController,
                decoration: const InputDecoration(
                  labelText: 'Rate Per Month',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _mobilisationController,
                decoration: const InputDecoration(
                  labelText: 'Mobilisation Charge',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                  helperText: 'One-time charge for moving equipment to site',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _minRentalDaysController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Rental Days',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),

              // Pay Structure (Dynamic based on equipment type)
              if (_selectedEquipmentType != null) ...[
                _buildSectionHeader('Pay Structure Configuration'),
                const SizedBox(height: 8),
                if (_payStructureData.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Equipment type has ${_payStructureData.length} rate configuration(s). You can customize them below.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPayStructureFields(),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No default pay structure defined for this equipment type. Use the basic pricing fields above.',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],

              // Additional Information
              _buildSectionHeader('Additional Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Any additional details about the equipment',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Image Upload
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickAndUploadImage,
                icon: Icon(_uploadedImageUrl != null
                    ? Icons.check_circle
                    : Icons.add_photo_alternate),
                label: Text(_uploadedImageUrl != null
                    ? 'Image Uploaded'
                    : 'Upload Equipment Image'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: _uploadedImageUrl != null
                      ? Colors.green
                      : null,
                ),
              ),
              if (_uploadedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Image uploaded successfully',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitEquipment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Add Equipment',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildPayStructureFields() {
    // Common pay structure field labels
    final Map<String, String> fieldLabels = {
      'rate_per_hour': 'Rate Per Hour (₹)',
      'rate_per_shift': 'Rate Per Shift (₹)',
      'rate_per_month': 'Rate Per Month (₹)',
      'overtime_multiplier': 'Overtime Multiplier (e.g., 1.5)',
      'mobilisation_fee': 'Mobilisation Fee (₹)',
      'demobilisation_fee': 'Demobilisation Fee (₹)',
      'operator_surcharge_per_day': 'Operator Surcharge Per Day (₹)',
      'min_billing_hours': 'Minimum Billing Hours',
      'idle_rate_per_hour': 'Idle Rate Per Hour (₹)',
    };

    final List<Widget> fields = [];
    
    _payStructureData.forEach((key, value) {
      final label = fieldLabels[key] ?? _formatFieldName(key);
      final isMultiplier = key.contains('multiplier');
      
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            initialValue: value?.toString() ?? '',
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(isMultiplier ? Icons.calculate : Icons.currency_rupee),
              helperText: 'From equipment type template',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              setState(() {
                final parsedValue = isMultiplier 
                    ? double.tryParse(val) 
                    : (val.isEmpty ? null : double.tryParse(val));
                if (parsedValue != null) {
                  _payStructureData[key] = parsedValue;
                } else if (val.isEmpty) {
                  _payStructureData.remove(key);
                }
              });
            },
          ),
        ),
      );
    });

    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fields,
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatCategoryName(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0] + word.substring(1).toLowerCase() : '')
        .join(' ');
  }
}

// Helper formatter for uppercase input
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
