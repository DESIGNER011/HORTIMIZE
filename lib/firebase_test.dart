import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isLoading = false;
  String _status = 'Idle';
  FirebaseFirestore? _firestore;

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
  }

  Future<void> _initializeFirestore() async {
    setState(() {
      _isLoading = true;
      _status = 'Initializing Firestore...';
    });

    try {
      _firestore = FirebaseFirestore.instance;
      setState(() {
        _status = 'Firestore initialized successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error initializing Firestore: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirestoreConnection() async {
    if (_firestore == null) {
      setState(() {
        _status = 'Firestore not initialized';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing Firestore connection...';
    });

    try {
      // Simple test - get a collection
      await _firestore!.collection('test').get();
      setState(() {
        _status = 'Firestore connection successful!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error connecting to Firestore: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Firebase Connection Status',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _status.contains('successful') ? Colors.green.shade100 : 
                         _status.contains('Error') ? Colors.red.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _status.contains('successful') ? Colors.green.shade800 : 
                           _status.contains('Error') ? Colors.red.shade800 : Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _testFirestoreConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Test Firestore Connection'),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 