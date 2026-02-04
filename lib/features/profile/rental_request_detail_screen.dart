import 'package:flutter/material.dart';
import 'package:equip_verse/core/models/rental_request.dart';
import 'package:intl/intl.dart';
import 'package:equip_verse/core/widgets/logout_icon_button.dart';

class RentalRequestDetailScreen extends StatelessWidget {
  final RentalRequest request;

  const RentalRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateTimeFormat = DateFormat('MMM dd, yyyy hh:mm a');
    
    Color statusColor;
    IconData statusIcon;
    String statusDescription;
    
    switch (request.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusDescription = 'Your request is pending and waiting for vendor quotes';
        break;
      case 'quoted':
        statusColor = Colors.blue;
        statusIcon = Icons.request_quote;
        statusDescription = 'Vendors have submitted quotes for your request';
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusDescription = 'You have accepted a quote for this request';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusDescription = 'This request has been rejected or cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusDescription = 'Status unknown';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        actions: [
          const LogoutIconButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Icon(statusIcon, color: statusColor, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Request Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailCard(
                    context,
                    [
                      _DetailItem(
                        icon: Icons.receipt,
                        label: 'Request ID',
                        value: request.id,
                      ),
                      _DetailItem(
                        icon: Icons.category,
                        label: 'Equipment Type ID',
                        value: request.equipmentTypeId,
                      ),
                      _DetailItem(
                        icon: Icons.person,
                        label: 'User ID',
                        value: request.userId,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Rental Period',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailCard(
                    context,
                    [
                      _DetailItem(
                        icon: Icons.calendar_today,
                        label: 'Start Date',
                        value: dateFormat.format(request.startDate),
                      ),
                      _DetailItem(
                        icon: Icons.event,
                        label: 'End Date',
                        value: dateFormat.format(request.endDate),
                      ),
                      _DetailItem(
                        icon: Icons.access_time,
                        label: 'Duration',
                        value: '${request.endDate.difference(request.startDate).inDays} days',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailCard(
                    context,
                    [
                      _DetailItem(
                        icon: Icons.location_on,
                        label: 'ZIP Code',
                        value: request.zipCode,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Timeline',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailCard(
                    context,
                    [
                      _DetailItem(
                        icon: Icons.add_circle,
                        label: 'Created At',
                        value: dateTimeFormat.format(request.createdAt),
                      ),
                    ],
                  ),
                  
                  if (request.reason != null || request.desiredPrice != null) ...[
                    const SizedBox(height: 16),
                    
                    Text(
                      'Additional Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailCard(
                      context,
                      [
                        if (request.desiredPrice != null)
                          _DetailItem(
                            icon: Icons.attach_money,
                            label: 'Budget',
                            value: '\$${request.desiredPrice!.toStringAsFixed(2)}',
                          ),
                        if (request.reason != null)
                          _DetailItem(
                            icon: Icons.description,
                            label: 'Reason for Rental',
                            value: request.reason!,
                          ),
                        if (request.details != null)
                          _DetailItem(
                            icon: Icons.info,
                            label: 'Details',
                            value: request.details!,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, List<_DetailItem> items) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: 24),
                _buildDetailRow(context, item),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, _DetailItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
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

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;

  _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
