import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _activeTab = 0; // 0 for Animal Feed, 1 for Compost
  String _quantity = '12 KG';
  String _lastBatchDate = '2024-07-26';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('inventory')
          .doc(_activeTab == 0 ? 'animal_feed' : 'compost')
          .get();
      if (snapshot.exists) {
        setState(() {
          _quantity = snapshot.get('quantity') ?? '12 KG';
          _lastBatchDate = snapshot.get('lastBatchDate') ?? '2024-07-26';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Optionally show a snackbar or alert for the user
    }
  }

  void _switchTab(int index) {
    if (_activeTab != index) {
      setState(() {
        _activeTab = index;
      });
      _fetchData(); // Fetch new data when tab changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2), // Light yellow background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Inventory',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Color(0xFF1B5E20), // Dark green title
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60, // Matches the app bar height in the image
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure full width alignment
          children: [
            const SizedBox(height: 16), // Top padding to align with image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Even spacing with full width
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(0),
                    child: Text(
                      'Animal Feed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: _activeTab == 0 ? Color(0xFF1B5E20) : Color(0xFF4F7942),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(1),
                    child: Text(
                      'Compost',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        color: _activeTab == 1 ? Color(0xFF1B5E20) : Color(0xFF4F7942),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4), // Reduced height for tighter divider spacing
            const Divider(
              color: Color(0xFF1B5E20), // Dark green divider
              thickness: 2,
              height: 2,
            ),
            const SizedBox(height: 24), // Increased spacing to match card positioning
            _buildInfoCard(
              title: 'Quantity Produced',
              icon: Icons.line_weight, // Valid icon for weight
              value: _quantity,
              isCompleted: true,
            ),
            const SizedBox(height: 16), // Spacing between cards
            _buildInfoCard(
              title: 'Last Batch Date',
              icon: Icons.calendar_today,
              value: _lastBatchDate,
              isCompleted: true,
            ),
            const SizedBox(height: 32), // Larger bottom padding to center button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add completion logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20), // Dark green button
                  foregroundColor: const Color(0xFFFEF8C2), // Light yellow text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Matches rounded edges
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  minimumSize: const Size(320, 55), // Exact size from image
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String value,
    required bool isCompleted,
  }) {
    return Container(
      width: double.infinity, // Full width to match card design
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1B5E20),
                ),
              ),
              if (isCompleted)
                const Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1B5E20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1B5E20), size: 24),
              const SizedBox(width: 12), // Increased spacing for alignment
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}