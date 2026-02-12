import 'package:flutter/material.dart';
import 'package:eqp_rent/core/models/asset.dart';
import 'package:eqp_rent/core/services/file_service.dart';
import 'package:eqp_rent/features/vendor/schedule_form_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AssetDetailsScreen extends StatefulWidget {
  final Asset asset;

  const AssetDetailsScreen({super.key, required this.asset});

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  int _currentImageIndex = 0;

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
                    widget.asset.category,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Manufacturer and Model
                  Text(
                    '${widget.asset.manufacturer} - ${widget.asset.model}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
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
                            widget.asset.yearOfPurchase.toString(),
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            Icons.confirmation_number,
                            'Registration Number',
                            widget.asset.registrationNumber,
                          ),
                          if (widget.asset.serialNumber != null) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              context,
                              Icons.numbers,
                              'Serial Number',
                              widget.asset.serialNumber!,
                            ),
                          ],
                          const Divider(height: 24),
                          _buildDetailRow(
                            context,
                            Icons.location_on,
                            'Location',
                            widget.asset.location,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rental Rates
                  if (widget.asset.rentalRatePerDay != null || widget.asset.rentalRatePerWeek != null)
                    Card(
                      elevation: 2,
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
                            if (widget.asset.rentalRatePerDay != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Per Day',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '₹${widget.asset.rentalRatePerDay}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            if (widget.asset.rentalRatePerDay != null && widget.asset.rentalRatePerWeek != null)
                              const SizedBox(height: 8),
                            if (widget.asset.rentalRatePerWeek != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Per Week',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '₹${widget.asset.rentalRatePerWeek}',
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
                  if (widget.asset.conditionNotes != null && widget.asset.conditionNotes!.isNotEmpty)
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
                              widget.asset.conditionNotes!,
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
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleFormScreen(asset: widget.asset),
              ),
            );
            
            if (result == true && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Equipment scheduled successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
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
    );
  }

  Widget _buildImageGallery(FileService fileService) {
    if (widget.asset.photoUrls.isEmpty) {
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
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.asset.photoUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = fileService.getImageUrl(widget.asset.photoUrls[index]);
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
          // Download button overlay
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black.withOpacity(0.6),
              onPressed: () => _downloadCurrentImage(context, fileService),
              child: const Icon(Icons.download, color: Colors.white),
            ),
          ),
        ],
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
  Future<void> _downloadCurrentImage(BuildContext context, FileService fileService) async {
    try {
      // Request permission only on mobile platforms
      if (!kIsWeb) {
        final permission = await _requestPermission();
        if (!permission) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage permission is required to download images'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Show loading indicator
      if (context.mounted) {
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
                Text('Downloading image...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // Download the current image
      if (widget.asset.photoUrls.isEmpty) {
        throw Exception('No images to download');
      }

      final filePath = widget.asset.photoUrls[_currentImageIndex];
      final filename = 'equipverse_${widget.asset.id}_${_currentImageIndex + 1}.jpg';
      
      // Use the new platform-aware download method
      await fileService.downloadAndSaveImage(filePath, filename);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb 
              ? 'Image downloaded to your downloads folder!' 
              : 'Image saved to gallery!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _requestPermission() async {
    if (await Permission.photos.isGranted) {
      return true;
    }

    // For Android 13+ (API 33+), use photos permission
    // For Android 12 and below, use storage permission
    final status = await Permission.photos.request();
    if (status.isGranted) {
      return true;
    }

    // Fallback to storage permission for older Android versions
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }}
