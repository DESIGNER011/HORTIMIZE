import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hortimize/account/sign_up.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/services/auth_service.dart';

/// AuthWrapper is responsible for deciding which screen to show
/// based on the user's authentication state.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to the authentication state changes
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // If connection is active and we have user data
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          
          // If the user is logged in
          if (user != null) {
            // Check if the user is registered in Firestore
            return FutureBuilder<bool>(
              future: _authService.isUserRegistered(user.uid),
              builder: (context, registrationSnapshot) {
                // Show loading while checking user registration
                if (registrationSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                // User is registered, navigate to main app
                if (registrationSnapshot.data == true) {
                  return const HeroPage();
                } 
                // User is not registered (shouldn't typically happen as we register during signup)
                else {
                  return const SignUpPage();
                }
              },
            );
          }
          
          // User is not logged in, show the signup page
          return const SignUpPage();
        }
        
        // Connection state is waiting, show loading
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
} 