import 'package:flutter/material.dart';
import 'package:eqp_rent/core/models/equipment.dart';
import 'package:eqp_rent/features/rental/rental_request_form_screen.dart';
import 'package:eqp_rent/core/widgets/equipment_image.dart';
import 'package:eqp_rent/core/widgets/profile_icon_button.dart';
import 'package:eqp_rent/core/widgets/logout_icon_button.dart';

class EquipmentDetailScreen extends StatelessWidget {
  final Equipment equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ProfileIconButton(),
        title: Text('eqp Rent - ${equipment.name}'),
        actions: [
          const LogoutIconButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Equipment Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: EquipmentImage(
                imagePath: equipment.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            
            // Equipment Name & Category
            Text(equipment.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  equipment.categoryDisplay,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Basic Details
            if (equipment.make != null || equipment.model != null || equipment.year != null) ...[
              _buildSectionHeader(context, 'Equipment Details'),
              const SizedBox(height: 12),
              _buildInfoCard(context, [
                if (equipment.make != null)
                  _buildInfoRow(Icons.precision_manufacturing, 'Make', equipment.make!),
                if (equipment.model != null)
                  _buildInfoRow(Icons.model_training, 'Model', equipment.model!),
                if (equipment.year != null)
                  _buildInfoRow(Icons.calendar_today, 'Year', equipment.year.toString()),
                if (equipment.capacityDescription != null)
                  _buildInfoRow(Icons.fitness_center, 'Capacity', equipment.capacityDescription!),
                _buildInfoRow(Icons.local_gas_station, 'Fuel Type', equipment.fuelType),
                if (equipment.meterHours > 0)
                  _buildInfoRow(Icons.access_time, 'Meter Hours', '${equipment.meterHours.toStringAsFixed(0)} hrs'),
              ]),
              const SizedBox(height: 16),
            ],
            
            // Location & Coverage
            if (equipment.baseCity != null || equipment.baseArea != null) ...[
              _buildSectionHeader(context, 'Location & Coverage'),
              const SizedBox(height: 12),
              _buildInfoCard(context, [
                if (equipment.baseCity != null)
                  _buildInfoRow(Icons.location_city, 'Base City', equipment.baseCity!),
                if (equipment.baseArea != null)
                  _buildInfoRow(Icons.location_on, 'Base Area', equipment.baseArea!),
                _buildInfoRow(Icons.route, 'Deployable Radius', '${equipment.deployableRadiusKm} km'),
              ]),
              const SizedBox(height: 16),
            ],
            
            // Description
            if (equipment.description.isNotEmpty) ...[
              _buildSectionHeader(context, 'Description'),
              const SizedBox(height: 12),
              Text(
                equipment.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            
            // Pricing Information
            _buildSectionHeader(context, 'Pricing'),
            const SizedBox(height: 12),
            _buildPricingSection(context),
            const SizedBox(height: 16),
            
            // Pay Structure (if available)
            if (equipment.payStructure != null && equipment.payStructure!.isNotEmpty) ...[
              _buildSectionHeader(context, 'Detailed Pay Structure'),
              const SizedBox(height: 12),
              _buildPayStructureSection(context),
              const SizedBox(height: 16),
            ],
            
            // Additional Information
            _buildSectionHeader(context, 'Additional Information'),
            const SizedBox(height: 12),
            _buildInfoCard(context, [
              _buildInfoRow(
                Icons.person,
                'Operator',
                equipment.includesOperator == 'YES'
                    ? 'Included'
                    : equipment.includesOperator == 'NO'
                        ? 'Not Included'
                        : 'Optional',
              ),
              _buildInfoRow(
                Icons.calendar_month,
                'Minimum Rental',
                '${equipment.minRentalDays} ${equipment.minRentalDays == 1 ? 'day' : 'days'}',
              ),
              if (equipment.notes != null && equipment.notes!.isNotEmpty)
                _buildInfoRow(Icons.notes, 'Notes', equipment.notes!),
            ]),
            
            const SizedBox(height: 24),
            
            // Rent Now Button
            ElevatedButton(
              onPressed: equipment.isAvailable
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RentalRequestFormScreen(equipment: equipment),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: equipment.isAvailable ? null : Colors.grey,
              ),
              child: Text(equipment.isAvailable ? 'Rent Now' : 'Currently Unavailable'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context) {
    final List<Widget> priceItems = [];

    if (equipment.ratePerHour != null) {
      priceItems.add(_buildPriceItem(
        context,
        'Hourly Rate',
        equipment.ratePerHour!,
        Icons.access_time,
      ));
    }

    if (equipment.ratePerDay != null) {
      priceItems.add(_buildPriceItem(
        context,
        'Daily Rate',
        equipment.ratePerDay!,
        Icons.calendar_today,
      ));
    }

    if (equipment.ratePerMonth != null) {
      priceItems.add(_buildPriceItem(
        context,
        'Monthly Rate',
        equipment.ratePerMonth!,
        Icons.calendar_month,
      ));
    }

    if (equipment.mobilisationCharge != null) {
      priceItems.add(_buildPriceItem(
        context,
        'Mobilisation Fee',
        equipment.mobilisationCharge!,
        Icons.local_shipping,
      ));
    }

    if (priceItems.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Contact for pricing',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: priceItems,
        ),
      ),
    );
  }

  Widget _buildPriceItem(BuildContext context, String label, double price, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayStructureSection(BuildContext context) {
    final payStructure = equipment.payStructure!;
    
    // Field labels for better display
    final Map<String, String> fieldLabels = {
      'rate_per_hour': 'Rate Per Hour',
      'rate_per_shift': 'Rate Per Shift',
      'rate_per_day': 'Rate Per Day',
      'rate_per_month': 'Rate Per Month',
      'overtime_multiplier': 'Overtime Multiplier',
      'mobilisation_fee': 'Mobilisation Fee',
      'demobilisation_fee': 'Demobilisation Fee',
      'operator_surcharge_per_day': 'Operator Surcharge/Day',
      'min_billing_hours': 'Minimum Billing Hours',
      'idle_rate_per_hour': 'Idle Rate Per Hour',
    };

    final List<Widget> structureItems = [];

    payStructure.forEach((key, value) {
      if (value != null) {
        final label = fieldLabels[key] ?? _formatFieldName(key);
        final isMultiplier = key.contains('multiplier') || key.contains('min_billing_hours');
        final displayValue = isMultiplier 
            ? value.toString()
            : '₹${(value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0).toStringAsFixed(2)}';
        
        structureItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Icon(
                  isMultiplier ? Icons.calculate : Icons.currency_rupee,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    if (structureItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Equipment-Specific Rates',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...structureItems,
          ],
        ),
      ),
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }
}
