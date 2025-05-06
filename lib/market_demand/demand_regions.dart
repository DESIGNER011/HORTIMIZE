import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/data.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/plans/plans.dart';

class DemandRegions extends StatelessWidget {
  final Commodity commodity;
  
  const DemandRegions({super.key, required this.commodity});

  @override
  Widget build(BuildContext context) {
    // Calculate price difference for recommendation - ensure all values are doubles
    final double highestPrice = commodity.priceByRegion[commodity.demandRanking.first] ?? 0.0;
    final double lowestPrice = commodity.priceByRegion[commodity.demandRanking.last] ?? 0.0;
    final double priceDifference = (highestPrice - lowestPrice).abs();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${commodity.name} Demand Regions",
          style: TextStyle(fontFamily: "Poppins", fontSize: 24),
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
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("asset/images/homescreen.jpeg"),
          fit: BoxFit.cover,
        )),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(25),
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xffd8d8d8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Demand Regions for ${commodity.name}",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: 300,
                    width: 300,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xffb6c6c1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Demand Regions (High to Low):",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: commodity.demandRanking.length,
                            itemBuilder: (context, index) {
                              final String regionName = commodity.demandRanking[index];
                              final double regionPrice = commodity.priceByRegion[regionName] ?? 0.0;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 12,
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        regionName,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹${regionPrice.toStringAsFixed(2)}/${commodity.unit}",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    width: 300,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xffb6c6c1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recommendation Strategy",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Best market for selling: ${commodity.demandRanking.first}",
                          style: TextStyle(fontFamily: "Poppins"),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Price difference between highest and lowest demand regions: ₹${priceDifference.toStringAsFixed(2)}",
                          style: TextStyle(fontFamily: "Poppins"),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
            } else if (index == 1) {
              Navigator.pop(context);
            } else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PlansPage()));
            } else if (index == 3) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Climate()));
            }
          }),
    );
  }
}
