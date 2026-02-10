class Schedule {
  final String? id;
  final String? vendorId;
  final String equipmentId;
  final String startTime;
  final String endTime;
  final String name;
  final String contact;
  final double? price;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Schedule({
    this.id,
    this.vendorId,
    required this.equipmentId,
    required this.startTime,
    required this.endTime,
    required this.name,
    required this.contact,
    this.price,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // Handle price as both string and number
    double? priceValue;
    if (json['price'] != null) {
      if (json['price'] is String) {
        priceValue = double.tryParse(json['price']);
      } else {
        priceValue = json['price']?.toDouble();
      }
    }

    return Schedule(
      id: json['id'],
      vendorId: json['vendor_id'],
      equipmentId: json['equipment_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      name: json['name'],
      contact: json['contact'],
      price: priceValue,
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (vendorId != null) 'vendor_id': vendorId,
      'equipment_id': equipmentId,
      'start_time': startTime,
      'end_time': endTime,
      'name': name,
      'contact': contact,
      if (price != null) 'price': price,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

class AvailabilityCheck {
  final String equipmentId;
  final bool isAvailable;
  final List<Schedule> conflictingSchedules;

  AvailabilityCheck({
    required this.equipmentId,
    required this.isAvailable,
    required this.conflictingSchedules,
  });

  factory AvailabilityCheck.fromJson(Map<String, dynamic> json) {
    List<Schedule> conflicts = [];
    if (json['conflicting_schedules'] != null && json['conflicting_schedules'] is List) {
      conflicts = (json['conflicting_schedules'] as List)
          .map((scheduleJson) => Schedule.fromJson(scheduleJson))
          .toList();
    }

    return AvailabilityCheck(
      equipmentId: json['equipment_id'] ?? '',
      isAvailable: json['is_available'] ?? false,
      conflictingSchedules: conflicts,
    );
  }
}
