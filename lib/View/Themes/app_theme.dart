import 'package:flutter/material.dart';

ThemeData appTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodySmall:
          TextStyle(color: Colors.black, fontFamily: "regular", fontSize: 16),
      bodyMedium:
          TextStyle(color: Colors.black, fontFamily: "medium", fontSize: 20),
      bodyLarge:
          TextStyle(color: Colors.black, fontFamily: "bold", fontSize: 22),
    ).apply());
