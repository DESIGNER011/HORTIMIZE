import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/plans/community.dart';
import 'package:hortimize/plans/expert_suggest.dart';
import 'package:hortimize/plans/schemes.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
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
          "Plans",
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
        padding: EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 40),
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("asset/images/homescreen.jpeg"),
          fit: BoxFit.cover,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Community()),
                );
              },
              child: _buildInfoContainer(
                "Communtiny Forum",
                Icons.auto_graph_outlined,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpertSuggestionsPage()),
                );
              },
              child: _buildInfoContainer(
                "Expert Suggestions",
                Icons.auto_graph_outlined,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GovSchemes()),
                );
              },
              child: _buildInfoContainer(
                "Government Schemes",
                Icons.auto_graph_outlined,
              ),
            ),
          ],
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
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
            } else if (index == 1) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MarketDemandPage()));
            } else if (index == 3) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) => false,
              );
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Climate()));
            }
          }),
    );
  }

  // 🔹 Helper Function to Create Info Containers with Icons
  Widget _buildInfoContainer(String title, IconData iconData) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 30),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
            Icon(iconData, size: 40, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
