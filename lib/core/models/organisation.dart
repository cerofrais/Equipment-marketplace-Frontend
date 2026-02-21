class Organisation {
  final String? id;
  final String name;
  final String? gstin;
  final String type; // SUPPLIER, BUILDER, PLATFORM
  final String city;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Organisation({
    this.id,
    required this.name,
    this.gstin,
    required this.type,
    required this.city,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Organisation.fromJson(Map<String, dynamic> json) {
    return Organisation(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      gstin: json['gstin'],
      type: json['type'] ?? 'SUPPLIER',
      city: json['city'] ?? '',
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      logoUrl: json['logo_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (gstin != null) 'gstin': gstin,
      'type': type,
      'city': city,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (logoUrl != null) 'logo_url': logoUrl,
      'is_active': isActive,
    };
  }

  // Helper to create a supplier organisation
  factory Organisation.supplier({
    String? id,
    required String name,
    String? gstin,
    required String city,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
    bool isActive = true,
  }) {
    return Organisation(
      id: id,
      name: name,
      gstin: gstin,
      type: 'SUPPLIER',
      city: city,
      address: address,
      phone: phone,
      email: email,
      logoUrl: logoUrl,
      isActive: isActive,
    );
  }
}
