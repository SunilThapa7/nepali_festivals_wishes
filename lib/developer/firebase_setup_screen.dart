import 'package:flutter/material.dart';
import '../utils/firebase_data_uploader.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final uploader = FirebaseDataUploader();
                  await uploader.uploadSampleData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully uploaded festival data!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Upload Sample Data to Firestore'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Note: Make sure you have:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Created Firestore Database'),
                  Text('2. Set up Security Rules'),
                  Text('3. Added proper indexes'),
                  Text('4. Initialized Firebase in the app'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
