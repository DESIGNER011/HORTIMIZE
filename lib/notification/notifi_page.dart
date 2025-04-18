import 'package:flutter/material.dart';

class NotifiPage extends StatelessWidget {
  const NotifiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(fontFamily: "Poppins"),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "asset/images/homescreen.jpeg"), // ✅ Background Image
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            _buildNotification(
              "Ideal Climate for Herbal Crops",
              "Cooler temperatures are driving demand for basil and mint.",
            ),
            _buildNotification(
              "New Farming Subsidy Available",
              "Apply before March 30th for organic farming support.",
            ),
            _buildNotification(
              "Join the Farmer's Meet-Up",
              "Scheduled for March 15th at 10 AM in the Village Hall.",
            ),
            _buildNotification(
              "Rice Prices Dropping – Hold Your Stock!",
              "Rice prices are expected to drop next week.",
            ),
            _buildNotification(
              "High Demand for Organic Vegetables",
              "Local buyers offer 10% higher rates for organic produce.",
            ),
            _buildNotification(
              "Nearest Market with Best Rates",
              "Madhavpur Mandi offers the highest rate for onions today.",
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper Function for Notifications
  Widget _buildNotification(String title, String description) {
    return Card(
      color: Colors.white
          .withOpacity(0.9), // Slight transparency for better readability
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        trailing: Icon(Icons.volume_up_outlined, color: Colors.green, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
