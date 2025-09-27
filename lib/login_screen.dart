import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import 'signup_screen.dart'; // Ensure this file exists

class LoginScreen extends StatefulWidget {
  final String imageAsset;

  const LoginScreen({this.imageAsset = 'assets/nutricyclelogo.png', super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Ensure Firebase is initialized
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> _login() async {
    try {
      // Attempt to sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to home screen or another screen after successful login
      Navigator.pushReplacementNamed(context, '/home'); // Replace with your home route
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
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    const SizedBox(height: 50),
                    Image.asset(
                      widget.imageAsset,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Welcome to NutriCycle',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0B440E),
                      ),
                    ),
                    const Text(
                      'Log in to manage cabbage waste',
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
                          labelText: 'Email Address',
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
                          labelText: 'Password',
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
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          if (_emailController.text.isEmpty) {
                            setState(() {
                              _errorMessage = 'Please enter an email address.';
                            });
                            return;
                          }
                          try {
                            await _auth.sendPasswordResetEmail(
                                email: _emailController.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Password reset email sent!')),
                            );
                          } catch (e) {
                            setState(() {
                              _errorMessage =
                                  'Failed to send reset email. Please try again.';
                            });
                          }
                        },
                        child: const Text(
                          'Forgot password',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B440E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B440E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        fixedSize: const Size(283, 53),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Login',
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
                            text: "Don't have an account? ",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0B440E),
                            ),
                          ),
                          TextSpan(
                            text: 'Sign up',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0B440E),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/signup_screen');
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