import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class FirebaseDataUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadSampleData() async {
    try {
      // Read the JSON file
      String jsonString =
          await rootBundle.loadString('firebase_sample_data.json');
      Map<String, dynamic> data = json.decode(jsonString);

      // Get the festivals data
      Map<String, dynamic> festivals = data['festivals'];

      // Upload each festival
      for (var entry in festivals.entries) {
        String festivalId = entry.key;
        Map<String, dynamic> festivalData = entry.value;

        // Convert date string to Timestamp
        String dateStr = festivalData['date'];
        DateTime date = DateTime.parse(dateStr);
        festivalData['date'] = Timestamp.fromDate(date);

        // Upload to Firestore
        await _firestore
            .collection('festivals')
            .doc(festivalId)
            .set(festivalData);

        print('Uploaded festival: ${festivalData['name']}');
      }

      print('Successfully uploaded all festival data to Firestore!');
    } catch (e) {
      print('Error uploading data: $e');
    }
  }

  Future<void> setupIndexes() async {
    try {
      // Note: Composite indexes need to be created manually in the Firebase Console
      print('Please create the following indexes in Firebase Console:');
      print('1. Collection: festivals');
      print('   Fields to index:');
      print('   - category Ascending + date Ascending');
      print('   - date Ascending');
    } catch (e) {
      print('Error setting up indexes: $e');
    }
  }
}
