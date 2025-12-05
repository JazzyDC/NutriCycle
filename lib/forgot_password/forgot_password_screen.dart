import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  // Static utility functions
  static Future<String> generateVerificationCode() async {
    var random = Random();
    int code = 100000 + random.nextInt(900000);
    String codeStr = code.toString();
    if (codeStr.length != 6) {
      print('Generated code length issue: $codeStr');
      return '000000';
    }
    return codeStr;
  }

  static Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }
  }

  static Future<void> sendVerificationEmail(String email, String code) async {
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
          'sender': {
            'name': 'NutriCycle',
            'email': 'micodelacruz519@gmail.com',
          },
          'to': [
            {'email': email, 'name': 'User'},
          ],
          'subject': 'Your Password Reset Code',
          'htmlContent':
              '<h1>Password Reset Verification</h1><p>Your verification code is <strong>$code</strong>. Please enter it to reset your password.</p>',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Failed to send email. Status: ${response.statusCode}, Message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _emailError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    }).catchError((e) {
      setState(() {
        _generalError = 'Failed to initialize Firebase: $e';
      });
    });
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    setState(() {
      _isLoading = true;
      _emailError = null;
      _generalError = null;
    });

    try {
      await ForgotPasswordScreen.checkConnectivity();
      final code = await ForgotPasswordScreen.generateVerificationCode();
      await ForgotPasswordScreen.sendVerificationEmail(email, code);
      Navigator.pushNamed(context, '/verification_screens', arguments: {
        'email': email,
        'verificationCode': code,
      });
    } catch (e) {
      setState(() {
        _generalError = 'Failed to send verification code: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B440E)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B440E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email address to receive a password reset link.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0B440E),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0B440E),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B440E),
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B440E),
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF0B440E),
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    errorText: _emailError,
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF2D2D2D),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                if (_generalError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _generalError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B440E),
                      foregroundColor: const Color(0xFFFEF8C2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFFEF8C2),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send Reset Link',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}