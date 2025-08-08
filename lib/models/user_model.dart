import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'user' or 'admin'
  final DateTime createdAt;
  final List<String> favorites;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.favorites = const [],
    this.avatarUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      favorites: List<String>.from(data['favorites'] ?? []),
      avatarUrl: data['avatarUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'favorites': favorites,
      'avatarUrl': avatarUrl,
    };
  }

  UserModel copyWith({
    String? name,
    List<String>? favorites,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role,
      createdAt: createdAt,
      favorites: favorites ?? this.favorites,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
