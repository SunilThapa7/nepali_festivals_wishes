import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/festival_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  // Get all festivals
  Stream<List<Festival>> getFestivals() {
    return _firestore
        .collection('festivals')
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Festival.fromFirestore(doc)).toList();
    });
  }

  // Get festivals by category
  Stream<List<Festival>> getFestivalsByCategory(String category) {
    return _firestore
        .collection('festivals')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Festival.fromFirestore(doc)).toList();
    });
  }

  // Get upcoming festivals
  Stream<List<Festival>> getUpcomingFestivals() {
    return _firestore
        .collection('festivals')
        .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Festival.fromFirestore(doc)).toList();
    });
  }

  // Add a new festival
  Future<void> addFestival(Festival festival) async {
    await _firestore.collection('festivals').add(festival.toFirestore());
  }

  // Update an existing festival
  Future<void> updateFestival(String festivalId, Festival festival) async {
    await _firestore
        .collection('festivals')
        .doc(festivalId)
        .update(festival.toFirestore());
  }

  // Delete a festival
  Future<void> deleteFestival(String festivalId) async {
    await _firestore.collection('festivals').doc(festivalId).delete();
  }

  // Create a user submission (wish or card)
  Future<void> createSubmission({
    required String userId,
    required String festivalId,
    required String festivalName,
    required String type, // 'wish' or 'card'
    String? language, // 'nepali' | 'english' for wish
    required String value, // wish text or card image URL
  }) async {
    await _firestore.collection('submissions').add({
      'userId': userId,
      'festivalId': festivalId,
      'festivalName': festivalName,
      'type': type,
      'language': language,
      'value': value,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get submissions for a user
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getUserSubmissions(
      String userId) {
    return _firestore
        .collection('submissions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }

  // Admin: get all submissions
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllSubmissions() {
    return _firestore
        .collection('submissions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
