import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/plans/plans.dart';

class MarketsPrice extends StatefulWidget {
  const MarketsPrice({super.key});

  @override
  State<MarketsPrice> createState() => _MarketsPriceState();
}

class _MarketsPriceState extends State<MarketsPrice> {
  bool showDropdown = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Market Price",
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
                      "Disaplaying prices",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 24),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35.0),
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                showDropdown =
                                    !showDropdown; // Toggle dropdown visibility
                              });
                            },
                            icon: Icon(Icons.line_style_sharp)),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 300,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c6c1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                            "Shows the market prices of \n given commodiyt besed on \n their demand and supply \n based n the selected \n regions or area\n\n * \n * \n"),
                      ),
                    ),
                    Container(
                      height: 150,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c6c1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Text("Summary on prices")),
                    ),
                  ],
                ),
              ),
            ),
            if (showDropdown)
              Positioned(
                top: 105, // Adjust position below TextField
                right: 140,
                left: 105,
                child: Container(
                  height: 150,
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
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      _dropdownItem("Market"),
                      _dropdownItem("Regions"),
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
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => HeroPage()),
              //   (route) =>
              //       false, // This removes all previous routes from the stack
              // );
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PlansPage()));
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

  Widget _dropdownItem(String text) {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(88, 153, 182, 121),
        child: ListTile(
          title: Text(text, style: TextStyle(fontFamily: "Poppins")),
          onTap: () {
            setState(() {
              showDropdown = false; // Hide dropdown after selection
            });
          },
        ),
      ),
    );
  }
}
