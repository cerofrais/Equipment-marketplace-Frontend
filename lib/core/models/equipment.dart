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
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      image: json['image_url'] ?? 'assets/images/placeholder.png', // Use API image URL or fallback to local
    );
  }
}
