import 'package:flutter/material.dart';
import 'package:eqp_rent/core/theme/app_colors.dart';

/// Example widget demonstrating how to use AppColors throughout the app
class ColorUsageExample extends StatelessWidget {
  const ColorUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Uses primaryBackground from theme
      backgroundColor: AppColors.primaryBackground,
      
      appBar: AppBar(
        title: Text(
          'Color Usage Example',
          style: TextStyle(color: AppColors.primaryContent),
        ),
        backgroundColor: AppColors.secondaryBackground,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background Colors Section
            _buildSection(
              'Background Colors',
              [
                _buildColorBox('Primary', AppColors.primaryBackground),
                _buildColorBox('Secondary', AppColors.secondaryBackground),
                _buildColorBox('Tertiary', AppColors.tertiaryBackground),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Content Colors Section
            _buildSection(
              'Content Colors',
              [
                _buildTextExample('Primary Content', AppColors.primaryContent),
                _buildTextExample('Secondary Content', AppColors.secondaryContent),
                _buildTextExample('Tertiary Content', AppColors.tertiaryContent),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action Button Example
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAction,
                  foregroundColor: AppColors.primaryContent,
                ),
                child: const Text('Primary Action Button'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Border Examples
            _buildSection(
              'Borders',
              [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    border: Border.all(color: AppColors.subtleBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Subtle Border',
                      style: TextStyle(color: AppColors.primaryContent),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    border: Border.all(color: AppColors.opaqueBorder, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Opaque Border',
                      style: TextStyle(color: AppColors.primaryContent),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Status Colors
            _buildSection(
              'Status Colors',
              [
                _buildStatusChip('Success', AppColors.successGreen),
                _buildStatusChip('Warning', AppColors.warningYellow),
                _buildStatusChip('Error', AppColors.errorRed),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Card Example
            Card(
              color: AppColors.tertiaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.subtleBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example Card',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This card uses tertiaryBackground with subtle border.',
                      style: TextStyle(color: AppColors.secondaryContent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryContent,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
  
  Widget _buildColorBox(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.opaqueBorder),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color.computeLuminance() > 0.5 
                  ? Colors.black 
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextExample(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: color),
      ),
    );
  }
  
  Widget _buildStatusChip(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
      ),
    );
  }
}
