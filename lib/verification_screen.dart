    import 'package:flutter/material.dart';
    import 'package:http/http.dart' as http;
    import 'dart:convert';
    import 'dart:math';
    import 'package:connectivity_plus/connectivity_plus.dart';

    class VerificationScreen extends StatefulWidget {
      final String email;
      final String verificationCode;
      const VerificationScreen({
        super.key,
        required this.email,
        required this.verificationCode,
      });

      @override
      _VerificationScreenState createState() => _VerificationScreenState();
    }

    class _VerificationScreenState extends State<VerificationScreen> {
      late String currentVerificationCode;
      bool isVerified = false;
      final List<TextEditingController> _codeControllers = List.generate(
        6,
        (_) => TextEditingController(),
      );
      String? _errorMessage;
      String? _successMessage;

      @override
      void initState() {
        super.initState();
        currentVerificationCode = widget.verificationCode;
        print(
          'Initial email: ${widget.email}, Initial code: $currentVerificationCode',
        );
      }

      Future<void> checkConnectivity() async {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          throw Exception('No internet connection');
        }
      }

      void _verifyCode() {
        String enteredCode =
            _codeControllers.map((controller) => controller.text).join();
        if (enteredCode == currentVerificationCode) {
          showSuccessModal(context);
        } else {
          setState(() {
            _errorMessage = 'Invalid verification code. Please try again.';
          });
        }
      }

      void showSuccessModal(BuildContext context) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xFFFEF8C2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign Up Successful!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B440E),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your account has been created.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Color(0xFF0B440E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Welcome to the NutriCycle community!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Color(0xFF0B440E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login_screen');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B440E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      fixedSize: const Size(303, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFEF8C2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }

      @override
      void dispose() {
        for (var controller in _codeControllers) {
          controller.dispose();
        }
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
                          'Verification Code',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0B440E),
                          ),
                        ),
                        Text(
                          'Please enter the 6-digit verification code sent to ${widget.email}.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B440E),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Color(0xFF0B440E)),
                                  
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextField(
                                  
                                  controller: _codeControllers[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        if (_successMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _successMessage!,
                              style: TextStyle(color: Colors.green, fontSize: 14),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code? ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0B440E),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await checkConnectivity();
                                  final newCode = await generateVerificationCode();
                                  print('Sending code $newCode to ${widget.email}');
                                  await sendVerificationEmail(
                                    widget.email,
                                    newCode,
                                  );
                                  setState(() {
                                    currentVerificationCode = newCode;
                                    _errorMessage = null;
                                    _successMessage =
                                        'New code sent successfully! Check your email (including spam).';
                                    for (var controller in _codeControllers) {
                                      controller.clear();
                                    }
                                  });
                                } catch (e) {
                                  setState(() {
                                    _errorMessage =
                                        'Failed to resend code. Details: $e';
                                    _successMessage = null;
                                  });
                                  print('Resend error: $e');
                                }
                              },
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0B440E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _verifyCode,
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
                            'Verify',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFEF8C2),
                            ),
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

      Future<String> generateVerificationCode() async {
        var random = Random();
        int code = 100000 + random.nextInt(900000); // Generates 100000 to 999999
        String codeStr = code.toString();
        if (codeStr.length != 6) {
          print('Generated code length issue: $codeStr');
          return '000000'; // Fallback
        }
        return codeStr;
      }

      Future<void> sendVerificationEmail(String email, String code) async {
        const String apiKey =
            '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';
        final url = Uri.parse('https://api.brevo.com/v3/smtp/email');

        try {
          // Validate email format
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
              }, // Replace with verified email
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
    }