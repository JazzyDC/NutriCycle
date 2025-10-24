import 'package:flutter/material.dart';

class ProcessingStatusScreen extends StatefulWidget {
  const ProcessingStatusScreen({super.key});

  @override
  _ProcessingStatusScreenState createState() => _ProcessingStatusScreenState();
}

class _ProcessingStatusScreenState extends State<ProcessingStatusScreen> {
  final List<Map<String, dynamic>> preparationChecklist = [
    {'text': 'Ensure machine is powered off', 'completed': false},
    {'text': 'Load vegetable waste into hopper', 'completed': false},
    {'text': 'Check water supply levels', 'completed': false},
    {'text': 'Secure all safety guards', 'completed': false},
  ];
  bool isPreparationComplete = false;

  void toggleChecklistItem(int index) {
    setState(() {
      preparationChecklist[index]['completed'] = !preparationChecklist[index]['completed'];
      isPreparationComplete = preparationChecklist.every((item) => item['completed']);
    });
  }

  void proceedToNextStage() {
    if (isPreparationComplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NextStageScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the title
              children: [
                const Text(
                  'Processing Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B440E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0B440E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Status: Preparation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B440E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(preparationChecklist.length, (index) {
                    final item = preparationChecklist[index];
                    return CheckboxListTile(
                      title: Text(item['text']),
                      value: item['completed'],
                      onChanged: (_) => toggleChecklistItem(index),
                      activeColor: const Color(0xFF0B440E),
                      checkColor: Colors.white,
                    );
                  }),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isPreparationComplete ? proceedToNextStage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B440E),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: const Color(0xFF0B440E).withOpacity(0.6),
                    ),
                    child: const Text(
                      'Proceed to Next Stage',
                      style: TextStyle(
                        color: Color(0xFFFEF8C2),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for starting the process
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B440E),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    color: Color(0xFFFEF8C2),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class NextStageScreen extends StatelessWidget {
  const NextStageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Next Stage')),
      body: const Center(child: Text('Recognition Stage')),
    );
  }
}