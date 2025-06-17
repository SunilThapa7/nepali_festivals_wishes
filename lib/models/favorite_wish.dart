// Model class for favorite wishes
class FavoriteWish {
  final String id;
  final String festivalId;
  final String festivalName;
  final String wishText;
  final bool isNepali;
  final DateTime dateAdded;

  FavoriteWish({
    required this.id,
    required this.festivalId,
    required this.festivalName,
    required this.wishText,
    required this.isNepali,
    required this.dateAdded,
  });

  // Convert FavoriteWish to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'festivalId': festivalId,
      'festivalName': festivalName,
      'wishText': wishText,
      'isNepali': isNepali,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
    };
  }

  // Create FavoriteWish from JSON
  factory FavoriteWish.fromJson(Map<String, dynamic> json) {
    return FavoriteWish(
      id: json['id'],
      festivalId: json['festivalId'],
      festivalName: json['festivalName'],
      wishText: json['wishText'],
      isNepali: json['isNepali'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(json['dateAdded']),
    );
  }
}
