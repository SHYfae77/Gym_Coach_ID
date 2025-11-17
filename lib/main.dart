import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GymCoachApp());
}

class GymCoachApp extends StatelessWidget {
  const GymCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan satu sumber warna (ColorScheme.fromSeed) dan Brightness.dark
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFFFF7A00), brightness: Brightness.dark);
    return MaterialApp(
      title: 'GymCoach ID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFF0E0E11),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withOpacity(0.55),
          selectedItemColor: scheme.primary,
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
