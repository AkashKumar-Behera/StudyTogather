import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AppUser? _userProfile;
  AppUser? get userProfile => _userProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch Firestore user profile
  Future<void> fetchUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _userProfile = null;
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _userProfile = AppUser.fromMap(doc.data()!, uid);
      } else {
        // Fallback to FirebaseAuth user details
        final u = _auth.currentUser!;
        _userProfile = AppUser(
          uid: u.uid,
          email: u.email ?? '',
          displayName: u.displayName ?? (u.email?.split('@').first ?? 'Friend'),
          photoUrl: u.photoURL,
          createdAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  // Sign In with Email and Password
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await fetchUserProfile();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFriendlyErrorMessage(e.code, e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  // Register with Email, Password, Name and Profile Photo
  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // 1. Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User creation failed');

      String? photoUrl;

      // 2. Upload avatar to Firebase Storage if provided
      if (imageBytes != null) {
        final ext = imageExtension ?? 'jpg';
        final ref = _storage.ref().child('user_avatars/${user.uid}/avatar.$ext');
        final metadata = SettableMetadata(contentType: 'image/$ext');
        final uploadTask = await ref.putData(imageBytes, metadata);
        photoUrl = await uploadTask.ref.getDownloadURL();
      }

      // 3. Update Firebase Auth profile
      await user.updateDisplayName(displayName.trim());
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await user.reload();

      // 4. Save User document to Cloud Firestore
      final appUser = AppUser(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
      _userProfile = appUser;

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFriendlyErrorMessage(e.code, e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  // Send Password Reset Email
  Future<bool> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFriendlyErrorMessage(e.code, e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _userProfile = null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  String _getFriendlyErrorMessage(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please verify and try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address entered is not valid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Console.';
      default:
        return defaultMessage ?? 'Authentication failed. Please check your credentials.';
    }
  }
}
