import 'dart:convert';

class MarketData {
  final List<Commodity> commodities;

  MarketData({required this.commodities});

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      commodities: List<Commodity>.from(
        json['commodities'].map((x) => Commodity.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'commodities': List<dynamic>.from(commodities.map((x) => x.toJson())),
      };
}

class Commodity {
  final String name;
  final String unit;
  final Map<String, double> priceByRegion;
  final List<String> demandRanking;
  final Map<String, double> priceTrend;

  Commodity({
    required this.name,
    required this.unit,
    required this.priceByRegion,
    required this.demandRanking,
    required this.priceTrend,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    // Helper function to convert values to double
    Map<String, double> _convertToDoubleMap(Map<String, dynamic> map) {
      return map.map((key, value) => MapEntry(key, value.toDouble()));
    }
    
    return Commodity(
      name: json['name'],
      unit: json['unit'],
      priceByRegion: _convertToDoubleMap(Map<String, dynamic>.from(json['price_by_region'])),
      demandRanking: List<String>.from(json['demand_ranking']),
      priceTrend: _convertToDoubleMap(Map<String, dynamic>.from(json['price_trend'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'unit': unit,
        'price_by_region': priceByRegion,
        'demand_ranking': demandRanking,
        'price_trend': priceTrend,
      };
}

// Market data - static access to the data
final marketDataJson = '''
{
  "commodities": [
    {
      "name": "Tomato",
      "unit": "kg",
      "price_by_region": {
        "Chennai": 40,
        "Madurai": 38,
        "Coimbatore": 35,
        "Salem": 32,
        "Trichy": 30
      },
      "demand_ranking": ["Chennai", "Madurai", "Coimbatore", "Salem", "Trichy"],
      "price_trend": {
        "January": 32,
        "February": 34,
        "March": 35,
        "April": 38,
        "May": 40
      }
    },
    {
      "name": "Rice",
      "unit": "kg",
      "price_by_region": {
        "Thanjavur": 55,
        "Chennai": 53,
        "Madurai": 50,
        "Erode": 48,
        "Trichy": 45
      },
      "demand_ranking": ["Thanjavur", "Chennai", "Madurai", "Erode", "Trichy"],
      "price_trend": {
        "January": 45,
        "February": 47,
        "March": 49,
        "April": 52,
        "May": 55
      }
    },
    {
      "name": "Onion",
      "unit": "kg",
      "price_by_region": {
        "Chennai": 28,
        "Erode": 26,
        "Trichy": 25,
        "Madurai": 24,
        "Coimbatore": 22
      },
      "demand_ranking": ["Chennai", "Erode", "Trichy", "Madurai", "Coimbatore"],
      "price_trend": {
        "January": 22,
        "February": 24,
        "March": 26,
        "April": 27,
        "May": 28
      }
    },
    {
      "name": "Potato",
      "unit": "kg",
      "price_by_region": {
        "Madurai": 33,
        "Chennai": 32,
        "Trichy": 30,
        "Erode": 28,
        "Salem": 27
      },
      "demand_ranking": ["Madurai", "Chennai", "Trichy", "Erode", "Salem"],
      "price_trend": {
        "January": 27,
        "February": 29,
        "March": 30,
        "April": 32,
        "May": 33
      }
    }
  ]
}
''';

// Parse the JSON string into a MarketData object for easy use in the app
final MarketData marketData = MarketData.fromJson(json.decode(marketDataJson));