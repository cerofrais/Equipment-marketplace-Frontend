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
    if (json['photo_front'] != null && json['photo_front'].toString().isNotEmpty) {
      photos.add(json['photo_front']);
    }
    if (json['photo_side'] != null && json['photo_side'].toString().isNotEmpty) {
      photos.add(json['photo_side']);
    }
    if (json['photo_plate'] != null && json['photo_plate'].toString().isNotEmpty) {
      photos.add(json['photo_plate']);
    }
    if (json['additional_photos'] != null) {
      if (json['additional_photos'] is List) {
        photos.addAll(List<String>.from(json['additional_photos']));
      } else if (json['additional_photos'] is String && json['additional_photos'].toString().isNotEmpty) {
        photos.add(json['additional_photos']);
      }
    }
    
    // Handle rental rates as both string and number
    double? rentalRatePerDayValue;
    if (json['rental_rate_per_day'] != null) {
      if (json['rental_rate_per_day'] is String) {
        rentalRatePerDayValue = double.tryParse(json['rental_rate_per_day']);
      } else if (json['rental_rate_per_day'] is num) {
        rentalRatePerDayValue = (json['rental_rate_per_day'] as num).toDouble();
      }
    }
    
    double? rentalRatePerWeekValue;
    if (json['rental_rate_per_week'] != null) {
      if (json['rental_rate_per_week'] is String) {
        rentalRatePerWeekValue = double.tryParse(json['rental_rate_per_week']);
      } else if (json['rental_rate_per_week'] is num) {
        rentalRatePerWeekValue = (json['rental_rate_per_week'] as num).toDouble();
      }
    }
    
    return Asset(
      id: json['id']?.toString(),
      category: (json['asset_category'] ?? json['category'] ?? '').toString().trim(),
      manufacturer: (json['manufacturer'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      yearOfPurchase: json['year_of_purchase'] is int 
          ? json['year_of_purchase'] 
          : int.tryParse(json['year_of_purchase']?.toString() ?? '0') ?? 0,
      registrationNumber: (json['registration_number'] ?? '').toString(),
      serialNumber: json['serial_number']?.toString(),
      photoUrls: photos,
      conditionNotes: json['condition_notes']?.toString(),
      location: (json['location'] ?? '').toString(),
      rentalRatePerDay: rentalRatePerDayValue,
      rentalRatePerWeek: rentalRatePerWeekValue,
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
