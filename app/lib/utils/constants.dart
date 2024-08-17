import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  // Name
  static String appName = "e-Learning";
  static String uri = 'http://192.168.1.7:5000';

  // Material Design Color
  static Color lightPrimary = Color(0xfffcfcff);
  static Color lightAccent = Color(0xFFF18C8E);
  static Color lightBackground = Color(0xfffcfcff);

  static Color grey = Color(0xff707070);
  static Color textPrimary = Color(0xFF486581);
  static Color textDark = Color(0xFF305F72);

  // Salmon
  static Color salmonMain = Color(0xFFF18C8E);
  static Color salmonDark = Color(0xFFBB7F87);
  static Color salmonLight = Color(0xFFF19895);

  // Blue
  static Color blueMain = Color(0xFF579ACA);
  static Color blueDark = Color(0xFF4E92B1);
  static Color blueLight = Color(0xFF5AA6C8);

  // Pink
  static Color lightPink = Color(0xFFFAE4F4);

  // Yellow
  static Color lightYellow = Color(0xFFFFF5E5);

  // Violet
  static Color lightViolet = Color(0xFFFBF5FF);

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      primaryColor: lightPrimary,
      hintColor: lightAccent,
      cardColor: lightAccent,
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          color: lightAccent,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: lightPrimary,
        secondary: lightAccent,
        background: lightBackground,
      ),
    );
  }

  static double headerHeight = 228.5;
  static double mainPadding = 20.0;
}
