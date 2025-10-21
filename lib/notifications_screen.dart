import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF8C2),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1B5E20),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            icon: Icons.info_outline,
            title: 'System Update',
            message: 'New system update available',
            time: '2 hours ago',
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            icon: Icons.warning_amber_rounded,
            title: 'Machine Status',
            message: 'Processing completed successfully',
            time: '5 hours ago',
            iconColor: const Color(0xFF1B5E20),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    Color iconColor = const Color(0xFF1B5E20),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Color(0xFF1B5E20),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Color(0xFF1B5E20), fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}