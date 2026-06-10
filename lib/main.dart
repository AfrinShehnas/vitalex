import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ✅ ALL SCREENS
import 'screens/welcome/welcome_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/profile/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VitalexApp());
}

class VitalexApp extends StatelessWidget {
  const VitalexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vitalex',

      // ✅ START SCREEN
      home: const WelcomePage(),

      // ✅ ROUTES
      routes: {
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DashboardPage(),
        '/profile': (context) => ProfilePage(),
      },

      // ✅ THEME
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFE8F5E9),
        fontFamily: 'Roboto',
      ),
    );
  }
}