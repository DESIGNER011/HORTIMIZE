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

// API Keys - Replace with actual keys in production
const String openWeatherMapApiKey = "YOUR_OPENWEATHERMAP_API_KEY"; 
const String openAIApiKey = "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"; 