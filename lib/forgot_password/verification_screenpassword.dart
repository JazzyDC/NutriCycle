import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'forgot_password_screen.dart';

class VerificationSScreen extends StatefulWidget {
  const VerificationSScreen({super.key});

  @override
  State<VerificationSScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationSScreen> {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isResendEnabled = false;
  bool _hasExpired = false;
  String? _expectedCode;
  String? _email;
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      _email = arguments?['email'];
      _expectedCode = arguments?['verificationCode'];
      if (_expectedCode == null || _email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid verification data.')),
        );
      }
      _startTimer();
    });
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _isResendEnabled = false;
      _hasExpired = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _hasExpired = true;
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final code = _codeControllers.map((controller) => controller.text).join();

    if (_hasExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code has expired. Please resend.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (code == _expectedCode && mounted && _email != null) {
      try {
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email format.')),
          );
          setState(() => _isLoading = false);
          return;
        }

        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
        _timer?.cancel();
        _showResetModal(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset email: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid verification code.')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _resendCode() async {
    if (_email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email provided to resend code.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ForgotPasswordScreen.checkConnectivity();
      final newCode = await ForgotPasswordScreen.generateVerificationCode();
      await ForgotPasswordScreen.sendVerificationEmail(_email!, newCode);
      setState(() {
        _expectedCode = newCode;
      });
      _startTimer(); // Reset the timer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend code: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResetModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent background clicks
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEF8C2),
        title: const Text(
          'Success!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0B440E),
          ),
        ),
        content: const Text(
          'Please check your email inbox or spam folder for the message.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0B440E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the modal
              Navigator.pop(context); // Back to ForgotPasswordScreen
              Navigator.pop(context); // Back to previous screen (e.g., login)
            },
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B440E),
              ),
            ),
          ),
        ],
      ),
    );
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
                  'Verification Code',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B440E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter the 6-digit verification code sent to your email address.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0B440E),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: _codeControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF0B440E), width: 0.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        if (!RegExp(r'^\d$').hasMatch(value)) {
                          return '';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  )),
                ),
                const SizedBox(height: 16),
                Text(
                  'Time remaining: ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0B440E),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isResendEnabled && !_isLoading ? _resendCode : null,
                  child: Text(
                    'Didn\'t receive the code? Resend',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: _isResendEnabled ? const Color(0xFF0B440E) : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
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
                            'Verify',
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
    _timer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}