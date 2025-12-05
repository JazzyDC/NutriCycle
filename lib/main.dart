import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen_1.dart';
import 'splash_screen_2.dart';
import 'splash_screen_3.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'verification_screen.dart';
import 'dashboard_screen.dart';
import 'forgot_password/forgot_password_screen.dart';
import 'forgot_password/verification_screenpassword.dart';
import 'processing_navigation_screen.dart';
// FIXED: removed the trailing space here
import 'recognition_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriCycle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(surface: Colors.white),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/splash_screen_1': (context) => const SplashScreen1(),
        '/splash_screen_2': (context) => const SplashScreen2(),
        '/splash_screen_3': (context) => const SplashScreen3(),
        '/login_screen': (context) => const LoginScreen(),
        '/signup_screen': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/verification_screens': (context) => const VerificationSScreen(),
        // This one was missing in your routes map – added it so you can navigate directly
        '/processing_navigation': (context) => const ProcessingNavigationScreen(),
        '/recognition_screen': (context) => const RecognitionScreen(),
      },
      onGenerateRoute: (settings) {
        // Handles /verification_screen?email=...&code=...
        if (settings.name == '/verification_screen') {
          final args = settings.arguments as Map<String, String>?;
          return MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: args?['email'] ?? '',
              verificationCode: args?['verificationCode'] ?? '',
            ),
          );
        }
        return null; // let Flutter use the normal routes map for everything else
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Authentication error')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        return const SplashScreen1();
      },
    );
  }
}