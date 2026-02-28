import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../features/cropz_card/presentation/pages/cropz_card_home_page.dart';

class CropzApp extends StatelessWidget {
  const CropzApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F766E);
    const secondary = Color(0xFF2563EB);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Cropz',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
        textTheme: GoogleFonts.manropeTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: colorScheme.primary.withOpacity(0.4)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      home: const CropzCardHomePage(),
    );
  }
}
