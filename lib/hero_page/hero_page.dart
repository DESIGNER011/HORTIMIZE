import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/notification/notifi_page.dart';
import 'package:hortimize/plans/plans.dart';
import 'package:hortimize/profile/profile.dart';
import 'package:hortimize/services/auth_service.dart';
import 'package:hortimize/auth/auth_wrapper.dart';
import 'dart:async';  // Add this import for TimeoutException

class HeroPage extends StatelessWidget {
  const HeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("asset/images/homescreen.jpeg"), // Background Image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              // 🔹 Title with Icons
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50, // Circle size
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, // Makes it circular
                        image: DecorationImage(
                          image: AssetImage('asset/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Hortimize",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 50, // Circle size
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, // Makes it circular
                          image: DecorationImage(
                            image: AssetImage('asset/images/profile.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.only(
                        top: 10, left: 30, right: 30, bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(178, 182, 198, 177),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Home",
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 25),
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MarketDemandPage()));
                            },
                            child: _buildRectangleBox("Marketing demands")),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PlansPage(),
                                ));
                          },
                          child: _buildRectangleBox("Plans"),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Climate(),
                                ));
                          },
                          child: _buildRectangleBox("Climate"),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NotifiPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff7cc8a6), // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.notifications_none,
                              size: 25,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Notification",
                          style: TextStyle(fontFamily: "Poppins", fontSize: 20),
                        ),
                        const SizedBox(height: 30),
                        // Logout Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Logout Confirmation",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    "Are you sure you want to logout?",
                                    style: TextStyle(fontFamily: "Poppins"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close dialog
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop(); // Close dialog
                                        
                                        try {
                                          // Show loading indicator
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      CircularProgressIndicator(),
                                                      SizedBox(width: 20),
                                                      Text(
                                                        "Logging out...",
                                                        style: TextStyle(fontFamily: "Poppins"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          
                                          // Set a timeout for the logout operation
                                          bool logoutSuccess = false;
                                          
                                          // Perform logout with timeout
                                          try {
                                            await _authService.signOut()
                                                .timeout(Duration(seconds: 5), onTimeout: () {
                                              throw TimeoutException('Logout timed out');
                                            });
                                            logoutSuccess = true;
                                          } catch (e) {
                                            debugPrint('Logout error or timeout: $e');
                                            // Even on error, we'll proceed with navigation
                                            // but will show an error message
                                          }
                                          
                                          // Check if context is still mounted before proceeding
                                          if (!context.mounted) return;
                                          
                                          // Close loading dialog if open
                                          if (Navigator.canPop(context)) {
                                            Navigator.of(context).pop();
                                          }
                                          
                                          if (!logoutSuccess && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Warning: Logout encountered an issue. App state has been reset anyway.'),
                                                backgroundColor: Colors.orange,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                          
                                          // Always navigate to login (AuthWrapper will handle) even if 
                                          // there was an error, as we want the user to get out
                                          await Future.delayed(Duration(milliseconds: 300));
                                          
                                          // Check if context is still mounted before navigating
                                          if (context.mounted) {
                                            Navigator.of(context).pushAndRemoveUntil(
                                              MaterialPageRoute(builder: (context) => AuthWrapper()),
                                              (route) => false
                                            );
                                          }
                                        } catch (e) {
                                          // Check if context is still mounted before proceeding
                                          if (!context.mounted) return;
                                          
                                          // Close loading dialog if open
                                          if (Navigator.canPop(context)) {
                                            Navigator.of(context).pop();
                                          }
                                          
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error signing out: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                          
                                          // Even on error, try to navigate to login
                                          try {
                                            await Future.delayed(Duration(seconds: 1));
                                            
                                            // Check if context is still mounted before navigating
                                            if (context.mounted) {
                                              Navigator.of(context).pushAndRemoveUntil(
                                                MaterialPageRoute(builder: (context) => AuthWrapper()),
                                                (route) => false
                                              );
                                            }
                                          } catch (navError) {
                                            debugPrint('Navigation error: $navError');
                                          }
                                        }
                                      },
                                      child: Text(
                                        "Logout",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Function to Create a Rectangular Box
  Widget _buildRectangleBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      width: 210,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xffD8D8D8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: const TextStyle(fontFamily: "Poppins", fontSize: 20),
          ),
        ],
      ),
    );
  }
}
