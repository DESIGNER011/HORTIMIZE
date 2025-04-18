import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/plans/plans.dart';

class Community extends StatelessWidget {
  const Community({super.key});

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
          "Community Forum",
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("asset/images/homescreen.jpeg"),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffd8d8d8), //b6c5c1
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Create New Discussion",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                            Text(
                              "Read more",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment_bank,
                              size: 15,
                            ),
                            Text(
                              "View cmt",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 15,
                            ),
                            Text(
                              "Comment",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                            Text(
                              "Read more",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment_bank,
                              size: 15,
                            ),
                            Text(
                              "View cmt",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 15,
                            ),
                            Text(
                              "Comment",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                            Text(
                              "Read more",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment_bank,
                              size: 15,
                            ),
                            Text(
                              "View cmt",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 15,
                            ),
                            Text(
                              "Comment",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                            Text(
                              "Read more",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment_bank,
                              size: 15,
                            ),
                            Text(
                              "View cmt",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 15,
                            ),
                            Text(
                              "Comment",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                            Text(
                              "Read more",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment_bank,
                              size: 15,
                            ),
                            Text(
                              "View cmt",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 15,
                            ),
                            Text(
                              "Comment",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                            Text(
                              "Read more",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment_bank,
                              size: 15,
                            ),
                            Text(
                              "View cmt",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 15,
                            ),
                            Text(
                              "Comment",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Color(0xffb6c5c1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 15,
                            ),
                            Text(
                              "Read more",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment_bank,
                              size: 15,
                            ),
                            Text(
                              "View cmt",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 85,
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 15,
                            ),
                            Text(
                              "Comment",
                              style: TextStyle(
                                  fontSize: 10, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
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
