import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'splash_screen_1.dart';
import 'splash_screen_2.dart';
import 'splash_screen_3.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'verification_screen.dart';
import 'dashboard_screen.dart';
import 'forgot_password/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    // Replace print with a logging mechanism in production
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    // Handle Firebase initialization failure gracefully
    debugPrint('Firebase initialization error: $e');
    // Optionally, show an error screen or retry initialization
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
        ).copyWith(
          surface: Colors.white, // Ensure Material 3 compatibility
        ),
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
        '/forgot_password': (context) => const ForgotPasswordScreen(), // Added route
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/verification_screen') {
          // Safely handle arguments
          if (settings.arguments is Map<String, String>?) {
            final args = settings.arguments as Map<String, String>?;
            return MaterialPageRoute(
              builder: (context) => VerificationScreen(
                email: args?['email'] ?? '',
                verificationCode: args?['verificationCode'] ?? '',
              ),
            );
          }
          // Fallback for invalid arguments
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Invalid verification arguments')),
            ),
          );
        }
        // Improved fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
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
          debugPrint('StreamBuilder error: ${snapshot.error}');
          return const Scaffold(
            body: Center(child: Text('Error loading authentication state')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('StreamBuilder: Waiting for auth state');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('User logged in: ${snapshot.data!.email}');
          return const DashboardScreen();
        }

        debugPrint('No user logged in, showing SplashScreen1');
        return const SplashScreen1();
      },
    );
  }
}