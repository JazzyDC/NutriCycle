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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp()
        .whenComplete(() {
          setState(() {});
        })
        .catchError((e) {
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
    const String apiKey =
        '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';
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
          'sender': {
            'name': 'NutriCycle',
            'email': 'micodelacruz519@gmail.com',
          },
          'to': [
            {'email': email, 'name': 'User'},
          ],
          'subject': 'Your Verification Code',
          'htmlContent':
              '<h1>Verification Code</h1><p>Your verification code is <strong>$code</strong>. Please enter it to complete your sign-up.</p>',
        }),
      );

      print(
        'API Response Status: ${response.statusCode}, Body: ${response.body}',
      );
      if (response.statusCode != 201) {
        throw Exception(
          'Failed to send email. Status: ${response.statusCode}, Message: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in sendVerificationEmail: $e');
      throw Exception('Failed to send verification email. Details: $e');
    }
  }

  Future<void> _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    bool hasError = false;

    setState(() {
      _emailError = null;
      if (email.isEmpty) {
        _emailError = 'Email is required.';
        hasError = true;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Invalid email format.';
        hasError = true;
      }

      _passwordError = null;
      if (password.isEmpty) {
        _passwordError = 'Password is required.';
        hasError = true;
      } else if (password.length < 8) {
        _passwordError = 'Password must be at least 8 characters.';
        hasError = true;
      } else if (!RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
      ).hasMatch(password)) {
        _passwordError =
            'Password must include uppercase, lowercase, number, and special character.';
        hasError = true;
      }

      _confirmError = null;
      if (confirmPassword != password) {
        _confirmError = 'Passwords do not match.';
        hasError = true;
      }

      _generalError = null;
    });

    if (hasError) {
      return;
    }

    try {
      await checkConnectivity();
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final code = await generateVerificationCode();
      print('Sending initial code $code to $email');
      await sendVerificationEmail(email, code);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  VerificationScreen(email: email, verificationCode: code),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e.code);
      if (e.code == 'invalid-email' || e.code == 'email-already-in-use') {
        setState(() {
          _emailError = errorMessage;
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          _passwordError = errorMessage;
        });
      } else {
        setState(() {
          _generalError = errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _generalError = 'An unexpected error occurred. Please try again.';
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
                      'assets/Logo.png',
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
                            fontWeight: FontWeight.w500
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 1,
                            ),
                          ),
                          errorText: _emailError,
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF0B440E),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Enter your Password',
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF0B440E),
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 1,
                            ),
                          ),
                          errorText: _passwordError,
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF0B440E),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF0B440E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm your Password',
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF0B440E),
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B440E),
                              width: 1,
                            ),
                          ),
                          errorText: _confirmError,
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF0B440E),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF0B440E),
                        ),
                      ),
                    ),
                    if (_generalError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text(
                          _generalError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B440E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
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
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                      context,
                                      '/login_screen',
                                    );
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