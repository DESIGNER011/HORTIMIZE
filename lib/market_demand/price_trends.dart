import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/data.dart';
import 'package:hortimize/plans/plans.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceTrends extends StatelessWidget {
  final Commodity commodity;
  
  const PriceTrends({super.key, required this.commodity});

  @override
  Widget build(BuildContext context) {
    // Extract price trend data for the chart
    final Map<String, double> priceTrend = commodity.priceTrend;
    final List<FlSpot> spots = [];
    
    int index = 0;
    priceTrend.forEach((month, price) {
      spots.add(FlSpot(index.toDouble(), price));
      index++;
    });

    // Calculate summary values safely
    final double minPrice = priceTrend.values.isEmpty ? 0.0 : priceTrend.values.reduce((a, b) => a < b ? a : b);
    final double maxPrice = priceTrend.values.isEmpty ? 0.0 : priceTrend.values.reduce((a, b) => a > b ? a : b);
    final double avgPrice = priceTrend.values.isEmpty ? 0.0 
        : priceTrend.values.fold(0.0, (sum, price) => sum + price) / priceTrend.values.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // 🔙 Back Arrow
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${commodity.name} Price Trends",
          style: TextStyle(fontFamily: "Poppins", fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.green, // ✅ AppBar background color
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 18, // ✅ Profile Picture on Right
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
                    "${commodity.name} Price Trends",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 24),
                  ),
                  Container(
                    height: 300,
                    width: 300,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xffb6c6c1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: spots.isNotEmpty
                        ? LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 && value.toInt() < priceTrend.keys.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            priceTrend.keys.elementAt(value.toInt()).substring(0, 3),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }
                                      return Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '₹${value.toInt()}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: Colors.green,
                                  barWidth: 4,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Text("No price data available"),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Summary",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Minimum Price: ₹${minPrice.toStringAsFixed(2)}",
                          style: TextStyle(fontFamily: "Poppins"),
                        ),
                        Text(
                          "Maximum Price: ₹${maxPrice.toStringAsFixed(2)}",
                          style: TextStyle(fontFamily: "Poppins"),
                        ),
                        Text(
                          "Average Price: ₹${avgPrice.toStringAsFixed(2)}",
                          style: TextStyle(fontFamily: "Poppins"),
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
