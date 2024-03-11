import 'package:flutter/material.dart';

ThemeData themeData() => ThemeData(
      fontFamily: "NotoSans",
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 30.0,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
        ),
      ),
    );
