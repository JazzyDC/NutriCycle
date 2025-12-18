import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _expandedBin = -1; // -1 = none expanded

  void _toggleExpand(int index) {
    setState(() {
      _expandedBin = _expandedBin == index ? -1 : index;
    });
  }

  // Safely get document by ID
  DocumentSnapshot? _docById(List<QueryDocumentSnapshot> docs, String id) {
    try {
      return docs.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      appBar: AppBar(
        title: const Text('Inventory',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontFamily: 'Poppins')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          }

          final docs = snapshot.data!.docs;
          final animalFeedDoc = _docById(docs, 'animal_feed');
          final compostDoc = _docById(docs, 'compost');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBinCard(
                  doc: animalFeedDoc,
                  title: "Animal Feed Bin",
                  icon: 'assets/iconchicken.png',
                  isExpanded: _expandedBin == 0,
                  onTap: () => _toggleExpand(0),
                ),
                const SizedBox(height: 16),
                _buildBinCard(
                  doc: compostDoc,
                  title: "Vegetable Compost Bin",
                  icon: 'assets/composticon.png',
                  isExpanded: _expandedBin == 1,
                  onTap: () => _toggleExpand(1),
                  showCollectionTime: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBinCard({
    required DocumentSnapshot? doc,
    required String title,
    required String icon,
    required bool isExpanded,
    required VoidCallback onTap,
    bool showCollectionTime = false,
  }) {
    // No data yet → clean "waiting" card (exactly like your old design)
    if (doc == null || !doc.exists) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset(icon, width: 50, height: 50, color: Colors.grey[400]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20))),
                        const SizedBox(height: 8),
                        Text("Waiting for data...", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1B5E20)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Data exists → real values from Firebase
    final data = doc.data() as Map<String, dynamic>;
    final double used = (data['storageUsed'] as num?)?.toDouble() ?? 0.0;
    final double total = (data['storageTotal'] as num?)?.toDouble() ?? 3.0;
    final double progress = total > 0 ? used / total : 0.0;

    // EXPANDED CARD (Dark Green)
    if (isExpanded) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D5016),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              InkWell(
                onTap: onTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFFEF8C2), fontFamily: 'Poppins')),
                    const SizedBox(width: 10),
                    const Icon(Icons.keyboard_arrow_up, color: Color(0xFFFEF8C2), size: 30),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Status: ${data['status'] ?? 'Loading...'}', style: const TextStyle(fontSize: 16, color: Color(0xFFFEF8C2))),
              const SizedBox(height: 20),

              // Circular Progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140, height: 140,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation(progress < 0.8 ? const Color(0xFFFEF8C2) : Colors.red),
                    ),
                  ),
                  Image.asset(icon, width: 70, height: 70, color: const Color(0xFFFEF8C2)),
                ],
              ),

              const SizedBox(height: 30),
              _row('Capacity:', '${total.toStringAsFixed(1)} kg'),
              _row('Current Load:', '${used.toStringAsFixed(1)} kg'),
              _row('Remaining:', '${(total - used).toStringAsFixed(1)} kg'),
              _row('Optimal Temp:', data['optimalTemp'] ?? '28-32°C'),
              if (showCollectionTime && data['estimatedCollection'] != null)
                _row('Collection In:', data['estimatedCollection']),
              _row('Last Cleaned:', data['lastCleaned'] ?? 'Never'),
            ],
          ),
        ),
      );
    }

    // COLLAPSED CARD (White with progress bar — your original look)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF1B5E20)),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1B5E20), size: 28),
                  ],
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20), fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Text('${used.toStringAsFixed(1)} kg out of ${total.toStringAsFixed(1)} kg',
                    style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFEF8C2), fontSize: 15)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(color: Color(0xFFFEF8C2), fontSize: 15)),
        ],
      ),
    );
  }
}