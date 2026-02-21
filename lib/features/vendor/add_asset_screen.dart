import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eqp_rent/core/services/equipment_service.dart';
import 'package:eqp_rent/core/services/equipment_types_service.dart';
import 'package:eqp_rent/core/services/vendor_service.dart';
import 'package:eqp_rent/core/services/file_service.dart';
import 'package:eqp_rent/core/widgets/logout_icon_button.dart';
import 'package:image_picker/image_picker.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _conditionNotesController = TextEditingController();
  final _locationController = TextEditingController();
  final _rentalRatePerDayController = TextEditingController();
  final _rentalRatePerWeekController = TextEditingController();
  
  final _equipmentService = EquipmentService();
  final _equipmentTypesService = EquipmentTypesService();
  final _vendorService = VendorService();
  final _fileService = FileService();
  final _imagePicker = ImagePicker();

  int? _selectedYear;
  final List<XFile> _photoFiles = [];
  final List<String> _uploadedPhotoPaths = [];
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  List<Map<String, dynamic>> _equipmentTypes = [];
  bool _loadingTypes = true;

  @override
  void initState() {
    super.initState();
    _loadEquipmentTypes();
  }

  Future<void> _loadEquipmentTypes() async {
    try {
      final types = await _equipmentTypesService.getEquipmentTypes();
      setState(() {
        _equipmentTypes = types;
        _loadingTypes = false;
      });
    } catch (e) {
      developer.log('Error loading equipment types: $e', name: 'AddAsset');
      setState(() {
        _loadingTypes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading equipment types: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _registrationNumberController.dispose();
    _serialNumberController.dispose();
    _conditionNotesController.dispose();
    _locationController.dispose();
    _rentalRatePerDayController.dispose();
    _rentalRatePerWeekController.dispose();
    super.dispose();
  }

  Future<void> _selectYear() async {
    final currentYear = DateTime.now().year;
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year of Purchase'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: currentYear - 1950 + 1,
              itemBuilder: (context, index) {
                final year = currentYear - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () {
                    Navigator.pop(context, year);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      setState(() {
        _selectedYear = selectedYear;
      });
    }
  }

  Future<void> _showAddEquipmentTypeDialog() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    final imagePathController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Equipment Type'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: imagePathController,
                    decoration: const InputDecoration(
                      labelText: 'Image Path (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _equipmentTypesService.createEquipmentType(
                      name: nameController.text,
                      category: categoryController.text,
                      description: descriptionController.text.isNotEmpty
                          ? descriptionController.text
                          : null,
                      imagePath: imagePathController.text.isNotEmpty
                          ? imagePathController.text
                          : null,
                    );
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _loadEquipmentTypes();
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isUploadingPhoto = true;
        });

        try {
          // Upload image to server
          final filePath = await _fileService.uploadEquipmentImage(image);
          
          setState(() {
            _photoFiles.add(image);
            _uploadedPhotoPaths.add(filePath);
            _isUploadingPhoto = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo uploaded successfully!')),
            );
          }
        } catch (e) {
          setState(() {
            _isUploadingPhoto = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload photo: $e')),
            );
          }
        }
      }
    } catch (e) {
      developer.log('Error picking image: $e', name: 'AddAsset');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoFiles.removeAt(index);
      _uploadedPhotoPaths.removeAt(index);
    });
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select year of purchase')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get vendor ID from saved vendor data
      final vendorData = await _vendorService.getSavedVendorData();
      if (vendorData == null || vendorData['id'] == null) {
        throw Exception('Vendor ID not found. Please create a vendor profile.');
      }

      final vendorId = vendorData['id'];

      // Create equipment using API with uploaded photo paths
      final result = await _equipmentService.createEquipment(
        assetCategory: _categoryController.text,
        manufacturer: _manufacturerController.text,
        model: _modelController.text,
        yearOfPurchase: _selectedYear!,
        registrationNumber: _registrationNumberController.text,
        serialNumber: _serialNumberController.text.isNotEmpty ? _serialNumberController.text : null,
        photoFront: _uploadedPhotoPaths.isNotEmpty ? _uploadedPhotoPaths[0] : null,
        photoSide: _uploadedPhotoPaths.length > 1 ? _uploadedPhotoPaths[1] : null,
        photoPlate: _uploadedPhotoPaths.length > 2 ? _uploadedPhotoPaths[2] : null,
        additionalPhotos: _uploadedPhotoPaths.length > 3 ? _uploadedPhotoPaths.sublist(3).join(',') : null,
        conditionNotes: _conditionNotesController.text.isNotEmpty ? _conditionNotesController.text : null,
        location: _locationController.text,
        rentalRatePerDay: _rentalRatePerDayController.text.isNotEmpty ? double.tryParse(_rentalRatePerDayController.text) : null,
        rentalRatePerWeek: _rentalRatePerWeekController.text.isNotEmpty ? double.tryParse(_rentalRatePerWeekController.text) : null,
        isAvailable: true,
        vendorId: vendorId,
      );

      developer.log('Equipment created: $result', name: 'Equipment');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipment added successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      developer.log('Error creating equipment: $e', name: 'Equipment');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eqp Rent - Add Asset'),
        backgroundColor: Colors.green,
        actions: [
          const LogoutIconButton(),
        ],
      ),
      body: _loadingTypes
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Asset Category with Add Button
                  Row(
                    children: [
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _equipmentTypes.map((e) => e['name'] as String);
                            }
                            return _equipmentTypes
                                .map((e) => e['name'] as String)
                                .where((String option) {
                              return option
                                  .toLowerCase()
                                  .contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            _categoryController.text = selection;
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Asset Category *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                                hintText: 'Search or select category',
                              ),
                              onChanged: (value) {
                                _categoryController.text = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showAddEquipmentTypeDialog,
                        icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                        tooltip: 'Add New Equipment Type',
                      ),
                    ],
                  ),
            const SizedBox(height: 16),

            // Manufacturer
            TextFormField(
              controller: _manufacturerController,
              decoration: const InputDecoration(
                labelText: 'Manufacturer (Brand) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter manufacturer';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Model
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter model';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Year of Purchase
            InkWell(
              onTap: _selectYear,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Year of Purchase *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedYear?.toString() ?? 'Select Year',
                  style: TextStyle(
                    color: _selectedYear == null ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Registration Number
            TextFormField(
              controller: _registrationNumberController,
              decoration: const InputDecoration(
                labelText: 'Registration Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter registration number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Serial Number (Optional)
            TextFormField(
              controller: _serialNumberController,
              decoration: const InputDecoration(
                labelText: 'Serial Number (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),

            // Equipment Photos
            const Text(
              'Equipment Photos (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add photos (Front, Side, Plate)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (_photoFiles.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoFiles.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FutureBuilder<Uint8List>(
                              future: _photoFiles[index].readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: InkWell(
                            onTap: () => _removePhoto(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isUploadingPhoto ? null : _pickImage,
              icon: _isUploadingPhoto 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate),
              label: Text(_isUploadingPhoto ? 'Uploading...' : 'Add Photo'),
            ),
            const SizedBox(height: 16),

            // Condition/Notes (Optional)
            TextFormField(
              controller: _conditionNotesController,
              decoration: const InputDecoration(
                labelText: 'Condition/Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: '500084',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Rental Rate Per Day (Optional)
            TextFormField(
              controller: _rentalRatePerDayController,
              decoration: const InputDecoration(
                labelText: 'Rental Rate Per Day (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Rental Rate Per Week (Optional)
            TextFormField(
              controller: _rentalRatePerWeekController,
              decoration: const InputDecoration(
                labelText: 'Rental Rate Per Week (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAsset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save Asset',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}