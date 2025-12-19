import 'package:flutter/material.dart';
import 'dart:async';

typedef StatusUpdateCallback = void Function(String currentTask, String mode);

class ProcessingNavigationScreen extends StatefulWidget {
  final StatusUpdateCallback? onStatusUpdate;

  const ProcessingNavigationScreen({super.key, this.onStatusUpdate});

  @override
  State<ProcessingNavigationScreen> createState() => _ProcessingNavigationScreenState();
}

class _ProcessingNavigationScreenState extends State<ProcessingNavigationScreen> {
  bool isProcessing = false;
  bool isCompostMode = false;
  int currentIndex = 0;
  Timer? _timer;

  final String wifiName = 'NutriCycle-1';

  final List<StepData> guidelineSteps = [
    StepData('Step: 1', 'Power Check', 'Make sure that the machine is On', 'assets/step1.png', 'Proceed'),
    StepData('Step: 2', 'Pre-Manual Sorting', 'Remove non-biodegradable waste that may cause harm to the machine', 'assets/step2.png', 'Proceed'),
    StepData('Step: 3', 'Load Waste', 'Load Vegetable waste into the hopper of the machine', 'assets/step3.png', 'Proceed'),
    StepData('Step: 4', 'Secure Safety', 'Ensure all safety guards are properly secured', 'assets/step4.png', 'Start Process'),
  ];

  final List<ProcessingStepData> animalFeedSteps = [
    ProcessingStepData(
      title: 'Recognition',
      subtitle: 'Analyzing Waste...',
      description: 'The system identifies and assesses various types of green leafy vegetable waste.',
    ),
    ProcessingStepData(
      title: 'Sorting',
      subtitle: 'Determining waste pathway...',
      description: 'The system categorizes waste based on its type.',
    ),
    ProcessingStepData(
      title: 'Vermicasting',
      subtitle: 'Initiating vermicasting process...',
      description: 'The system processes the waste for composting.',
    ),
    ProcessingStepData(
      title: 'Completion',
      subtitle: 'Animal feed processing complete.',
      description: 'Animal feed processing is finished and ready for collection.',
    ),
  ];

  final List<ProcessingStepData> compostSteps = [
    ProcessingStepData(
      title: 'Recognition',
      subtitle: 'Analyzing Waste...',
      description: 'The system identifies and assesses various types of green leafy vegetable waste.',
    ),
    ProcessingStepData(
      title: 'Sorting',
      subtitle: 'Determining waste pathway...',
      description: 'The system categorizes waste based on its type.',
    ),
    ProcessingStepData(
      title: 'Vermicasting',
      subtitle: 'Initiating vermicasting process...',
      description: 'The system processes the waste for composting.',
    ),
    ProcessingStepData(
      title: 'Completion',
      subtitle: 'Compost processing complete.',
      description: 'Compost processing is finished and ready for collection.',
    ),
  ];

  late List<ProcessingStepData> currentProcessingSteps;

  @override
  void initState() {
    super.initState();
    currentProcessingSteps = animalFeedSteps;

    // FIXED: Delay initial status notification until after first frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyStatus();
    });
  }

  void _notifyStatus() {
    if (!mounted) return; // Safety check

    if (!isProcessing) {
      widget.onStatusUpdate?.call('Idle', 'None');
      return;
    }
    final currentStep = currentProcessingSteps[currentIndex];
    final mode = isCompostMode ? 'Compost Process' : 'Animal Feed Process';
    widget.onStatusUpdate?.call(currentStep.title, mode);
  }

  void nextStep() {
    if (!isProcessing && currentIndex == guidelineSteps.length - 1) {
      setState(() {
        isProcessing = true;
        isCompostMode = false;
        currentProcessingSteps = animalFeedSteps;
        currentIndex = 0;
      });
      _notifyStatus();
      startProcessingTimer();
    } else if (!isProcessing) {
      setState(() => currentIndex++);
      _notifyStatus(); // Optional: notify on guideline step change if needed
    }
  }

  void previousStep() {
    if (!isProcessing && currentIndex > 0) {
      setState(() => currentIndex--);
      _notifyStatus(); // Optional
    }
  }

  void startProcessingTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        if (currentIndex < currentProcessingSteps.length - 1) {
          currentIndex++;
          _notifyStatus();
        } else {
          timer.cancel();
          if (!isCompostMode) {
            setState(() {
              isCompostMode = true;
              currentProcessingSteps = compostSteps;
              currentIndex = 0;
            });
            _notifyStatus();
            startProcessingTimer();
          }
        }
      });
    });
  }

  void doneOrForceStop() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      isProcessing = false;
      isCompostMode = false;
      currentIndex = 0;
      currentProcessingSteps = animalFeedSteps;
    });
    _notifyStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getAppBarTitle() {
    if (!isProcessing) return 'Machine Guidelines';
    return isCompostMode ? 'Compost Process – $wifiName' : 'Animal Feed Process – $wifiName';
  }

  String getCurrentTaskLabel() {
    return isCompostMode ? 'Current Task: Compost Process' : 'Current Task: Animal Feed Process';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7D6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7D6),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          getAppBarTitle(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
        ),
      ),
      body: isProcessing ? _buildProcessingView() : _buildGuidelineView(),
    );
  }

  Widget _buildGuidelineView() {
    final step = guidelineSteps[currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(step.step, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFEF7D6))),
                      const SizedBox(height: 10),
                      Text(step.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFFEF7D6)), textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            step.image,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('Image not found', style: TextStyle(color: Colors.grey[600])),
                                    Text(step.image, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(step.description, style: const TextStyle(fontSize: 16, color: Color(0xFFFEF7D6), height: 1.5), textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEF7D6),
                          foregroundColor: const Color(0xFF1B5E20),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(step.buttonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                if (currentIndex > 0)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: previousStep,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFEF7D6), size: 28),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1B5E20), width: 2),
            ),
            child: RichText(
              textAlign: TextAlign.left,
              text: const TextSpan(
                style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF1B5E20)),
                children: [
                  TextSpan(text: 'Information:\n', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  TextSpan(text: 'These guidelines ensure safe and proper operation of the NutriCycle machine. Following these steps helps prevent damage, maintains consistent performance, and keeps users safe during the processing of waste.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    final step = currentProcessingSteps[currentIndex];
    final bool isLastStep = currentIndex == currentProcessingSteps.length - 1;
    final bool showDoneButton = isCompostMode && isLastStep;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(getCurrentTaskLabel(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20))),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: const Color(0xFF1B5E20), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text(step.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFFEF7D6)), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(step.subtitle, style: const TextStyle(fontSize: 20, color: Color(0xFFFEF7D6)), textAlign: TextAlign.center),
                      const SizedBox(height: 60),
                      Text(step.description, style: const TextStyle(fontSize: 17, color: Color(0xFFFEF7D6), height: 1.5), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text('Step ${currentIndex + 1} of ${currentProcessingSteps.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: doneOrForceStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showDoneButton ? const Color(0xFF1B5E20) : Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    showDoneButton ? 'Done' : 'Force Stop',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepData {
  final String step, title, description, image, buttonText;
  StepData(this.step, this.title, this.description, this.image, this.buttonText);
}

class ProcessingStepData {
  final String title, subtitle, description;
  ProcessingStepData({required this.title, required this.subtitle, required this.description});
}