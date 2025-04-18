import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/notification/notifi_page.dart';
import 'package:hortimize/plans/plans.dart';
import 'package:hortimize/profile/profile.dart';

class HeroPage extends StatelessWidget {
  const HeroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Makes it circular
                        image: DecorationImage(
                          image: AssetImage('asset/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Hortimize",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 50, // Circle size
                        height: 50,
                        decoration: BoxDecoration(
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
                    padding: EdgeInsets.only(
                        top: 10, left: 30, right: 30, bottom: 10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(178, 182, 198, 177),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
                                          MarketDemandPage()));
                            },
                            child: _buildRectangleBox("Marketing demands")),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlansPage(),
                                ));
                          },
                          child: _buildRectangleBox("Plans"),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Climate(),
                                ));
                          },
                          child: _buildRectangleBox("Climate"),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NotifiPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff7cc8a6), // Button color
                            // padding: EdgeInsets.symmetric(
                            //     horizontal: 150, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.notifications_none,
                              size: 25,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Notification",
                          style: TextStyle(fontFamily: "Poppins", fontSize: 20),
                        )
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
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(10),
      width: 210,
      height: 120,
      decoration: BoxDecoration(
        color: Color(0xffD8D8D8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
