import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hortimize/services/firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Timeouts
  static const Duration _operationTimeout = Duration(seconds: 15);
  static const Duration _firebaseTimeout = Duration(seconds: 20);
  
  // Connectivity checker
  final Connectivity _connectivity = Connectivity();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Check internet connectivity
  Future<bool> _checkConnectivity() async {
    try {
      var result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      // Assume connectivity exists if we can't check
      return true;
    }
  }
  
  // Ensure Firebase is initialized
  Future<void> _ensureFirebaseInitialized() async {
    if (!FirebaseService.isInitialized) {
      try {
        await FirebaseService.initializeFirebase();
      } catch (e) {
        debugPrint('Error initializing Firebase: $e');
        throw Exception('Firebase initialization failed. Please restart the app.');
      }
    }
  }
  
  // Check if user exists in Firestore
  Future<bool> isUserRegistered(String uid) async {
    try {
      await _ensureFirebaseInitialized();
      
      if (!await _checkConnectivity()) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      
      final docSnapshot = await _db.collection('users').doc(uid).get()
          .timeout(_firebaseTimeout, onTimeout: () {
        throw TimeoutException('Operation timed out. Please try again.');
      });
      
      return docSnapshot.exists;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error checking user registration: $e');
      throw Exception('Error checking user data: ${getFirebaseErrorMessage(e)}');
    } on TimeoutException catch (e) {
      debugPrint('Timeout checking user registration: $e');
      throw Exception('Connection timed out. Please try again later.');
    } catch (e) {
      debugPrint('Error checking if user is registered: $e');
      return false;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      await _ensureFirebaseInitialized();
      
      if (!await _checkConnectivity()) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn()
          .timeout(_operationTimeout, onTimeout: () {
        throw TimeoutException('Google sign-in timed out. Please try again.');
      });
      
      if (googleUser == null) {
        throw Exception('Google sign in aborted by user');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication
          .timeout(_operationTimeout, onTimeout: () {
        throw TimeoutException('Google authentication timed out. Please try again.');
      });

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential)
          .timeout(_firebaseTimeout, onTimeout: () {
        throw TimeoutException('Firebase authentication timed out. Please try again.');
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error: $e');
      throw Exception(getAuthErrorMessage(e));
    } on TimeoutException catch (e) {
      debugPrint('Timeout during Google sign in: $e');
      throw Exception('Connection timed out. Please try again later.');
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // Store user data in Firestore
  Future<void> storeUserData({
    required String uid,
    required String name,
    required String email,
    required String? photoURL,
    String? phoneNumber,
    String? location,
    String? password,
  }) async {
    try {
      await _ensureFirebaseInitialized();
      
      if (!await _checkConnectivity()) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'location': location,
        'photoURL': photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(_firebaseTimeout, onTimeout: () {
        throw TimeoutException('Storing user data timed out. Please try again.');
      });
    } on FirebaseException catch (e) {
      debugPrint('Firebase error storing user data: $e');
      throw Exception('Error saving user data: ${getFirebaseErrorMessage(e)}');
    } on TimeoutException catch (e) {
      debugPrint('Timeout storing user data: $e');
      throw Exception('Connection timed out. Please try again later.');
    } catch (e) {
      debugPrint('Error storing user data: $e');
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _ensureFirebaseInitialized();
      
      if (!await _checkConnectivity()) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(_firebaseTimeout, onTimeout: () {
        throw TimeoutException('Sign in timed out. Please try again.');
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error: $e');
      throw Exception(getAuthErrorMessage(e));
    } on TimeoutException catch (e) {
      debugPrint('Timeout during sign in: $e');
      throw Exception('Connection timed out. Please try again later.');
    } catch (e) {
      debugPrint('Error signing in: $e');
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _ensureFirebaseInitialized();
      
      if (!await _checkConnectivity()) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(_firebaseTimeout, onTimeout: () {
        throw TimeoutException('Registration timed out. Please try again.');
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error: $e');
      throw Exception(getAuthErrorMessage(e));
    } on TimeoutException catch (e) {
      debugPrint('Timeout during registration: $e');
      throw Exception('Connection timed out. Please try again later.');
    } catch (e) {
      debugPrint('Error registering: $e');
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _ensureFirebaseInitialized();
      
      // No need to check connectivity for sign out, as we want to allow
      // users to sign out even if offline (clears local auth state)
      
      // Try sign out from Google first, but don't block if it fails
      try {
        await _googleSignIn.signOut().timeout(
          Duration(seconds: 5),
          onTimeout: () {
            debugPrint('Google sign out timed out, continuing with Firebase signout');
            return;
          }
        );
      } catch (e) {
        debugPrint('Error with Google sign out: $e');
        // Continue with Firebase sign-out even if Google sign-out fails
      }
      
      // Sign out from Firebase
      await _auth.signOut().timeout(_operationTimeout, onTimeout: () {
        throw TimeoutException('Sign out timed out. Local auth state cleared.');
      });
    } on TimeoutException catch (e) {
      debugPrint('Timeout during sign out: $e');
      // For signout, we can just warn but don't need to block the UI
      // since Firebase auth state is likely cleared locally
      debugPrint('Sign out completed locally, but server sync may have failed');
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw Exception('Error signing out: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _ensureFirebaseInitialized();
      
      if (!await _checkConnectivity()) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      
      await _auth.sendPasswordResetEmail(email: email)
          .timeout(_firebaseTimeout, onTimeout: () {
        throw TimeoutException('Password reset request timed out. Please try again.');
      });
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error: $e');
      throw Exception(getAuthErrorMessage(e));
    } on TimeoutException catch (e) {
      debugPrint('Timeout during password reset: $e');
      throw Exception('Connection timed out. Please try again later.');
    } catch (e) {
      debugPrint('Error resetting password: $e');
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  // Get auth error message
  String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'requires-recent-login':
        return 'Please log in again before retrying this request.';
      case 'provider-already-linked':
        return 'This account is already linked with another provider.';
      case 'invalid-credential':
        return 'The credential received is malformed or has expired.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed.';
      default:
        return 'An error occurred: ${e.message ?? e.code}';
    }
  }

  // Add this method for handling general Firebase exceptions
  String getFirebaseErrorMessage(FirebaseException e) {
    return 'Firebase error: ${e.message ?? e.code}';
  }
} 