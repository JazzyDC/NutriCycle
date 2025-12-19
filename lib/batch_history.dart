import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BatchHistoryScreen extends StatefulWidget {
  const BatchHistoryScreen({super.key});

  @override
  State<BatchHistoryScreen> createState() => _BatchHistoryScreenState();
}

class _BatchHistoryScreenState extends State<BatchHistoryScreen> {
  DateTime? _selectedDate;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1B5E20),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // Format date for grouping header: Today, Yesterday, or "12 Jan 2025"
  String _formatGroupDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final batchDate = DateTime(date.year, date.month, date.day);

    if (batchDate == today) return 'Today';
    if (batchDate == yesterday) return 'Yesterday';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            color: const Color(0xFFFEF8C2),
            child: const Center(
              child: Text(
                'Batch History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                  color: Color(0xFF0B440E),
                ),
              ),
            ),
          ),

          // Date Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? 'All Time'
                        : DateFormat('dd MMM yyyy').format(_selectedDate!),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B440E),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 22),
                    color: const Color(0xFF0B440E),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ),
          ),

          // StreamBuilder to listen to Firestore in real-time
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('batches') // Change to your collection name
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading history',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1B5E20),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        const Text(
                          'No batch history yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filter by selected date
                var filteredDocs = docs;
                if (_selectedDate != null) {
                  final selectedStart = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                  final selectedEnd = selectedStart.add(const Duration(days: 1));

                  filteredDocs = docs.where((doc) {
                    final timestamp = doc['createdAt'] as Timestamp?;
                    if (timestamp == null) return false;
                    final batchDate = timestamp.toDate();
                    return batchDate.isAfter(selectedStart) && batchDate.isBefore(selectedEnd);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final timestamp = data['createdAt'] as Timestamp?;
                    final batchDate = timestamp?.toDate();
                    final timeStr = batchDate != null ? DateFormat('HH:mm').format(batchDate) : '';
                    final dateGroup = timestamp != null ? _formatGroupDate(timestamp) : 'Unknown Date';

                    final previousDoc = index > 0 ? filteredDocs[index - 1] : null;
                    final previousTimestamp = previousDoc != null
                        ? (previousDoc['createdAt'] as Timestamp?)?.toDate()
                        : null;
                    final previousDateGroup = previousTimestamp != null
                        ? _formatGroupDate(previousDoc!['createdAt'])
                        : null;

                    final showDateHeader = index == 0 || dateGroup != previousDateGroup;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              dateGroup,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B440E),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data['batchId']?.toString() ?? 'BCH-Unknown',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B440E),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0B440E),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Formulation: ${data['formulation'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  batchDate != null
                                      ? DateFormat('dd MMM yyyy').format(batchDate)
                                      : 'Unknown Date',
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• ${data['status'] ?? 'Unknown'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: (data['status']?.toString().contains('Stopped') ?? false) ||
                                            (data['status']?.toString().contains('Failed') ?? false)
                                        ? Colors.orange[800]
                                        : Colors.green[800],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}