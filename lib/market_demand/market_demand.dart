import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/data.dart';
import 'package:hortimize/market_demand/demand_regions.dart';
import 'package:hortimize/market_demand/markets_price.dart';
import 'package:hortimize/market_demand/price_trends.dart';
import 'package:hortimize/plans/plans.dart';

class MarketDemandPage extends StatefulWidget {
  const MarketDemandPage({super.key});

  @override
  State<MarketDemandPage> createState() => _MarketDemandPageState();
}

class _MarketDemandPageState extends State<MarketDemandPage> {
  bool showDropdown = false;
  String searchQuery = '';
  List<Commodity> filteredCommodities = [];
  Commodity? selectedCommodity;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCommodities = marketData.commodities;
  }

  void filterCommodities(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredCommodities = marketData.commodities;
      } else {
        filteredCommodities = marketData.commodities
            .where((commodity) =>
                commodity.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      // Reset selected commodity if search query changes
      if (selectedCommodity != null && !query.isEmpty && 
          !selectedCommodity!.name.toLowerCase().contains(query.toLowerCase())) {
        selectedCommodity = null;
      }
    });
  }

  void selectCommodity(Commodity commodity) {
    setState(() {
      selectedCommodity = commodity;
      _searchController.text = commodity.name;
      showDropdown = false;
    });
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
          "Market Demand",
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
      body: Stack(children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/images/homescreen.jpeg"),
              fit: BoxFit.cover,
              opacity: .7,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: filterCommodities,
                      decoration: InputDecoration(
                        hintText: "Search by commodity name",
                        hintStyle: TextStyle(fontFamily: "Poppins"),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              showDropdown = !showDropdown;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.all(15),
                      ),
                    ),
                    SizedBox(height: 30),
                    if (selectedCommodity != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          padding: EdgeInsets.all(15),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selected: ${selectedCommodity!.name}",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Unit: ${selectedCommodity!.unit}",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Top demand region: ${selectedCommodity!.demandRanking.first}",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 300,
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              if (selectedCommodity != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PriceTrends(
                                      commodity: selectedCommodity!,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please select a commodity first'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: _buildInfoContainer(
                              "Price Trends (Graph)",
                              Icons.auto_graph_outlined,
                            ),
                          ),
                          SizedBox(height: 15),
                          InkWell(
                            onTap: () {
                              if (selectedCommodity != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DemandRegions(
                                      commodity: selectedCommodity!,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please select a commodity first'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: _buildInfoContainer(
                              "Demand region",
                              Icons.auto_graph_outlined,
                            ),
                          ),
                          SizedBox(height: 15),
                          InkWell(
                            onTap: () {
                              if (selectedCommodity != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MarketsPrice(
                                      commodity: selectedCommodity!,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please select a commodity first'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: _buildInfoContainer(
                              "Market price",
                              Icons.auto_graph_outlined,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDropdown && filteredCommodities.isNotEmpty)
          Positioned(
            top: 80, // Adjust position below TextField
            right: 20,
            left: 20,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: filteredCommodities.length,
                  itemBuilder: (context, index) {
                    return _buildCommodityItem(filteredCommodities[index]);
                  },
                ),
              ),
            ),
          ),
        if (showDropdown && filteredCommodities.isEmpty)
          Positioned(
            top: 80,
            right: 20,
            left: 20,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "No commodities found",
                  style: TextStyle(fontFamily: "Poppins"),
                ),
              ),
            ),
          ),
      ]),
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
            } else if (index == 2) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PlansPage()));
            } else if (index == 3) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Climate()));
            }
          }),
    );
  }

  Widget _buildCommodityItem(Commodity commodity) {
    return ListTile(
      title: Text(
        commodity.name,
        style: TextStyle(fontFamily: "Poppins"),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "Unit: ${commodity.unit}",
        style: TextStyle(fontFamily: "Poppins", fontSize: 12),
      ),
      onTap: () {
        selectCommodity(commodity);
      },
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
        padding: const EdgeInsets.all(8.0),
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
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
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
