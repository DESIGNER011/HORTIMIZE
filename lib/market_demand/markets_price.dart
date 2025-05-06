import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/data.dart';
import 'package:hortimize/plans/plans.dart';

class MarketsPrice extends StatefulWidget {
  final Commodity commodity;
  
  const MarketsPrice({super.key, required this.commodity});

  @override
  State<MarketsPrice> createState() => _MarketsPriceState();
}

class _MarketsPriceState extends State<MarketsPrice> {
  bool showDropdown = false;
  String selectedFilter = "All Regions";
  List<String> regions = [];
  
  @override
  void initState() {
    super.initState();
    regions = widget.commodity.priceByRegion.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Filter regions based on the selected filter
    List<String> displayRegions = regions;
    if (selectedFilter != "All Regions") {
      if (selectedFilter == "Top 3") {
        displayRegions = widget.commodity.demandRanking.take(3).toList();
      } else if (selectedFilter == "Current location") {
        // This would normally use geolocation - hardcoded for now
        displayRegions = [widget.commodity.demandRanking.first];
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${widget.commodity.name} Market Price",
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
          child: Stack(children: [
            Container(
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
                      "${widget.commodity.name} Market Prices",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 24),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35.0),
                        child: Row(
                          children: [
                            Text(
                              "Filter by: ",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              selectedFilter,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showDropdown =
                                      !showDropdown; // Toggle dropdown visibility
                                });
                              },
                              icon: Icon(Icons.filter_list, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c6c1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Region",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Price per ${widget.commodity.unit}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(0),
                              itemCount: displayRegions.length,
                              itemBuilder: (context, index) {
                                final region = displayRegions[index];
                                final price = widget.commodity.priceByRegion[region] ?? 0.0;
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          region,
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "₹${price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.right,
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
                            "Price Summary",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Average price: ₹${_calculateAverage().toStringAsFixed(2)}/${widget.commodity.unit}",
                            style: TextStyle(fontFamily: "Poppins"),
                          ),
                          Text(
                            "Highest price: ₹${_findHighestPrice().toStringAsFixed(2)} (${_findHighestPriceRegion()})",
                            style: TextStyle(fontFamily: "Poppins"),
                          ),
                          Text(
                            "Lowest price: ₹${_findLowestPrice().toStringAsFixed(2)} (${_findLowestPriceRegion()})",
                            style: TextStyle(fontFamily: "Poppins"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showDropdown)
              Positioned(
                top: 105, // Adjust position below filter button
                right: 140,
                left: 105,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 2,
                          blurRadius: 5),
                    ],
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      _dropdownItem("All Regions"),
                      _dropdownItem("Top 3"),
                      _dropdownItem("Current location"),
                    ],
                  ),
                ),
              ),
          ]),
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

  Widget _dropdownItem(String text) {
    return Container(
      color: selectedFilter == text 
          ? const Color.fromARGB(88, 153, 182, 121)
          : Colors.transparent,
      child: ListTile(
        title: Text(text, style: TextStyle(fontFamily: "Poppins")),
        onTap: () {
          setState(() {
            selectedFilter = text;
            showDropdown = false; // Hide dropdown after selection
          });
        },
      ),
    );
  }

  // Helper methods for price calculations
  double _calculateAverage() {
    final prices = widget.commodity.priceByRegion.values;
    if (prices.isEmpty) return 0.0;
    return prices.fold(0.0, (sum, price) => sum + price) / prices.length;
  }

  double _findHighestPrice() {
    final prices = widget.commodity.priceByRegion.values;
    if (prices.isEmpty) return 0.0;
    return prices.reduce((a, b) => a > b ? a : b);
  }

  String _findHighestPriceRegion() {
    final priceByRegion = widget.commodity.priceByRegion;
    if (priceByRegion.isEmpty) return "N/A";

    double maxPrice = 0.0;
    String maxRegion = "";
    
    priceByRegion.forEach((region, price) {
      if (price > maxPrice) {
        maxPrice = price;
        maxRegion = region;
      }
    });
    
    return maxRegion;
  }

  double _findLowestPrice() {
    final prices = widget.commodity.priceByRegion.values;
    if (prices.isEmpty) return 0.0;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  String _findLowestPriceRegion() {
    final priceByRegion = widget.commodity.priceByRegion;
    if (priceByRegion.isEmpty) return "N/A";

    double minPrice = double.infinity;
    String minRegion = "";
    
    priceByRegion.forEach((region, price) {
      if (price < minPrice) {
        minPrice = price;
        minRegion = region;
      }
    });
    
    return minRegion;
  }
}
