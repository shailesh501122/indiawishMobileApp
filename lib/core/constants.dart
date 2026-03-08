import 'package:flutter/material.dart';

class AppColors {
  // OLX-style primary dark blue
  static const Color primary = Color(0xFF002F5A);
  // OLX header/appbar blue
  static const Color headerBlue = Color(0xFF0A2B6B);
  // OLX featured badge yellow
  static const Color featured = Color(0xFFFFCD00);
  // OLX sell button ring (yellow-green)
  static const Color sellRing = Color(0xFFF2C300);
  // OLX sell button inner (teal/blue)
  static const Color sellButton = Color(0xFF002F5A);
  // Accent light blue
  static const Color accent = Color(0xFFE8EEF5);
  // Background
  static const Color background = Color(0xFFF7F7F7);
  // White
  static const Color white = Colors.white;
  // Black / text
  static const Color black = Color(0xFF1A1A1A);
  // Dark text
  static const Color darkText = Color(0xFF0D1B2A);
  // Grey
  static const Color grey = Color(0xFF767676);
  // Light grey for borders/dividers
  static const Color lightGrey = Color(0xFFE0E0E0);
  // Success/active green
  static const Color success = Color(0xFF2E7D32);
  // Swiggy-style Orange
  static const Color swiggyOrange = Color(0xFFFC8019);
  // Price color (dark)
  static const Color priceColor = Color(0xFF002F5A);
  // Secondary text
  static const Color secondaryText = Color(0xFF8E9BAD);
}

class ApiConfig {
  // Use Render for production
  static const String baseUrl = 'https://holaboxpython-wbfy.onrender.com/api';
  static const String socketUrl = 'https://holaboxpython-wbfy.onrender.com';

  // FOR LOCAL TESTING
  // static const String baseUrl = 'http://10.210.168.90:8000/api'; 
  // static const String socketUrl = 'http://10.210.168.90:8000';
}
