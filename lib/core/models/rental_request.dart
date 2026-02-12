class RentalRequest {
  final String id;
  final String userId;
  final String equipmentTypeId;
  final String zipCode;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;
  final String? details;
  final double? desiredPrice;
  final String? reason;

  RentalRequest({
    required this.id,
    required this.userId,
    required this.equipmentTypeId,
    required this.zipCode,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.details,
    this.desiredPrice,
    this.reason,
  });

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    // Handle desiredPrice as both string and number
    double? desiredPriceValue;
    if (json['desired_price'] != null) {
      if (json['desired_price'] is String) {
        desiredPriceValue = double.tryParse(json['desired_price']);
      } else if (json['desired_price'] is num) {
        desiredPriceValue = (json['desired_price'] as num).toDouble();
      }
    }

    return RentalRequest(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      equipmentTypeId: json['equipment_type_id']?.toString() ?? '',
      zipCode: json['zip_code']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      details: json['details']?.toString(),
      desiredPrice: desiredPriceValue,
      reason: json['reason']?.toString(),
    );
  }
}
