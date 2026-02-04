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
    return RentalRequest(
      id: json['id'],
      userId: json['user_id'],
      equipmentTypeId: json['equipment_type_id'],
      zipCode: json['zip_code'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      details: json['details'],
      desiredPrice: json['desired_price'] != null ? double.tryParse(json['desired_price'].toString()) : null,
      reason: json['reason'],
    );
  }
}
