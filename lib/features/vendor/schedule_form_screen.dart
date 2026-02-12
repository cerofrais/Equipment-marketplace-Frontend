import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eqp_rent/core/models/asset.dart';
import 'package:eqp_rent/core/models/schedule.dart';
import 'package:eqp_rent/core/services/schedule_service.dart';
import 'package:intl/intl.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Asset asset;

  const ScheduleFormScreen({super.key, required this.asset});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scheduleService = ScheduleService();
  
  final _customerNameController = TextEditingController();
  final _customerNumberController = TextEditingController();
  final _priceController = TextEditingController();
  
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill price if available from asset
    if (widget.asset.rentalRatePerDay != null) {
      _priceController.text = widget.asset.rentalRatePerDay.toString();
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null && mounted) {
        final dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            _startDateTime = dateTime;
          } else {
            _endDateTime = dateTime;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select Date & Time';
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDateTime == null || _endDateTime == null) {
      _showErrorDialog('Please select both start and end date/time');
      return;
    }

    if (_endDateTime!.isBefore(_startDateTime!)) {
      _showErrorDialog('End date/time must be after start date/time');
      return;
    }

    if (widget.asset.id == null) {
      _showErrorDialog('Equipment ID not found');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Format dates to ISO 8601
      final startTimeStr = _startDateTime!.toUtc().toIso8601String();
      final endTimeStr = _endDateTime!.toUtc().toIso8601String();

      // First, check availability
      final availabilityCheck = await _scheduleService.checkAvailability(
        equipmentId: widget.asset.id!,
        startTime: startTimeStr,
        endTime: endTimeStr,
      );

      if (!availabilityCheck.isAvailable) {
        // Show conflict error with detailed information
        _showConflictDialog(availabilityCheck);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // If available, create the schedule
      final price = _priceController.text.isEmpty 
          ? null 
          : double.tryParse(_priceController.text);

      await _scheduleService.createSchedule(
        equipmentId: widget.asset.id!,
        startTime: startTimeStr,
        endTime: endTimeStr,
        customerContactName: _customerNameController.text,
        customerContactNumber: _customerNumberController.text,
        price: price,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipment scheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to previous screen
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Failed to schedule equipment: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showConflictDialog(AvailabilityCheck availabilityCheck) {
    if (availabilityCheck.conflictingSchedules.isEmpty) {
      _showErrorDialog('Equipment is not available but no conflicting schedules were provided.');
      return;
    }

    // Show all conflicting schedules
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Equipment Not Available'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                availabilityCheck.conflictingSchedules.length == 1
                    ? 'This equipment is already scheduled for the selected time period.'
                    : 'This equipment has ${availabilityCheck.conflictingSchedules.length} conflicting schedules for the selected time period.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Show all conflicting schedules
              ...availabilityCheck.conflictingSchedules.asMap().entries.map((entry) {
                final index = entry.key;
                final conflict = entry.value;
                final startTime = DateFormat('MMM dd, yyyy - hh:mm a')
                    .format(DateTime.parse(conflict.startTime).toLocal());
                final endTime = DateFormat('MMM dd, yyyy - hh:mm a')
                    .format(DateTime.parse(conflict.endTime).toLocal());

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (availabilityCheck.conflictingSchedules.length > 1) ...[
                      Text(
                        'Schedule ${index + 1}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      const Text(
                        'Conflicting Schedule:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Customer: ${conflict.name}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Phone: ${conflict.contact}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('From: $startTime'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('To: $endTime'),
                        ),
                      ],
                    ),
                    if (index < availabilityCheck.conflictingSchedules.length - 1) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Equipment'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Equipment Info Card
                    Card(
                      elevation: 2,
                      color: Colors.grey[800],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Equipment Details',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.asset.category,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            Text(
                              '${widget.asset.manufacturer} - ${widget.asset.model}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            Text(
                              'Reg: ${widget.asset.registrationNumber}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[300],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Start Date & Time
                    Text(
                      'Start Date & Time *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDateTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDateTime(_startDateTime),
                              style: TextStyle(
                                color: _startDateTime == null ? Colors.grey : Colors.white,
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // End Date & Time
                    Text(
                      'End Date & Time *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDateTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDateTime(_endDateTime),
                              style: TextStyle(
                                color: _endDateTime == null ? Colors.grey : Colors.white,
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customer Contact Name
                    Text(
                      'Customer Contact Name *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter customer name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person, color: Colors.green),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Customer Contact Number
                    Text(
                      'Customer Contact Number *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customerNumberController,
                      decoration: InputDecoration(
                        hintText: 'Enter contact number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.phone, color: Colors.green),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contact number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price (Optional)
                    Text(
                      'Price (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        hintText: 'Enter price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.currency_rupee, color: Colors.green),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Schedule Equipment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
