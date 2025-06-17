enum FestivalCategory {
  religious,
  national,
  cultural,
  seasonal,
}

class Festival {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final FestivalCategory category;
  final List<String> nepaliWishes;
  final List<String> englishWishes;
  final List<String> cardImageUrls;
  final DateTime date;

  Festival({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.nepaliWishes,
    required this.englishWishes,
    required this.cardImageUrls,
    required this.date,
  });

  // Convert Festival to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.index,
      'nepaliWishes': nepaliWishes,
      'englishWishes': englishWishes,
      'cardImageUrls': cardImageUrls,
      'date': date.millisecondsSinceEpoch,
    };
  }

  // Create Festival from JSON
  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: FestivalCategory.values[json['category']],
      nepaliWishes: List<String>.from(json['nepaliWishes']),
      englishWishes: List<String>.from(json['englishWishes']),
      cardImageUrls: List<String>.from(json['cardImageUrls']),
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    );
  }
}
