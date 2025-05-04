import 'package:flutter/material.dart';
import 'package:hortimize/climate/climate.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/providers/openai_provider.dart';
import 'package:provider/provider.dart';

class ExpertSuggestionsPage extends StatefulWidget {
  const ExpertSuggestionsPage({super.key});

  @override
  State<ExpertSuggestionsPage> createState() => _ExpertSuggestionsPageState();
}

class _ExpertSuggestionsPageState extends State<ExpertSuggestionsPage> {
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final openAIProvider = Provider.of<OpenAIProvider>(context);
    
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("asset/images/homescreen.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SafeArea(
            child: Card(
              elevation: 0,
              color: Color(0xffd8d8d8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '"Ask an Expert"',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
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
                      decoration: BoxDecoration(
                        color: Color(0xffb6c5c1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: TextField(
                        controller: _questionController,
                        decoration: InputDecoration(
                          hintText: 'Ask about farming, crops, market trends in Tamil Nadu...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                        ),
                        style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async {
                        if (_questionController.text.isNotEmpty) {
                          // Get expert suggestion through OpenAI
                          await openAIProvider.getExpertSuggestion(_questionController.text);
                          // Hide keyboard
                          FocusScope.of(context).unfocus();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff4CAF50),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      'Expert',
                      style: TextStyle(
                        fontSize: 16, 
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffb6c5c1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: openAIProvider.isLoading
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.green,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Getting expert advice...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : openAIProvider.error.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      openAIProvider.error,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Poppins",
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                : openAIProvider.suggestion.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: SingleChildScrollView(
                                          physics: BouncingScrollPhysics(),
                                          child: Text(
                                            openAIProvider.suggestion,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Poppins",
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(
                                          'Ask a question to get expert advice on farming, crop markets, and climate in Tamil Nadu.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ),
                      ),
                    ),
                  ],
                ),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MarketDemandPage()));
            } else if (index == 2) {
              Navigator.pop(context);
            } else if (index == 3) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Climate()));
            }
          }),
    );
  }
}
