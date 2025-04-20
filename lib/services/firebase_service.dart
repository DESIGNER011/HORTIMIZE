import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hortimize/firebase_options.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class FirebaseService {
  static bool _initialized = false;
  static int _initAttempts = 0;
  static const int maxInitAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration initTimeout = Duration(seconds: 15);
  
  static bool get isInitialized => _initialized;
  
  // Check internet connectivity
  static Future<bool> _checkConnectivity() async {
    try {
      var result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      // Assume connectivity exists if we can't check
      return true;
    }
  }
  
  static Future<void> initializeFirebase() async {
    if (_initialized) {
      debugPrint('Firebase already initialized');
      return;
    }
    
    // Check internet connectivity first
    if (!await _checkConnectivity()) {
      debugPrint('No internet connection when initializing Firebase');
      throw Exception('No internet connection. Please check your network and try again.');
    }
    
    // Increment attempt counter
    _initAttempts++;
    
    try {
      debugPrint('Attempting to initialize Firebase (Attempt $_initAttempts of $maxInitAttempts)');
      
      // Clear any previous error states from Firebase
      try {
        await Firebase.app().delete();
      } catch (e) {
        // App probably doesn't exist yet, which is fine
      }
      
      // First try to initialize with default options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(initTimeout, onTimeout: () {
        throw TimeoutException('Firebase initialization timed out');
      });
      
      _initialized = true;
      _initAttempts = 0; // Reset counter on success
      debugPrint('Firebase initialized successfully with options');
    } catch (optionsError) {
      debugPrint('Error initializing Firebase with options: $optionsError');
      
      // Fallback to default initialization (without options)
      try {
        await Firebase.initializeApp().timeout(initTimeout, onTimeout: () {
          throw TimeoutException('Firebase initialization timed out');
        });
        
        _initialized = true;
        _initAttempts = 0; // Reset counter on success
        debugPrint('Firebase initialized successfully without options');
      } catch (e) {
        debugPrint('Error initializing Firebase: $e');
        
        // If we haven't reached max attempts, retry after delay
        if (_initAttempts < maxInitAttempts) {
          debugPrint('Will retry initialization after delay');
          await Future.delayed(retryDelay);
          return initializeFirebase(); // Recursive retry
        }
        
        // If we've exhausted retries, throw a more specific error based on the exception
        if (e is FirebaseException) {
          if (e.code == 'app-already-exists') {
            // This is actually okay, we can consider Firebase initialized
            _initialized = true;
            debugPrint('Firebase app already exists, considering initialized');
            return;
          }
          
          throw Exception('Firebase error: ${e.message ?? e.code}. Please restart the app.');
        } else if (e is TimeoutException) {
          throw Exception('Firebase initialization timed out. Please check your internet connection and try again.');
        } else {
          throw Exception('Failed to initialize Firebase: ${e.toString()}. Please restart the app.');
        }
      }
    }
  }
  
  // Force reinitialize Firebase (for recovery attempts)
  static Future<void> reinitializeFirebase() async {
    _initialized = false;
    _initAttempts = 0;
    return initializeFirebase();
  }
} 