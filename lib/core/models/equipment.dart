class Equipment {
  final String? id;
  final String? supplierOrgId;
  final String? vendorId; // Legacy field for backward compatibility
  final String? category;
  final String? make;
  final String? model;
  final int? year;
  final String regNumber; // Registration number (unique)
  final String? serialNumber;
  final String? assetCategory; // Legacy text category field
  final String fuelType;
  final String? capacityDescription;
  final List<String> attachmentTypes;
  final double meterHours;
  final String equipmentStatus;
  final bool isAvailable;
  final bool isActive;
  final String? baseCity;
  final String? baseArea;
  final int deployableRadiusKm;
  final String includesOperator; // "YES", "NO", "OPTIONAL"
  final double? ratePerHour;
  final double? ratePerDay;
  final double? ratePerMonth;
  final double? mobilisationCharge;
  final int minRentalDays;
  final String? iotDeviceId;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? payStructure;
  final String? image; // Primary image URL

  Equipment({
    this.id,
    this.supplierOrgId,
    this.vendorId,
    this.category,
    this.make,
    this.model,
    this.year,
    required this.regNumber,
    this.serialNumber,
    this.assetCategory,
    this.fuelType = 'DIESEL',
    this.capacityDescription,
    this.attachmentTypes = const [],
    this.meterHours = 0,
    this.equipmentStatus = 'UNDER_REVIEW',
    this.isAvailable = true,
    this.isActive = true,
    this.baseCity,
    this.baseArea,
    this.deployableRadiusKm = 50,
    this.includesOperator = 'OPTIONAL',
    this.ratePerHour,
    this.ratePerDay,
    this.ratePerMonth,
    this.mobilisationCharge,
    this.minRentalDays = 1,
    this.iotDeviceId,
    this.approvedAt,
    this.approvedBy,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.payStructure,
    this.image,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id']?.toString(),
      supplierOrgId: json['supplier_org_id']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      category: json['category'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      regNumber: json['reg_number'] ?? '',
      serialNumber: json['serial_number'],
      assetCategory: json['asset_category'],
      fuelType: json['fuel_type'] ?? 'DIESEL',
      capacityDescription: json['capacity_description'],
      attachmentTypes: json['attachment_types'] != null
          ? List<String>.from(json['attachment_types'])
          : [],
      meterHours: json['meter_hours'] is String
          ? double.tryParse(json['meter_hours']) ?? 0
          : (json['meter_hours'] as num?)?.toDouble() ?? 0,
      equipmentStatus: json['equipment_status'] ?? 'UNDER_REVIEW',
      isAvailable: json['is_available'] ?? true,
      isActive: json['is_active'] ?? true,
      baseCity: json['base_city'],
      baseArea: json['base_area'],
      deployableRadiusKm: json['deployable_radius_km'] ?? 50,
      includesOperator: json['includes_operator'] ?? 'OPTIONAL',
      ratePerHour: json['rate_per_hour'] is String
          ? double.tryParse(json['rate_per_hour'])
          : (json['rate_per_hour'] as num?)?.toDouble(),
      ratePerDay: json['rate_per_day'] is String
          ? double.tryParse(json['rate_per_day'])
          : (json['rate_per_day'] as num?)?.toDouble(),
      ratePerMonth: json['rate_per_month'] is String
          ? double.tryParse(json['rate_per_month'])
          : (json['rate_per_month'] as num?)?.toDouble(),
      mobilisationCharge: json['mobilisation_charge'] is String
          ? double.tryParse(json['mobilisation_charge'])
          : (json['mobilisation_charge'] as num?)?.toDouble(),
      minRentalDays: json['min_rental_days'] ?? 1,
      iotDeviceId: json['iot_device_id'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      approvedBy: json['approved_by'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      payStructure: json['pay_structure'] != null
          ? (json['pay_structure'] is Map
              ? Map<String, dynamic>.from(json['pay_structure'] as Map)
              : null)
          : null,
      image: json['image_url'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (supplierOrgId != null) 'supplier_org_id': supplierOrgId,
      if (vendorId != null) 'vendor_id': vendorId,
      if (category != null) 'category': category,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      'reg_number': regNumber,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (assetCategory != null) 'asset_category': assetCategory,
      'fuel_type': fuelType,
      if (capacityDescription != null) 'capacity_description': capacityDescription,
      'attachment_types': attachmentTypes,
      'meter_hours': meterHours,
      'equipment_status': equipmentStatus,
      'is_available': isAvailable,
      'is_active': isActive,
      if (baseCity != null) 'base_city': baseCity,
      if (baseArea != null) 'base_area': baseArea,
      'deployable_radius_km': deployableRadiusKm,
      'includes_operator': includesOperator,
      if (ratePerHour != null) 'rate_per_hour': ratePerHour,
      if (ratePerDay != null) 'rate_per_day': ratePerDay,
      if (ratePerMonth != null) 'rate_per_month': ratePerMonth,
      if (mobilisationCharge != null) 'mobilisation_charge': mobilisationCharge,
      'min_rental_days': minRentalDays,
      if (iotDeviceId != null) 'iot_device_id': iotDeviceId,
      if (notes != null) 'notes': notes,
      if (payStructure != null) 'pay_structure': payStructure,
    };
  }

  // Helper getters for display and backward compatibility
  String get displayName {
    final parts = [make, model, category].where((p) => p != null && p.isNotEmpty);
    return parts.isEmpty ? regNumber : parts.join(' ');
  }

  // Backward compatibility getter
  String get name => displayName;

  // Description getter combining capacity and notes
  String get description {
    final parts = [capacityDescription, notes].where((p) => p != null && p.isNotEmpty);
    return parts.isEmpty ? 'No description available' : parts.join(' • ');
  }

  // Get category display name or fallback
  String get categoryDisplay => category ?? assetCategory ?? 'Equipment';

  // Get image with fallback
  String get imageUrl => image ?? 'assets/images/placeholder.png';
}
