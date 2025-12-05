import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sorting_screen.dart';

class BatchRecord {
  final String machineId;
  final double grams;
  final double kg;
  final String type;
  final String date;
  final String time; // Still kept for Firestore (optional)
  final DateTime timestamp;
  final bool isSaved;
  final String? firestoreId;

  BatchRecord({
    required this.machineId,
    required this.grams,
    required this.kg,
    required this.type,
    required this.date,
    required this.time,
    required this.timestamp,
    this.isSaved = false,
    this.firestoreId,
  });

  BatchRecord copyWith({bool? isSaved, String? firestoreId}) {
    return BatchRecord(
      machineId: machineId,
      grams: grams,
      kg: kg,
      type: type,
      date: date,
      time: time,
      timestamp: timestamp,
      isSaved: isSaved ?? this.isSaved,
      firestoreId: firestoreId ?? this.firestoreId,
    );
  }
}

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});
  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen>
    with SingleTickerProviderStateMixin {
  bool isScanning = false;
  String statusMessage = 'Starting...';
  late AnimationController _spin;
  final List<BatchRecord> _batchList = [];
  bool _isSaving = false;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _startAutoRecognition();
    _listenToMachineData();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _startAutoRecognition() {
    setState(() {
      isScanning = true;
      statusMessage = 'Connecting to machine...';
    });
    _spin.repeat();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _spin.stop();
      setState(() {
        isScanning = false;
        statusMessage = 'Live from mach-01';
      });
    });
  }

  void _listenToMachineData() {
    _db.child('mach-01').onValue.listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        setState(() => statusMessage = 'No data');
        return;
      }

      final record = BatchRecord(
        machineId: 'mach-01',
        grams: double.tryParse(data['grams'].toString()) ?? 0.0,
        kg: double.tryParse(data['kg'].toString()) ?? 0.0,
        type: data['type']?.toString() ?? 'unknown',
        date: data['date']?.toString() ?? '',
        time: data['time']?.toString() ?? '', // Still read but not used in UI
        timestamp: DateTime.now(),
      );

      setState(() {
        if (_batchList.isEmpty || _batchList.first.grams != record.grams) {
          _batchList.insert(0, record);
        }
        statusMessage = 'Updated: ${record.grams.toStringAsFixed(1)} g';
      });
    });
  }

  Future<void> _saveAndSort(BatchRecord batch) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final timestampId = batch.timestamp.millisecondsSinceEpoch.toString();
      final docRef = _firestore
          .collection('machines')
          .doc(batch.machineId)
          .collection('batches')
          .doc(timestampId);

      await docRef.set({
        'machineId': batch.machineId,
        'grams': batch.grams,
        'kg': batch.kg,
        'type': batch.type,
        'date': batch.date,
        'time': batch.time, // Still saved to Firestore
        'timestamp': batch.timestamp,
        'savedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        final idx = _batchList.indexOf(batch);
        if (idx != -1) {
          _batchList[idx] = batch.copyWith(isSaved: true, firestoreId: timestampId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved! Starting sorting...'), backgroundColor: Colors.green),
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SortingScreen(batchId: timestampId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _fmt(double grams) => '${grams.toStringAsFixed(1)} g';

  static const _label = TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500);
  static const _value = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0B440E));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF8C2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0B440E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('mach-01 Live',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B440E))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              _batchList.isNotEmpty ? Icons.cloud_done : Icons.cloud_off,
              color: _batchList.isNotEmpty ? Colors.green : Colors.red,
              size: 28,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            RotationTransition(
              turns: _spin,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(child: Image.asset('assets/Logo.png', fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 14,
                color: _batchList.isNotEmpty ? Colors.green.shade700 : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            // Latest Batch
            if (_batchList.isNotEmpty) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Latest Batch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B440E))),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Type', style: _label),
                      Text(_batchList.first.type, style: _value),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Weight', style: _label),
                      Text(_fmt(_batchList.first.grams), style: _value),
                    ]),
                    // Time row REMOVED
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 40, color: Color(0xFF0B440E)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : () => _saveAndSort(_batchList.first),
                            icon: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.sort, size: 18),
                            label: Text(_isSaving ? 'Saving...' : 'Collect & Sort'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B440E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(children: [
                  Icon(Icons.hourglass_empty, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Waiting for mach-01 data...', style: TextStyle(color: Colors.grey[600])),
                ]),
              ),
            ],

            const SizedBox(height: 30),

            // Batch History
            Text('Batch History (${_batchList.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTableHeader(),
            const SizedBox(height: 8),

            ..._batchList.take(10).map((batch) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _buildHistoryRow(
                    type: batch.type,
                    grams: _fmt(batch.grams),
                    isLatest: batch == _batchList.first,
                  ),
                )),

            if (_batchList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No batches yet', style: TextStyle(color: Colors.grey)),
              ),

            const SizedBox(height: 30),
            const Text('Live from Firebase • mach-01',
                style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Updated header: Only Type and Weight
  Widget _buildTableHeader() => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF0B440E).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: const Row(children: [
          Expanded(flex: 2, child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Weight', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        ]),
      );

  // Updated row: Only Type and Weight (grams)
  Widget _buildHistoryRow({
    required String type,
    required String grams,
    bool isLatest = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isLatest ? const Color(0xFFFEF8C2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              type,
              style: TextStyle(color: type == 'compost' ? Colors.brown : Colors.green[700]),
            ),
          ),
          Expanded(
            child: Text(
              grams,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}