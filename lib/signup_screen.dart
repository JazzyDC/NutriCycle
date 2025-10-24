import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'verification_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isTermsAccepted = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
      setState(() {});
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }

  Future<String> generateVerificationCode() async {
    var random = Random();
    int code = 100000 + random.nextInt(900000);
    String codeStr = code.toString();
    print('Generated verification code: $codeStr');
    return codeStr;
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print('Connectivity result: $connectivityResult');
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }
  }

  Future<void> sendVerificationEmail(String email, String code) async {
    const String apiKey = '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';
    final url = Uri.parse('https://api.brevo.com/v3/smtp/email');

    print('Attempting to send email to: $email with code: $code');

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
          'htmlContent': '<h1>Verification Code</h1><p>Your verification code is <strong>$code</strong>. Please enter it to complete your sign-up.</p>',
        }),
      );

      print('Email API Response Status: ${response.statusCode}');
      print('Email API Response Body: ${response.body}');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to send email. Status: ${response.statusCode}, Message: ${response.body}');
      }
      
      print('Email sent successfully!');
    } catch (e) {
      print('Error in sendVerificationEmail: $e');
      rethrow; // Re-throw to catch in _signUp
    }
  }

  Future<void> _signUp() async {
    print('===== SIGN UP STARTED =====');
    
    // Get trimmed values
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    print('Email: $email');
    print('Password length: ${password.length}');

    bool hasError = false;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
      _generalError = null;
    });

    // Validation
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required.';
      });
      hasError = true;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Invalid email format.';
      });
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required.';
      });
      hasError = true;
    } else if (password.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters.';
      });
      hasError = true;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(password)) {
      setState(() {
        _passwordError = 'Password must include uppercase, lowercase, number, and special character.';
      });
      hasError = true;
    }

    if (confirmPassword != password) {
      setState(() {
        _confirmError = 'Passwords do not match.';
      });
      hasError = true;
    }

    if (hasError) {
      print('Validation failed, stopping signup');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Check connectivity
      print('Step 1: Checking connectivity...');
      await checkConnectivity();
      print('✓ Connectivity OK');

      // Step 2: Create Firebase Auth user
      print('Step 2: Creating Firebase Auth user...');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;
      print('✓ User created with UID: $userId');

      // Step 3: Save to Firestore
      print('Step 3: Saving to Firestore...');
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'preferences': {},
      });
      print('✓ Firestore data saved');

      // Step 4: Generate verification code
      print('Step 4: Generating verification code...');
      final code = await generateVerificationCode();
      print('✓ Code generated: $code');

      // Step 5: Send verification email
      print('Step 5: Sending verification email...');
      await sendVerificationEmail(email, code);
      print('✓ Email sent');

      setState(() {
        _isLoading = false;
      });

      // Step 6: Navigate to verification screen
      print('Step 6: Navigating to verification screen...');
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: email,
              verificationCode: code,
            ),
          ),
        );
        print('✓ Navigation completed');
      } else {
        print('⚠ Widget not mounted, cannot navigate');
      }

      print('===== SIGN UP COMPLETED SUCCESSFULLY =====');
      
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      setState(() {
        _isLoading = false;
        String errorMessage = _getErrorMessage(e.code);
        if (e.code == 'invalid-email' || e.code == 'email-already-in-use') {
          _emailError = errorMessage;
        } else if (e.code == 'weak-password') {
          _passwordError = errorMessage;
        } else {
          _generalError = errorMessage;
        }
      });
    } on FirebaseException catch (e) {
      print('❌ FirebaseException (Firestore): ${e.code} - ${e.message}');
      setState(() {
        _isLoading = false;
        _generalError = 'Failed to save user data: ${e.message}';
      });
      // Try to delete the auth user if Firestore failed
      try {
        await _auth.currentUser?.delete();
        print('Deleted auth user due to Firestore failure');
      } catch (deleteError) {
        print('Could not delete auth user: $deleteError');
      }
    } catch (e) {
      print('❌ General error: $e');
      print('Error type: ${e.runtimeType}');
      setState(() {
        _isLoading = false;
        _generalError = 'An unexpected error occurred: ${e.toString()}';
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
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred: $code';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showTermsModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: const Color(0xFFFEF8C2),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    color: Color(0xFF0B440E),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      'By accessing and using the NutriCycle Mobile App, you agree to comply with and be bound by these Terms & Conditions. If you do not agree, please do not use the app.\n\n'
                      'NutriCycle is developed as an IoT- and AI-powered prototype designed to convert vegetable waste into poultry feed and compost. The app allows operators to:\n\n'
                      '• Monitor machine activity in real-time\n\n'
                      '• Track feed and compost production\n\n'
                      '• Receive system alerts and notifications\n\n'
                      'Users must provide accurate login details (e.g., email, password). The system should only be operated by trained personnel. Users must not misuse the app or attempt unauthorized access. Users are responsible for ensuring proper waste input (vegetable waste only).\n\n'
                      'The app may collect machine logs, processing data, and usage history. No personal financial or sensitive personal data is collected. All collected data is used solely for monitoring, development, and research.\n\n'
                      'NutriCycle is a prototype system and may not guarantee 100% accuracy or continuous availability. The developers are not liable for any misuse, equipment damage, or unintended consequences resulting from system use. Users acknowledge that the machine is not designed for unsupervised or large-scale operations.\n\n'
                      'All designs, concepts, and content of NutriCycle remain the property of the project developers. Users may not copy, redistribute, or commercially use the system without permission.\n\n'
                      'These Terms & Conditions may be updated as the system evolves. Users will be notified of significant changes within the app.\n\n'
                      'For inquiries, support, or feedback regarding NutriCycle, please contact us:\n\n'
                      'Email: nutricycle.project@gmail.com',
                      style: const TextStyle(
                        color: Color(0xFF0B440E),
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B440E),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFEF8C2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF0B440E),
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
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF0B440E),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
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
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _generalError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isTermsAccepted,
                            onChanged: (value) {
                              setState(() {
                                _isTermsAccepted = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF0B440E),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'By continuing you agree to our ',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0B440E),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0B440E),
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showTermsModal,
                                  ),
                                  const TextSpan(
                                    text: ' and ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Notice.',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0B440E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (_isLoading || !_isTermsAccepted) ? null : _signUp,
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
                        disabledBackgroundColor: const Color(0xFF0B440E).withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFFFEF8C2),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
                    const SizedBox(height: 40),
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