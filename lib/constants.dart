import 'package:flutter/material.dart';

// App colors
const Color primaryColor = Color(0xFF4CAF50); // Green color for the app
const Color accentColor = Color(0xFF66BB6A);
const Color backgroundColor = Color(0xFFF5F5F5);
const Color textColor = Color(0xFF212121);
const Color secondaryTextColor = Color(0xFF757575);

// App theme paddings
const double defaultPadding = 16.0;
const double smallPadding = 8.0;
const double largePadding = 24.0;

// Text styles
const TextStyle headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: textColor,
);

const TextStyle subheadingStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: textColor,
);

const TextStyle bodyStyle = TextStyle(
  fontSize: 16,
  color: textColor,
);

// API Keys - DO NOT hardcode API keys here in production
// Use environment variables or secure storage options
const String openWeatherMapApiKey = "YOUR_OPENWEATHERMAP_API_KEY"; 
const String openAIApiKey = "YOUR_OPENAI_API_KEY"; 

// For development, create a local_constants.dart file that is in .gitignore
// and import those keys from there 