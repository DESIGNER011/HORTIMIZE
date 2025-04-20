import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  // Replace with your OpenWeatherMap API key
  static const String apiKey = '817f99579de02f409fe41fe80b4af852';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoUrl = 'https://api.openweathermap.org/geo/1.0';

  // Get weather data by city name
  Future<WeatherData> getWeatherByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?q=$city&units=metric&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting weather: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  // Get weather data by latitude and longitude
  Future<WeatherData> getWeatherByLocation(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting weather: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  // Get forecast data (5 days, 3-hour intervals)
  Future<ForecastData> getForecastByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forecast?q=$city&units=metric&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        return ForecastData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting forecast: $e');
      throw Exception('Failed to load forecast data: $e');
    }
  }

  // Get forecast data by coordinates
  Future<ForecastData> getForecastByLocation(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        return ForecastData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting forecast: $e');
      throw Exception('Failed to load forecast data: $e');
    }
  }

  // Get the user's current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can get the location
    return await Geolocator.getCurrentPosition();
  }

  // Get location suggestions for search
  Future<List<CityData>> getLocationSuggestions(String query) async {
    try {
      if (query.length < 3) return []; // Only search for 3+ characters
      
      final response = await http.get(
        Uri.parse('$geoUrl/direct?q=$query&limit=5&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((city) => CityData.fromJson(city)).toList();
      } else {
        throw Exception('Failed to load city suggestions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting city suggestions: $e');
      return [];
    }
  }

  // Get the name of a location from coordinates
  Future<String> getLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (place.locality != null && place.locality!.isNotEmpty) {
          return place.locality!;
        } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          return place.administrativeArea!;
        } else {
          return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
        }
      }
      return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
    } catch (e) {
      debugPrint('Error getting location name: $e');
      return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
    }
  }
}

// Model for storing weather data
class WeatherData {
  final String cityName;
  final String country;
  final double latitude;
  final double longitude;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime sunrise;
  final DateTime sunset;
  final int pressure;
  final int visibility;
  final double rainLastHour;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.pressure,
    required this.visibility,
    this.rainLastHour = 0,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // Extract rain data if available
    double rain = 0;
    if (json.containsKey('rain') && json['rain'] != null) {
      if (json['rain'].containsKey('1h')) {
        rain = (json['rain']['1h'] as num).toDouble();
      }
    }

    return WeatherData(
      cityName: json['name'] ?? 'Unknown',
      country: json['sys']?['country'] ?? '',
      latitude: json['coord']?['lat']?.toDouble() ?? 0.0,
      longitude: json['coord']?['lon']?.toDouble() ?? 0.0,
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: json['main']?['humidity'] as int? ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      description: json['weather']?[0]?['description'] ?? 'Unknown',
      icon: json['weather']?[0]?['icon'] ?? '01d',
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']?['sunrise'] as int? ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']?['sunset'] as int? ?? 0) * 1000),
      pressure: json['main']?['pressure'] as int? ?? 0,
      visibility: json['visibility'] as int? ?? 0,
      rainLastHour: rain,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

// Model for forecast data
class ForecastData {
  final String cityName;
  final String country;
  final List<ForecastItem> items;

  ForecastData({
    required this.cityName,
    required this.country,
    required this.items,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    List<ForecastItem> forecastItems = [];
    
    if (json.containsKey('list')) {
      forecastItems = (json['list'] as List)
          .map((item) => ForecastItem.fromJson(item))
          .toList();
    }

    return ForecastData(
      cityName: json['city']?['name'] ?? 'Unknown',
      country: json['city']?['country'] ?? '',
      items: forecastItems,
    );
  }
}

// Model for individual forecast item
class ForecastItem {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final double windSpeed;
  final int humidity;
  final double rainProbability;

  ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.humidity,
    this.rainProbability = 0,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['weather']?[0]?['description'] ?? 'Unknown',
      icon: json['weather']?[0]?['icon'] ?? '01d',
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      humidity: json['main']?['humidity'] as int? ?? 0,
      rainProbability: json.containsKey('pop') ? (json['pop'] as num).toDouble() * 100 : 0,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

// Model for city suggestion data
class CityData {
  final String name;
  final String country;
  final String state;
  final double latitude;
  final double longitude;

  CityData({
    required this.name,
    required this.country,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      name: json['name'] ?? 'Unknown',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    if (state.isNotEmpty) {
      return '$name, $state, $country';
    } else {
      return '$name, $country';
    }
  }
} 