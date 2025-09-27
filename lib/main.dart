import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen_1.dart'; // Adjust the import path based on your file structure
import 'splash_screen_2.dart';
import 'splash_screen_3.dart';
import 'login_screen.dart';
import 'signup_screen.dart'; // New signup screen
import 'verification_screen.dart'; // New verification screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCycle', // Replace with your app name
      theme: ThemeData(
        primarySwatch: Colors.green, // Optional: Set a theme
      ),
      initialRoute: '/', // Start with SplashScreen1
      routes: {
        '/': (context) => SplashScreen1(), // SplashScreen1 as the entry point
        '/splash_screen_2': (context) => SplashScreen2(), // Route to SplashScreen2
        '/splash_screen_3': (context) => SplashScreen3(), // Route to SplashScreen3
        '/login_screen': (context) => LoginScreen(), // Route to LoginScreen
        '/signup_screen': (context) => SignupScreen(), // Route to SignupScreen
        '/verification_screen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return VerificationScreen(
            email: args['email'] ?? '',
            verificationCode: args['verificationCode'] ?? '',
          );
        }, // Route to VerificationScreen
      },
    );
  }
}