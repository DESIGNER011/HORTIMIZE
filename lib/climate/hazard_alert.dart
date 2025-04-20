import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/plans/plans.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HazardAlert extends StatefulWidget {
  const HazardAlert({super.key});

  @override
  State<HazardAlert> createState() => _HazardAlert();
}

enum TtsState { playing, stopped, paused, continued }

class _HazardAlert extends State<HazardAlert> {
  bool flooddropdown = true;
  bool droughtdropdown = false;
  bool cyclonedropdown = false;
  bool frostwropdown = false;
  
  // Text-to-speech engine
  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  bool _isSpeaking = false;
  String _currentlyPlayingAlert = "";
  String _ttsError = "";
  bool _ttsAvailable = false;
  bool _isInitializing = true;
  List<String> _availableLanguages = [];
  List<String> _availableVoices = [];
  String _selectedLanguage = "";
  
  // Alert descriptions
  final Map<String, String> _alertDescriptions = {
    'flood': "Store produce in elevated warehouse, waterproof containers, and well-ventilated raised platforms to prevent moisture damage. Move equipment to higher ground and ensure drainage systems are clear.",
    'drought': "Implement water conservation strategies for your crops. Use drought-resistant varieties, mulching, and efficient irrigation systems. Store seeds in cool, dry places and consider shade structures for sensitive crops.",
    'cyclone': "Secure all structures and equipment. Harvest mature crops if possible before the cyclone hits. Create windbreaks around vulnerable plantations and move livestock to protected shelters.",
    'frost': "Protect sensitive crops with frost cloths or blankets. Use heaters or sprinklers in orchards to prevent freezing. Harvest frost-sensitive produce before predicted frost events and ensure greenhouse heating systems are functioning.",
  };
  
  @override
  void initState() {
    super.initState();
    _initTts();
  }
  
  @override
  void dispose() {
    try {
      if (_ttsAvailable) {
        _flutterTts.stop();
      }
    } catch (e) {
      debugPrint("Error stopping TTS: $e");
    }
    super.dispose();
  }
  
