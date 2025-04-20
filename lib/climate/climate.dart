import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:weather_icons/weather_icons.dart';
import '../services/weather_service.dart';
import 'dart:async';
import '../constants.dart';
import 'package:hortimize/climate/hazard_alert.dart';
import 'package:hortimize/hero_page/hero_page.dart';
import 'package:hortimize/market_demand/market_demand.dart';
import 'package:hortimize/plans/plans.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Climate extends StatefulWidget {
  const Climate({Key? key}) : super(key: key);

  @override
  _ClimateState createState() => _ClimateState();
}

class _ClimateState extends State<Climate> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  
  // Current weather data
  WeatherData? _currentWeather;
  ForecastData? _forecast;
  
  // Location info
  double? _currentLat;
  double? _currentLon;
  String _locationName = "";
  
  // Status flags
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  bool _usingCurrentLocation = true;
  
  // Cache control
  final Duration _cacheExpiration = const Duration(minutes: 30);
  DateTime? _lastFetchTime;
  
  @override
  void initState() {
    super.initState();
    _loadWeatherFromCacheOrFetch();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Check cache and load data accordingly
  Future<void> _loadWeatherFromCacheOrFetch() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    // Try to load from cache first
    final success = await _loadFromCache();
    
    // If cache loading failed or cache is expired, fetch fresh data
    if (!success) {
      await _loadCurrentLocationWeather();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Save current weather data to cache
  Future<void> _saveToCache() async {
    if (_currentWeather == null || _forecast == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Build a cache object containing all necessary data
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'locationName': _locationName,
        'lat': _currentLat,
        'lon': _currentLon,
        'usingCurrentLocation': _usingCurrentLocation,
        'weather': jsonEncode(_currentWeather),
        'forecast': jsonEncode(_forecast),
      };
      
      // Save as JSON string
      await prefs.setString('weather_cache', jsonEncode(cacheData));
      _lastFetchTime = DateTime.now();
    } catch (e) {
      debugPrint('Error saving weather to cache: $e');
    }
  }
  
  // Load weather data from cache
  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString('weather_cache');
      
      if (cacheString == null) return false;
      
      final cacheData = jsonDecode(cacheString);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
      
      // Check if cache is expired
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        return false;
      }
      
      // Restore from cache
      setState(() {
        _locationName = cacheData['locationName'];
        _currentLat = cacheData['lat'];
        _currentLon = cacheData['lon'];
        _usingCurrentLocation = cacheData['usingCurrentLocation'];
        _searchController.text = _locationName;
        _lastFetchTime = timestamp;
        
        // Parse weather and forecast from JSON
        // Note: This is a simplified approximation as we can't directly deserialize from JSON
        // In a real implementation, you'd use proper serialization/deserialization
        _currentWeather = WeatherData.fromJson(jsonDecode(cacheData['weather']));
        _forecast = ForecastData.fromJson(jsonDecode(cacheData['forecast']));
      });
      
      return true;
    } catch (e) {
      debugPrint('Error loading weather from cache: $e');
      return false;
    }
  }
  
  // Load weather for current location
  Future<void> _loadCurrentLocationWeather() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
      _usingCurrentLocation = true;
    });
    
    try {
      // Get current location
      final position = await _weatherService.getCurrentLocation();
      _currentLat = position.latitude;
      _currentLon = position.longitude;
      
      // Start parallel operations
      final locationNameFuture = _weatherService.getLocationName(_currentLat!, _currentLon!);
      final weatherFuture = _weatherService.getWeatherByLocation(_currentLat!, _currentLon!);
      final forecastFuture = _weatherService.getForecastByLocation(_currentLat!, _currentLon!);
      
      // Wait for all operations to complete
      final results = await Future.wait([locationNameFuture, weatherFuture, forecastFuture]);
      
      _locationName = results[0] as String;
      _currentWeather = results[1] as WeatherData;
      _forecast = results[2] as ForecastData;
      
      _searchController.text = _locationName;
      
      // Save to cache
      _saveToCache();
      
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }
  
  // Load weather data for any location (by coordinates)
  Future<void> _loadWeatherData(double lat, double lon) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = "";
      });
      
      _currentLat = lat;
      _currentLon = lon;
      
      // Run API calls in parallel
      final weatherFuture = _weatherService.getWeatherByLocation(lat, lon);
      final forecastFuture = _weatherService.getForecastByLocation(lat, lon);
      
      final results = await Future.wait([weatherFuture, forecastFuture]);
      
      final weather = results[0] as WeatherData;
      final forecast = results[1] as ForecastData;
      
      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
        _hasError = false;
        
        // Save to cache
        _saveToCache();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "Failed to load weather data: ${e.toString()}";
      });
    }
  }
  
  // Load weather data for any location (by city name)
  Future<void> _loadWeatherByCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
      _usingCurrentLocation = false;
    });
    
    try {
      // Run API calls in parallel
      final weatherFuture = _weatherService.getWeatherByCity(cityName);
      final forecastFuture = _weatherService.getForecastByCity(cityName);
      
      final results = await Future.wait([weatherFuture, forecastFuture]);
      
      final weather = results[0] as WeatherData;
      final forecast = results[1] as ForecastData;
      
      // Update location data
      _currentLat = weather.latitude;
      _currentLon = weather.longitude;
      _locationName = "${weather.cityName}, ${weather.country}";
      
      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
        
        // Save to cache
        _saveToCache();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "Failed to load weather data: ${e.toString()}";
      });
    }
  }
  
  // Helper to get weather icon based on condition code
  IconData _getWeatherIcon(String iconCode) {
    // Convert OpenWeatherMap icon code to appropriate icon
    switch (iconCode.substring(0, 2)) {
      case '01': // clear sky
        return WeatherIcons.day_sunny;
      case '02': // few clouds
        return WeatherIcons.day_cloudy;
      case '03': // scattered clouds
        return WeatherIcons.cloud;
      case '04': // broken clouds
        return WeatherIcons.cloudy;
      case '09': // shower rain
        return WeatherIcons.showers;
      case '10': // rain
        return WeatherIcons.rain;
      case '11': // thunderstorm
        return WeatherIcons.thunderstorm;
      case '13': // snow
        return WeatherIcons.snow;
      case '50': // mist
        return WeatherIcons.fog;
      default:
        return WeatherIcons.day_sunny;
    }
  }

  // Build shimmer placeholder for current weather
  Widget _buildCurrentWeatherShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          
          // Forecast header shimmer
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          
          // Forecast list shimmer
          Container(
            height: 130,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                );
              },
            ),
          ),
          
          // Hazard alert button shimmer
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  // Build current weather display
  Widget _buildCurrentWeather() {
    if (_currentWeather == null) {
      return const Center(child: Text("No weather data available"));
    }
    
    return Column(
      children: [
        // Current weather display
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _locationName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _lastFetchTime != null 
                              ? "Updated ${_getTimeAgo(_lastFetchTime!)}" 
                              : "Updated just now",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _usingCurrentLocation 
                        ? _loadCurrentLocationWeather
                        : () => _loadWeatherByCity(_locationName),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(
                        _getWeatherIcon(_currentWeather!.icon),
                        size: 60,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentWeather!.description,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "${_currentWeather!.temperature.toStringAsFixed(1)}°C",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Feels like: ${_currentWeather!.feelsLike.toStringAsFixed(1)}°C",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherInfoItem(
                    WeatherIcons.humidity,
                    "${_currentWeather!.humidity}%",
                    "Humidity",
                  ),
                  _buildWeatherInfoItem(
                    WeatherIcons.wind,
                    "${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s",
                    "Wind",
                  ),
                  _buildWeatherInfoItem(
                    WeatherIcons.barometer,
                    "${_currentWeather!.pressure} hPa",
                    "Pressure",
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Forecast header
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Row(
            children: const [
              Icon(Icons.access_time),
              SizedBox(width: 8),
              Text(
                "Forecast",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Forecast list
        _buildForecastList(),
        
        // Hazard alert button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HazardAlert()),
              );
            },
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
            label: const Text(
              "View Weather Hazard Alerts",
              style: TextStyle(color: Colors.white, fontFamily: "Poppins"),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Get time ago string
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return "just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago";
    } else {
      return "${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago";
    }
  }
  
  // Build weather info item with icon, value and label
  Widget _buildWeatherInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: primaryColor),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Build shimmer placeholder for forecast list
  Widget _buildForecastShimmer() {
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Build forecast list display
  Widget _buildForecastList() {
    if (_forecast == null || _forecast!.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No forecast data available"),
      );
    }
    
    // Display only next 6 items for simplicity
    final nextItems = _forecast!.items.take(6).toList();
    
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: nextItems.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final item = nextItems[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "${item.dateTime.hour}:00",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _getWeatherIcon(item.icon),
                  size: 30,
                  color: primaryColor,
                ),
                Text(
                  "${item.temperature.toStringAsFixed(1)}°C",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${item.rainProbability.toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Build loading indicator
  Widget _buildLoadingIndicator() {
    return _buildCurrentWeatherShimmer();
  }
  
  // Build error display
  Widget _buildErrorDisplay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              "Error loading weather data",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadCurrentLocationWeather,
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
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
          "Climate",
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
      body: SafeArea(
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
            children: [
                  Expanded(
                    child: TypeAheadField<CityData>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _searchController,
                decoration: InputDecoration(
                          hintText: 'Search location',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                  border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 20,
                          ),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        if (pattern.length < 3) return [];
                        return await _weatherService.getLocationSuggestions(pattern);
                      },
                      itemBuilder: (context, CityData suggestion) {
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(suggestion.name),
                          subtitle: Text(
                            suggestion.state.isNotEmpty
                                ? "${suggestion.state}, ${suggestion.country}"
                                : suggestion.country,
                          ),
                        );
                      },
                      onSuggestionSelected: (CityData suggestion) {
                        _searchController.text = suggestion.toString();
                        _loadWeatherData(suggestion.latitude, suggestion.longitude);
                      },
                      noItemsFoundBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No locations found. Try a different search term."),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _loadCurrentLocationWeather,
                    tooltip: "Use current location",
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _usingCurrentLocation
                  ? _loadCurrentLocationWeather
                  : () => _loadWeatherByCity(_locationName),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _isLoading
                      ? _buildLoadingIndicator()
                      : _hasError
                          ? _buildErrorDisplay()
                          : _buildCurrentWeather(),
                ),
                ),
              ),
            ],
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
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
            } else if (index == 1) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MarketDemandPage()));
            } else if (index == 2) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeroPage()),
                (route) =>
                    false, // This removes all previous routes from the stack
              );
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PlansPage()));
            }
          }),
    );
  }
}
