// lib/screens/sorting_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SortingScreen extends StatefulWidget {
  final String batchId;
  const SortingScreen({super.key, required this.batchId});

  @override
  State<SortingScreen> createState() => _SortingScreenState();
}

class _SortingScreenState extends State<SortingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Map<String, dynamic>? _batchData;
  bool _isLoading = true;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _fetchBatchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchBatchData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('machines')
          .doc('mach-01')
          .collection('batches')
          .doc(widget.batchId)
          .get();

      if (doc.exists) {
        setState(() {
          _batchData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF8C2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0B440E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sorting Batch',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B440E),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showDetails ? Icons.info : Icons.info_outline,
              color: const Color(0xFF0B440E),
              size: 28,
            ),
            onPressed: () {
              setState(() => _showDetails = !_showDetails);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ---------- Main loading UI ----------
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotationTransition(
                  turns: _controller,
                  child: Image.asset('assets/Logo.png', width: 120, height: 120),
                ),
                const SizedBox(height: 32),
                Text(
                  'Batch ID: ${widget.batchId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B440E),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sorting in progress...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                // LinearProgressIndicator removed
              ],
            ),
          ),

          // ---------- Expandable Details Panel ----------
          if (_showDetails && _batchData != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _showDetails ? 0 : -400,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Batch Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B440E),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF0B440E)),
                          onPressed: () => setState(() => _showDetails = false),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 8),
                    
                    _buildDetailRow('Type', _batchData!['type'] ?? 'N/A'),
                    
                    _buildDetailRow(
                        'Grams', '${_batchData!['grams']?.toStringAsFixed(1) ?? '0.0'} g'),
                    
                    
                    _buildDetailRow(
                      'Saved At',
                      _batchData!['savedAt'] != null
                          ? (_batchData!['savedAt'] as Timestamp)
                              .toDate()
                              .toString()
                              .split('.')
                              .first
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B440E),
            ),
          ),
        ],
      ),
    );
  }
}