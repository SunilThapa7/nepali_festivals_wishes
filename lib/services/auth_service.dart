import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user model
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    }
    return null;
  }

  // Google Sign-In
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // user aborted
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) return null;

      final DocumentReference<Map<String, dynamic>> userDoc =
          _firestore.collection('users').doc(user.uid);

      final docSnap = await userDoc.get();
      if (!docSnap.exists) {
        final newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          role: 'user',
          createdAt: DateTime.now(),
        );
        await userDoc.set(newUser.toFirestore());
        return newUser;
      } else {
        return UserModel.fromFirestore(docSnap);
      }
    } catch (e) {
      print('Error with Google Sign-In: $e');
      rethrow;
    }
  }

  // Sign up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          id: user.uid,
          email: email,
          name: name,
          role: 'user', // Default role is user
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toFirestore());
        return newUser;
      }
    } catch (e) {
      throw _mapAuthError(e);
    }
    return null;
  }

  // Sign in
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
    } catch (e) {
      throw _mapAuthError(e);
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    List<String>? favorites,
    String? avatarUrl,
  }) async {
    Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (favorites != null) updates['favorites'] = favorites;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    await _firestore.collection('users').doc(userId).update(updates);
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['role'] == 'admin';
    }
    return false;
  }
}

extension on AuthService {
  String _mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'No account found for that email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'operation-not-allowed':
          return 'Sign-in is temporarily unavailable. Please try later.';
        case 'expired-action-code':
        case 'invalid-action-code':
          return 'The link has expired or is invalid.';
        default:
          return error.message ?? 'Authentication error. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
