import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hortimize/services/auth_service.dart';
import 'package:hortimize/account/sign_up.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  // User data
  String _name = '';
  String _location = '';
  String _phoneNumber = '';
  String? _photoURL;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get current user
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'No user logged in';
          _isLoading = false;
        });
        return;
      }
      
      // Set default values from auth
      _name = currentUser.displayName ?? 'User';
      _email = currentUser.email ?? '';
      _photoURL = currentUser.photoURL;
      
      // Get additional user data from Firestore
      final DocumentSnapshot userDoc = 
          await _db.collection('users').doc(currentUser.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        
        setState(() {
          _name = userData['name'] ?? _name;
          _location = userData['location'] ?? 'Not specified';
          _phoneNumber = userData['phoneNumber'] ?? 'Not specified';
          // If photo URL is null in Firestore but exists in Auth, keep the Auth one
          _photoURL = userData['photoURL'] ?? _photoURL;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // Navigate back to the SignUpPage
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignUpPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error signing out: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontFamily: "Poppins"),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff688e4d),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('asset/images/homescreen.jpeg'),
          fit: BoxFit.cover,
        )),
        child: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _photoURL != null
                          ? NetworkImage(_photoURL!)
                          : AssetImage("asset/images/profile.png") as ImageProvider,
                    ),
                  ),
                ),
    
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
    
                SizedBox(height: 20),
    
                // 🔹 User Information Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileInfo("Name", _name),
                      _buildProfileInfo("Email", _email),
                      _buildProfileInfo("Location", _location),
                      _buildProfileInfo("Contact", _phoneNumber),
                    ],
                  ),
                ),
    
                SizedBox(height: 30),
    
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    "Back",
                    style: TextStyle(
                        fontFamily: "Poppins", fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  // 🔹 Helper Function for Profile Info
  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