  // Initialize TTS with settings
  Future<void> _initTts() async {
    setState(() {
      _isInitializing = true;
      _ttsError = "";
    });
    
    try {
      _flutterTts = FlutterTts();
      
      // Check if the platform is supported
      if (Platform.isAndroid) {
        debugPrint("Running on Android - Setting up TTS");
      } else if (Platform.isIOS) {
        debugPrint("Running on iOS - Setting up TTS");
      } else {
        setState(() {
          _ttsAvailable = false;
          _ttsError = "TTS is not supported on this platform";
          _isInitializing = false;
        });
        return;
      }
      
      // Get available languages
      try {
        var languages = await _flutterTts.getLanguages;
        setState(() {
          _availableLanguages = languages.cast<String>();
        });
        debugPrint("Available languages: $_availableLanguages");
        
        if (_availableLanguages.isEmpty) {
          setState(() {
            _ttsError = "No TTS languages found. Install Google TTS engine from Play Store.";
            _ttsAvailable = false;
            _isInitializing = false;
          });
          return;
        }
      } catch (e) {
        debugPrint("Error getting languages: $e");
      }
      
      // Try different languages until one works
      bool languageSet = false;
      List<String> languagesToTry = ['en-US', 'en-GB', 'en-IN', 'en', 'en-AU'];
      
      for (var lang in languagesToTry) {
        try {
          int result = await _flutterTts.setLanguage(lang);
          if (result == 1) {
            setState(() {
              _selectedLanguage = lang;
            });
            languageSet = true;
            debugPrint("Successfully set language to $lang");
            break;
          }
        } catch (e) {
          debugPrint("Error setting language $lang: $e");
        }
      }
      
      if (!languageSet) {
        // If none of our preferred languages work, try the first available
        if (_availableLanguages.isNotEmpty) {
          try {
            await _flutterTts.setLanguage(_availableLanguages[0]);
            setState(() {
              _selectedLanguage = _availableLanguages[0];
            });
            languageSet = true;
            debugPrint("Fallback: Set language to ${_availableLanguages[0]}");
          } catch (e) {
            debugPrint("Error setting fallback language: $e");
          }
        }
      }
      
      if (!languageSet) {
        setState(() {
          _ttsAvailable = false;
          _ttsError = "Failed to set any language. TTS engine may not be properly installed.";
          _isInitializing = false;
        });
        return;
      }
      
      // Get available voices
      try {
        var voices = await _flutterTts.getVoices;
        setState(() {
          _availableVoices = voices.cast<String>();
        });
        debugPrint("Available voices: $_availableVoices");
      } catch (e) {
        debugPrint("Error getting voices: $e");
      }
      
      // Test if speak works with a simple message
      try {
        var engines = await _flutterTts.getEngines;
        debugPrint("Available engines: $engines");
        
        if (engines.isEmpty) {
          setState(() {
            _ttsAvailable = false;
            _ttsError = "No TTS engines found. Please install a TTS engine from the Play Store.";
            _isInitializing = false;
          });
          return;
        }
      } catch (e) {
        debugPrint("Error getting engines: $e");
      }
      
      // Set up handlers
      _flutterTts.setStartHandler(() {
        setState(() {
          _ttsState = TtsState.playing;
          _isSpeaking = true;
          debugPrint("TTS Started Playing");
        });
      });
      
      _flutterTts.setCompletionHandler(() {
        setState(() {
          _ttsState = TtsState.stopped;
          _isSpeaking = false;
          _currentlyPlayingAlert = "";
          debugPrint("TTS Completed");
        });
      });
      
      _flutterTts.setCancelHandler(() {
        setState(() {
          _ttsState = TtsState.stopped;
          _isSpeaking = false;
          _currentlyPlayingAlert = "";
          debugPrint("TTS Cancelled");
        });
      });
      
      _flutterTts.setErrorHandler((message) {
        setState(() {
          _ttsState = TtsState.stopped;
          _isSpeaking = false;
          _ttsError = "TTS Error: $message";
          debugPrint("TTS Error: $message");
        });
      });
      
      // Set parameters
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
      
      // Final test - try to speak a test message
      try {
        int result = await _flutterTts.speak("TTS test");
        await _flutterTts.stop(); // Immediately stop the test
        
        if (result == 1) {
          setState(() {
            _ttsAvailable = true;
            _ttsError = "";
            debugPrint("TTS is working properly");
          });
        } else {
          setState(() {
            _ttsAvailable = false;
            _ttsError = "TTS failed final test with result code: $result";
            debugPrint(_ttsError);
          });
        }
      } catch (e) {
        setState(() {
          _ttsAvailable = false;
          _ttsError = "Final TTS test failed: $e";
          debugPrint(_ttsError);
        });
      }
      
    } catch (e) {
      setState(() {
        _ttsAvailable = false;
        _ttsError = "Failed to initialize TTS: $e";
        debugPrint(_ttsError);
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }
  
  // Speak the text
  Future<void> _speak(String alertType, String text) async {
    if (!_ttsAvailable) {
      // First try to reinitialize if not available
      if (_ttsError.contains("No TTS engines found") || _ttsError.contains("not properly installed")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please install Google Text-to-Speech from the Play Store"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _initTts(); // Retry initialization
              },
            ),
          ),
        );
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Text-to-speech is not available. Trying to reinitialize..."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Try to reinitialize
      await _initTts();
      
      if (!_ttsAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Text-to-speech is still not available: $_ttsError"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }
    
    // Handle if we're already speaking
    if (_isSpeaking) {
      if (_currentlyPlayingAlert == alertType) {
        // Stop if it's the same alert
        try {
          await _flutterTts.stop();
          setState(() {
            _isSpeaking = false;
            _currentlyPlayingAlert = "";
          });
        } catch (e) {
          debugPrint("Error stopping TTS: $e");
        }
        return;
      } else {
        // Stop previous alert if different
        try {
          await _flutterTts.stop();
          setState(() {
            _isSpeaking = false;
          });
        } catch (e) {
          debugPrint("Error stopping TTS: $e");
        }
      }
    }
    
    // Begin speaking
    try {
      // Set parameters each time in case they were reset
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
      
      if (_selectedLanguage.isNotEmpty) {
        await _flutterTts.setLanguage(_selectedLanguage);
      }
      
      var result = await _flutterTts.speak(text);
      if (result == 1) { // success
        setState(() {
          _isSpeaking = true;
          _currentlyPlayingAlert = alertType;
          _ttsError = "";
        });
      } else {
        setState(() {
          _ttsError = "Failed to start TTS. Error code: $result";
          debugPrint(_ttsError);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not play speech: $_ttsError"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _ttsError = "Error using TTS: $e";
        debugPrint(_ttsError);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not play speech. Try restarting the app."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _initTts(); // Retry initialization
            },
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // 🔙 Back Arrow
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Hazard Alert mode",
          style: TextStyle(fontFamily: "Poppins", fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("asset/images/profile.png"),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("asset/images/homescreen.jpeg"),
              fit: BoxFit.cover),
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
          ),
          child: _isInitializing 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 20),
                      Text(
                        "Initializing text-to-speech...",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    // TTS not available warning
                    if (!_ttsAvailable)
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(
                                  "Text-to-speech unavailable",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "The audio feature is not available on this device. $_ttsError",
                              style: TextStyle(
                                color: Colors.orange.shade800,
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                _initTts();
                              },
                              child: Text("Retry TTS Initialization"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                    // Flood Alert
                    _buildAlertHeader("Flood Alert"),
                    // Flood Alert Content
                    _buildAlertContent(
                      "flood",
                      "Flood Alert", 
                      _alertDescriptions['flood']!,
                      () => _speak('flood', _alertDescriptions['flood']!),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    
                    // Drought Warning
                    _buildAlertHeader("Drought Warning"),
                    // Drought Warning Content
                    _buildAlertContent(
                      "drought",
                      "Drought Warning", 
                      _alertDescriptions['drought']!,
                      () => _speak('drought', _alertDescriptions['drought']!),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    
                    // Cyclone Alert
                    _buildAlertHeader("Cyclone Alert"),
                    // Cyclone Alert Content
                    _buildAlertContent(
                      "cyclone",
                      "Cyclone Alert", 
                      _alertDescriptions['cyclone']!,
                      () => _speak('cyclone', _alertDescriptions['cyclone']!),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    
                    // Frost Alert
                    _buildAlertHeader("Frost Alert"),
                    // Frost Alert Content
                    _buildAlertContent(
                      "frost",
                      "Frost Alert", 
                      _alertDescriptions['frost']!,
                      () => _speak('frost', _alertDescriptions['frost']!),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    
                    if (_ttsError.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TTS Error:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(_ttsError),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                _initTts();
                              },
                              child: Text("Retry"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Market"),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: "Plans"),
            BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Climate"),
          ],
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
            } else if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MarketDemandPage()));
            } else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PlansPage()));
            } else if (index == 3) {
              Navigator.pop(context);
            }
          }),
    );
  }

