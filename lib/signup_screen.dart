import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'login_screen.dart';
import 'verification_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    }).catchError((e) {
      print('Firebase initialization error: $e');
    });
  }

  Future<String> generateVerificationCode() async {
    var random = Random();
    int code = 100000 + random.nextInt(900000);
    String codeStr = code.toString();
    if (codeStr.length != 6) {
      print('Generated code length issue: $codeStr');
      return '000000';
    }
    return codeStr;
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }
  }

  Future<void> sendVerificationEmail(String email, String code) async {
    const String apiKey = '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';
    final url = Uri.parse('https://api.brevo.com/v3/smtp/email');

    try {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Invalid email address format: $email');
      }

      final response = await http.post(
        url,
        headers: {
          'api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'sender': {'name': 'NutriCycle', 'email': 'micodelacruz519@gmail.com'}, // Replace with verified email
          'to': [{'email': email, 'name': 'User'}],
          'subject': 'Your Verification Code',
          'htmlContent': '<h1>Verification Code</h1><p>Your verification code is <strong>${code}</strong>. Please enter it to complete your sign-up.</p>',
        }),
      );

      print('API Response Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode != 201) {
        throw Exception('Failed to send email. Status: ${response.statusCode}, Message: ${response.body}');
      }
    } catch (e) {
      print('Error in sendVerificationEmail: $e');
      throw Exception('Failed to send verification email. Details: $e');
    }
  }

  Future<void> _signUp() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    try {
      await checkConnectivity();
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final code = await generateVerificationCode();
      print('Sending initial code $code to ${_emailController.text.trim()}');
      await sendVerificationEmail(_emailController.text.trim(), code);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: _emailController.text.trim(),
            verificationCode: code,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is disabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFEF8C2),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Image.asset(
                      'assets/nutricyclelogo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0B440E),
                      ),
                    ),
                    const Text(
                      'Join the NutriCycle.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B440E),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Enter your Email Address',
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF0B440E),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorText: _errorMessage,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Enter your Password',
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF0B440E),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm your Password',
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF0B440E),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B440E),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        fixedSize: const Size(283, 53),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFEF8C2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0B440E),
                            ),
                          ),
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0B440E),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/login_screen');
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}