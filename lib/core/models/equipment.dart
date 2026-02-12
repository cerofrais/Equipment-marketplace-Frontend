class Equipment {
  final String id;
  final String name;
  final String category;
  final String description;
  final String image;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.image,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image_url']?.toString() ?? 'assets/images/placeholder.png', // Use API image URL or fallback to local
    );
  }
}