  // Helper method to build the alert header
  Widget _buildAlertHeader(String title) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.warning),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          Icon(Icons.arrow_drop_down_outlined),
        ],
      ),
    );
  }
  
  // Helper method to build the alert content
  Widget _buildAlertContent(String alertType, String title, String description, VoidCallback onMicPressed) {
    final bool isCurrentlyPlaying = _isSpeaking && _currentlyPlayingAlert == alertType;
    
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.announcement,
              ),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                ),
              ),
              InkWell(
                onTap: _ttsAvailable ? onMicPressed : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Text-to-speech is not available"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: !_ttsAvailable 
                        ? Colors.grey.shade300 
                        : (isCurrentlyPlaying ? Colors.red.shade100 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCurrentlyPlaying ? Icons.stop 
                                          : (_ttsAvailable ? Icons.volume_up : Icons.volume_off),
                        color: isCurrentlyPlaying ? Colors.red 
                                                 : (_ttsAvailable ? Colors.black : Colors.grey),
                        size: 18,
                      ),
                      SizedBox(width: 5),
                      Text(
                        isCurrentlyPlaying ? "Stop" : "Play",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrentlyPlaying ? Colors.red 
                                                   : (_ttsAvailable ? Colors.black : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          if (isCurrentlyPlaying)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Speaking...",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
