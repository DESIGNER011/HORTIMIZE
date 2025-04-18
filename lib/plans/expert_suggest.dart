import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/market_demand.dart';

class ExpertSuggestionsPage extends StatelessWidget {
  const ExpertSuggestionsPage({super.key});

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
          "Experts Suggestions",
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
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("asset/images/homescreen.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Color(0xffd8d8d8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                '"Ask an Expert"',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                'User',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(7)),
                child: Text(
                  'Users can submit their questions. Farmers can engage with expert responses.',
                  style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                ),
              ),
              const SizedBox(height: 20),
              // TextFormField(
              //   decoration: const InputDecoration(
              //     labelText: 'Enter your question',
              //     border: OutlineInputBorder(),
              //     contentPadding:
              //         EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              //   ),
              //   maxLines: 4,
              // ),

              ElevatedButton(
                onPressed: () {
                  // Handle submit action
                },
                style: ElevatedButton.styleFrom(
                  //padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Color(0xffd8d8d8),
                ),
                child: const Text('Submit'),
              ),
              const SizedBox(height: 30),

              Text(
                'Expert',
                style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
              ),

              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(20),
                height: 130,
                decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(7)),
                child: Text(
                  'Suggestion',
                  style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                ),
              ),

              const SizedBox(height: 30),
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
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => HeroPage()),
              //   (route) =>
              //       false, // This removes all previous routes from the stack
              // );
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MarketDemandPage()));
            } else if (index == 2) {
              Navigator.pop(context);
            } else if (index == 3) {
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => HeroPage()),
              //   (route) =>
              //       false, // This removes all previous routes from the stack
              // );
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Climate()));
            }
          }),
    );
  }
}
