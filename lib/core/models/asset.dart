class Asset {
  final String? id;
  final String category;
  final String manufacturer;
  final String model;
  final int yearOfPurchase;
  final String registrationNumber;
  final String? serialNumber;
  final List<String> photoUrls;
  final String? conditionNotes;
  final String location;
  final double? rentalRatePerDay;
  final double? rentalRatePerWeek;

  Asset({
    this.id,
    required this.category,
    required this.manufacturer,
    required this.model,
    required this.yearOfPurchase,
    required this.registrationNumber,
    this.serialNumber,
    required this.photoUrls,
    this.conditionNotes,
    required this.location,
    this.rentalRatePerDay,
    this.rentalRatePerWeek,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    // Collect all photo URLs from various fields
    List<String> photos = [];
    if (json['photo_front'] != null) photos.add(json['photo_front']);
    if (json['photo_side'] != null) photos.add(json['photo_side']);
    if (json['photo_plate'] != null) photos.add(json['photo_plate']);
    if (json['additional_photos'] != null) {
      if (json['additional_photos'] is List) {
        photos.addAll(List<String>.from(json['additional_photos']));
      }
    }
    
    return Asset(
      id: json['id'],
      category: json['asset_category'] ?? json['category'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      yearOfPurchase: json['year_of_purchase'],
      registrationNumber: json['registration_number'],
      serialNumber: json['serial_number'],
      photoUrls: photos,
      conditionNotes: json['condition_notes'],
      location: json['location'],
      rentalRatePerDay: json['rental_rate_per_day']?.toDouble(),
      rentalRatePerWeek: json['rental_rate_per_week']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'manufacturer': manufacturer,
      'model': model,
      'year_of_purchase': yearOfPurchase,
      'registration_number': registrationNumber,
      if (serialNumber != null) 'serial_number': serialNumber,
      'photo_urls': photoUrls,
      if (conditionNotes != null) 'condition_notes': conditionNotes,
      'location': location,
      if (rentalRatePerDay != null) 'rental_rate_per_day': rentalRatePerDay,
      if (rentalRatePerWeek != null) 'rental_rate_per_week': rentalRatePerWeek,
    };
  }
}
