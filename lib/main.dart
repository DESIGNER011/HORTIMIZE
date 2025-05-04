import 'package:flutter/material.dart';
import 'package:hortimize/auth/auth_wrapper.dart';
import 'package:hortimize/providers/community_provider.dart';
import 'package:hortimize/providers/openai_provider.dart';
import 'package:hortimize/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hortimize/firebase_test.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => OpenAIProvider()),
      ],
      child: MaterialApp(
        title: 'Hortimize',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const FirebaseInitializer(),
      ),
    );
  }
}

class FirebaseInitializer extends StatefulWidget {
  const FirebaseInitializer({super.key});

  @override
  State<FirebaseInitializer> createState() => _FirebaseInitializerState();
}

class _FirebaseInitializerState extends State<FirebaseInitializer> {
  bool _initialized = false;
  bool _error = false;
  String _errorMessage = '';

  // Initialize Firebase in the initState
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  // Initialize Firebase
  Future<void> _initializeFirebase() async {
    try {
      await FirebaseService.initializeFirebase();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error
    if (_error) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Failed to initialize Firebase'),
                const SizedBox(height: 8),
                Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeFirebase,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show loading screen
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing app...'),
              ],
            ),
          ),
        ),
      );
    }

    // Show app with Auth Wrapper that will handle authentication state
    return const AuthWrapper();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/images/homescreen.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20, bottom: 50, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 210),
                child: Text(
                  "Hortimize",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 60),
                ),
              ),
              // Image.asset('asset/images/logo.png'),
              const Padding(
                padding: EdgeInsets.only(bottom: 150),
                child: Text(
                  'Market Insight, Maximum Profits',
                  style: TextStyle(fontFamily: "Poppins", fontSize: 20),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  // Navigate to the AuthWrapper which will handle authentication state
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen, // Button color
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
              ),
              
              // Add Firebase Test Button
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FirebaseTestScreen()),
                  );
                },
                child: const Text(
                  "Test Firebase Connection",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
