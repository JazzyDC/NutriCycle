import 'package:flutter/material.dart';

class PrivacyNoticeScreen extends StatelessWidget {
  const PrivacyNoticeScreen({super.key});

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
          'Privacy Notice',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 18,
            fontWeight: FontWeight.w900,
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
              '1. Information We Collect',
              'We may collect the following information:\n\n'
                  '• Account Information – email, password used to log in\n\n'
                  '• System Data – machine logs, compost/feed production records, and sensor readings\n\n'
                  '• Device Information – technical details such as device type, operating system, and connection logs',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use collected information to:\n\n'
                  '• Operate and improve the NutriCycle system\n\n'
                  '• Provide real-time monitoring, alerts, and reports\n\n'
                  '• Support research, testing, and system development\n\n'
                  '• Ensure system security and prevent misuse',
            ),
            _buildSection(
              '3. Sharing of Information',
              'We do not sell or rent your personal information.\nData may only be shared:\n\n'
                  '• With authorized developers and advisers for maintenance and research\n\n'
                  '• In anonymized form for reports, publications, or academic presentations',
            ),
            _buildSection(
              '4. Data Retention and Security',
              '• We retain system and usage data only as long as necessary for monitoring and research\n\n'
                  '• All data is stored securely with encryption and access controls\n\n'
                  '• While we take reasonable steps to protect your data, no system is completely secure',
            ),
            _buildSection(
              '5. Your Rights',
              'You may:\n\n'
                  '• Request access to your information\n\n'
                  '• Ask for corrections or deletion of your data\n\n'
                  '• Stop using the app at any time',
            ),
            _buildSection(
              '6. Updates to This Notice',
              'We may update this Privacy Notice from time to time.\nChanges will be posted within the app and will take effect immediately upon posting',
            ),
            _buildSection(
              '7. Contact Us',
              'If you have questions or concerns about this Privacy Notice, please contact us at:\n\n'
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
