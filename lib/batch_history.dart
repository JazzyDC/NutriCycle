import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class BatchHistoryScreen extends StatefulWidget {
  @override
  _BatchHistoryScreenState createState() => _BatchHistoryScreenState();
}

class _BatchHistoryScreenState extends State<BatchHistoryScreen> {
  DateTime? _selectedDate;
  final List<Map<String, String>> batchHistory = [
    {
      'date': 'Today',
      'id': 'BCH-3A4FDE',
      'formulation': 'High-Protein Feed',
      'status': 'Completed - Animal Feed',
      'time': '14:30',
      'dateFull': '15 Jan 2024',
    },
    {
      'date': 'Yesterday',
      'id': 'BCH-0B1C7A',
      'formulation': 'Standard Compost',
      'status': 'Completed - Compost',
      'time': '09:15',
      'dateFull': '14 Jan 2024',
    },
    {
      'date': '13 Jan 2024',
      'id': 'BCH-2D8E5F',
      'formulation': 'High-Protein Feed',
      'status': 'Stopped - Power Outage',
      'time': '16:45',
      'dateFull': '13 Jan 2024',
    },
    {
      'date': '12 Jan 2024',
      'id': 'BCH-5G2H9I',
      'formulation': 'High-Protein Feed',
      'status': 'Completed - Animal Feed',
      'time': '11:00',
      'dateFull': '12 Jan 2024',
    },
    {
      'date': '11 Jan 2024',
      'id': 'BCH-7J3KIL',
      'formulation': 'Standard Compost',
      'status': 'Completed - Compost',
      'time': '18:20',
      'dateFull': '11 Jan 2024',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2025, 9, 30); // Default to 15 Jan 2024 to match data
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF1B5E20),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0B440E),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<Map<String, String>> getFilteredBatches() {
    if (_selectedDate == null) {
      // Default to all data if no date selected
      return batchHistory;
    }
    // When a date is selected, show all data (remove 7-day filter)
    return batchHistory;
  }

  @override
  Widget build(BuildContext context) {
    final filteredBatches = getFilteredBatches();
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2), // Background color for the entire screen
      body: Column(
        children: [
          // Custom header with back button, title, and date/time
          Container(
            padding: const EdgeInsets.all(10.0),
            color: const Color(0xFFFEF8C2), // Matches the scaffold background
            child: Column(
              children: [
                Row(
                  children: [
                  
                    const Expanded(
                      child: Text(
                        'Batch History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Poppins',
                            color: Color(0xFF0B440E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white, // Background color for the container
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
                boxShadow: [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Last 7 Days'
                        : DateFormat('dd MMM yyyy').format(_selectedDate!),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B440E),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 20),
                    onPressed: () => _selectDate(context),
                     color: const Color(0xFF0B440E),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBatches.length,
              itemBuilder: (context, index) {
                final batch = filteredBatches[index];
                final isNewDate = index == 0 ||
                    batch['date'] != filteredBatches[index - 1]['date'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNewDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          batch['date']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B440E),
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: Colors.white, // White background for all cards
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              batch['id']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                 color: Color(0xFF0B440E),
                              ),
                            ),
                            Text(
                              batch['time']!,
                              style: const TextStyle(
                                fontSize: 16,
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
                              'Formulation: ${batch['formulation']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              batch['dateFull']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• ${batch['status']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: batch['status']!.contains('Stopped')
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
            ),
          ),
        ],
      ),
    );
  }
}