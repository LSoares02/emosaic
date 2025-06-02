import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(Color seed) => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
    useMaterial3: true,
    textTheme: TextTheme(
      titleLarge: GoogleFonts.poppins(
        fontSize: 50,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(fontSize: 24),
      bodyMedium: GoogleFonts.ibmPlexSans(fontSize: 16),
      bodySmall: GoogleFonts.ibmPlexSans(fontSize: 12),
      labelLarge: GoogleFonts.ibmPlexSans(fontSize: 14),
    ),
  );

  static ThemeData darkTheme(Color seed) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    textTheme: TextTheme(
      titleLarge: GoogleFonts.poppins(fontSize: 50),
      bodyLarge: GoogleFonts.ibmPlexSans(fontSize: 24),
      bodyMedium: GoogleFonts.ibmPlexSans(fontSize: 16),
      bodySmall: GoogleFonts.ibmPlexSans(fontSize: 12),
      labelLarge: GoogleFonts.ibmPlexSans(fontSize: 14),
    ),
  );
}
