import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF8C2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1B5E20),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using the NutriCycle Mobile App, you agree to comply with and be bound by these Terms & Conditions. If you do not agree, please do not use the app.',
            ),
            _buildSection(
              '2. Purpose of the App',
              'NutriCycle is developed as an IoT- and AI-powered prototype designed to convert vegetable waste into poultry feed and compost. The app allows operators to:\n\n'
                  '• Monitor machine activity in real-time\n\n'
                  '• Track feed and compost production\n\n'
                  '• Receive system alerts and notifications',
            ),
            _buildSection(
              '3. User Responsibilities',
              '• Users must provide accurate login details (e.g., email, password)\n\n'
                  '• The system should only be operated by trained personnel\n\n'
                  '• Users must not misuse the app or attempt unauthorized access\n\n'
                  '• Users are responsible for ensuring proper waste input (vegetable waste only)',
            ),
            _buildSection(
              '4. Data Collection & Privacy',
              '• The app may collect machine logs, processing data, and usage history\n\n'
                  '• No personal financial or sensitive personal data is collected\n\n'
                  '• All collected data is used solely for monitoring, development, and research',
            ),
            _buildSection(
              '5. Limitations of Liability',
              '• NutriCycle is a prototype system and may not guarantee 100% accuracy or continuous availability\n\n'
                  '• The developers are not liable for any misuse, equipment damage, or unintended consequences resulting from system use\n\n'
                  '• Users acknowledge that the machine is not designed for unsupervised or large-scale operations',
            ),
            _buildSection(
              '6. Intellectual Property',
              '• All designs, concepts, and content of NutriCycle remain the property of the project developers\n\n'
                  '• Users may not copy, redistribute, or commercially use the system without permission',
            ),
            _buildSection(
              '7. Amendments',
              'These Terms & Conditions may be updated as the system evolves. Users will be notified of significant changes within the app.',
            ),
            _buildSection(
              '8. Contact Information',
              'For inquiries, support, or feedback regarding NutriCycle, please contact us:\n\n'
                  'Email: nutricycle.project@gmail.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
