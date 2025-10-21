import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'support_and_information/about_nutricycle_screen.dart';
import 'support_and_information/contact_us_screen.dart';
import 'support_and_information/terms_and_conditions_screen.dart';
import 'support_and_information/privacy_notice_screen.dart';
import 'account_settings/notifications_settings_screen.dart';
import 'forgot_password/change_password.dart'; // Import the new file

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      print('Logout successful');
      // Wait briefly for auth state to propagate
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        // Navigate directly to LoginScreen
        Navigator.pushReplacementNamed(context, '/login_screen');
      }
    } catch (e) {
      print('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout error: $e')),
        );
      }
    }
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  ChangePasswordScreen(),
      ),
    );
  }

  void _showLogOutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 311,
          height: 196,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF8C2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFF0B440E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  color: Color(0xFF0B440E),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 140,
                    height: 43,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF0B440E),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: const Color(0xFFFEF8C2),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF0B440E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 133,
                    height: 43,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B440E),
                        foregroundColor: const Color(0xFFFEF8C2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF8C2),
        elevation: 0,
        
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF0B440E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Account Settings'),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildSettingsItem(
                'Change Password',
                onTap: _navigateToChangePassword, // Updated to navigate
              ),
              _buildDivider(),
              _buildSettingsItem(
                'Notifications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsSettingsScreen(),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionTitle('Support & Information'),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildSettingsItem(
                'Contact Us',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                ),
              ),
              _buildDivider(),
              _buildSettingsItem(
                'About NutriCycle',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutNutriCycleScreen(),
                  ),
                ),
              ),
              _buildDivider(),
              _buildSettingsItem(
                'Terms & Conditions',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsAndConditionsScreen(),
                  ),
                ),
              ),
              _buildDivider(),
              _buildSettingsItem(
                'Privacy Notice',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyNoticeScreen(),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _showLogOutDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B440E),
                  foregroundColor: const Color(0xFFFEF8C2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'LOG OUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0B440E),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xCCFFF9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0B440E),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0B440E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF0B440E),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0x660B440E),
      ),
    );
  }
}