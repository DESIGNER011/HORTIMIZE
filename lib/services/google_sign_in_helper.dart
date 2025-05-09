import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

// Helper class to handle Google Sign-In with additional error handling
class GoogleSignInHelper {
  // Initialize with specific scopes to avoid potential issues
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Timeout durations
  static const Duration _operationTimeout = Duration(seconds: 15);
  static const Duration _firebaseTimeout = Duration(seconds: 20);

  // Safe sign-in method with proper error handling for PigeonUserDetails issues
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('Starting safe Google sign-in flow...');

      // Try to sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn()
          .timeout(_operationTimeout, onTimeout: () {
        throw Exception('Google sign-in timed out. Please try again.');
      });

      if (googleUser == null) {
        debugPrint('User canceled the sign-in process');
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication
          .timeout(_operationTimeout, onTimeout: () {
        throw Exception('Google authentication timed out. Please try again.');
      });

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Missing Google authentication tokens');
      }

      debugPrint('Successfully received auth tokens from Google');

      // Create credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      debugPrint('Signing in to Firebase with Google credential');
      try {
        final userCredential = await _auth.signInWithCredential(credential)
            .timeout(_firebaseTimeout, onTimeout: () {
          throw Exception('Firebase authentication timed out. Please try again.');
        });
        
        debugPrint('Successfully signed in with Google');
        return userCredential;
      } catch (firebaseError) {
        debugPrint('Firebase error during sign-in: $firebaseError');
        
        // If Firebase authenticated but there's an issue with user details
        if (_auth.currentUser != null) {
          // We can't create a UserCredential directly, but we can manually sign in again
          // using the current user token
          debugPrint('Firebase auth successful but error with credential. Using current user.');
          
          // Get the current user's ID token
          String? idToken = await _auth.currentUser?.getIdToken();
          if (idToken != null) {
            // Create a new credential and sign in again
            AuthCredential newCredential = GoogleAuthProvider.credential(
              idToken: idToken,
              accessToken: googleAuth.accessToken,
            );
            
            try {
              return await _auth.signInWithCredential(newCredential);
            } catch (e) {
              debugPrint('Secondary sign-in attempt failed: $e');
              // Continue with current user anyway, caller can use FirebaseAuth.instance.currentUser
            }
          }
          
          // Just return null and let app code use currentUser directly
          return null;
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('Error in Google sign-in helper: $e');
      
      // Handle specific errors
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>') ||
          e.toString().contains('type cast')) {
        debugPrint('Detected compatibility issue - trying a direct Firebase approach');
        
        // If Firebase auth was successful but the plugin has issues
        if (_auth.currentUser != null) {
          debugPrint('User is actually authenticated! Using current user.');
          // We can't return a UserCredential directly, 
          // but the caller can use FirebaseAuth.instance.currentUser
          return null;
        }
        
        debugPrint('No Firebase user found, trying one more manual approach');
        // Manual Firebase authentication as last resort
        try {
          // Sign out and try again
          await _googleSignIn.signOut();
          await _auth.signOut();
          
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser == null) return null;
          
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          
          return await _auth.signInWithCredential(credential);
        } catch (finalError) {
          debugPrint('Final Google sign-in attempt failed: $finalError');
          throw Exception('Google Sign-In is not working with this app version. Please try another sign-in method.');
        }
      }
      
      // Re-throw other errors
      rethrow;
    }
  }

  // Sign out method with more robust error handling
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
      // Continue even if Google sign-out fails
    }
    
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out from Firebase: $e');
      throw Exception('Failed to sign out: $e');
    }
  }
} 