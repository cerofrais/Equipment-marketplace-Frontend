import 'package:flutter/material.dart';
import 'package:equip_verse/core/models/asset.dart';
import 'package:equip_verse/core/services/file_service.dart';

class AssetDetailsScreen extends StatelessWidget {
  final Asset asset;

  const AssetDetailsScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final fileService = FileService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(fileService),
            
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    asset.category,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Manufacturer and Model
                  Text(
                    '${asset.manufacturer} - ${asset.model}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[800],
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Details Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            context,
                            Icons.calendar_today,
                            'Year of Purchase',
                            asset.yearOfPurchase.toString(),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            Icons.confirmation_number,
                            'Registration Number',
                            asset.registrationNumber,
                          ),
                          if (asset.serialNumber != null) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              context,
                              Icons.numbers,
                              'Serial Number',
                              asset.serialNumber!,
                            ),
                          ],
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            Icons.location_on,
                            'Location',
                            asset.location,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rental Rates
                  if (asset.rentalRatePerDay != null || asset.rentalRatePerWeek != null)
                    Card(
                      elevation: 2,
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rental Rates',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                            ),
                            const SizedBox(height: 12),
                            if (asset.rentalRatePerDay != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Per Day',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '₹${asset.rentalRatePerDay}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            if (asset.rentalRatePerDay != null && asset.rentalRatePerWeek != null)
                              const SizedBox(height: 8),
                            if (asset.rentalRatePerWeek != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Per Week',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '₹${asset.rentalRatePerWeek}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Condition Notes
                  if (asset.conditionNotes != null && asset.conditionNotes!.isNotEmpty)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Condition Notes',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              asset.conditionNotes!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coming Soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Schedule - Coming Soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(FileService fileService) {
    if (asset.photoUrls.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        color: Colors.grey[300],
        child: Icon(
          Icons.construction,
          size: 80,
          color: Colors.grey[600],
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: asset.photoUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = fileService.getImageUrl(asset.photoUrls[index]);
          return Image.network(
            imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[300],
                child: Icon(
                  Icons.construction,
                  size: 80,
                  color: Colors.grey[600],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 20),
        const SizedBox(width: 12),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
