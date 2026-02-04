import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/crop_detail_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/market_dashboard.dart';
import 'screens/weather_dashboard.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Agribusiness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      // ✅ Start app at login
      initialRoute: '/login',

      // ✅ Define all routes
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),    // Modern dashboard
        '/crops': (context) => const CropsScreen(),  // Crops list
        '/signup': (context) => SignupScreen(),
        '/market': (context) => const MarketDashboard(),
        '/weather': (context) => const WeatherDashboard(),
        
      },
    );
  }
}
