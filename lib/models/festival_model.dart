import 'package:cloud_firestore/cloud_firestore.dart';

class Festival {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
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

  factory Festival.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Festival(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      nepaliWishes: List<String>.from(data['nepaliWishes'] ?? []),
      englishWishes: List<String>.from(data['englishWishes'] ?? []),
      cardImageUrls: List<String>.from(data['cardImageUrls'] ?? []),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'nepaliWishes': nepaliWishes,
      'englishWishes': englishWishes,
      'cardImageUrls': cardImageUrls,
      'date': Timestamp.fromDate(date),
    };
  }
}
