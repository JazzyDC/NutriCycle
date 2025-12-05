

import 'package:flutter/material.dart';

class ProcessingNavigationScreen extends StatefulWidget {
  const ProcessingNavigationScreen({super.key});

  @override
  State<ProcessingNavigationScreen> createState() =>
      _ProcessingNavigationScreenState();
}

class _ProcessingNavigationScreenState
    extends State<ProcessingNavigationScreen> with TickerProviderStateMixin {
  int currentIndex = 0;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<StepData> steps = [
    StepData(
      'Step:1',
      'Power Check',
      'Make sure that the machine is On',
      'assets/step1.png',
      'Proceed',
    ),
    StepData(
      'Step:2',
      'Pre-Manual Sorting',
      'Remove non-biodegradable waste that may cause harm to the machine',
      'assets/step2.png',
      'Proceed',
    ),
    StepData(
      'Step:3',
      'Load Waste',
      'Load Vegetable waste into the hopper of the machine',
      'assets/step3.png',
      'Proceed',
    ),
    StepData(
      'Step:4',
      'Secure Safety',
      'Ensure all safety guards are properly secured',
      'assets/step4.png',
      'Start Process',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOutCubic),
            ))
        .toList();
  }

  void nextStep() {
    if (currentIndex >= steps.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Starting Process...')),
      );
      return;
    }

    _controllers[currentIndex].forward().then((_) {
      setState(() => currentIndex++);
      if (currentIndex < _controllers.length) {
        _controllers[currentIndex].value = 0;
      }
    });
  }

  void previousStep() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _controllers[currentIndex].value = 0;
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8C2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF8C2),
        elevation: 0,
        centerTitle: true,
        leading: currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0B440E)),
                onPressed: previousStep,
              )
            : null,
        title: const Text(
          'Machine Guidelines',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B440E),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // Card Stack
          Expanded(
            child: Center(
              child: SizedBox(
                width: 380,
                height: 580,
                child: Stack(
                  alignment: Alignment.center,
                  children: List.generate(4, (i) {
                    if (i < currentIndex) return const SizedBox();

                    final isTop = i == currentIndex;
                    final anim = _animations[i];
                    final step = steps[i];
                    final depth = 3 - i;

                    return AnimatedBuilder(
                      animation: anim,
                      builder: (context, child) {
                        final offset = isTop
                            ? Offset(anim.value * 2.5, anim.value * -1.5)
                            : Offset.zero;
                        final scale = isTop
                            ? (1 - anim.value * 0.1)
                            : (0.94 + (i * 0.02));
                        final opacity = isTop ? (1 - anim.value) : 1.0;

                        return Transform.translate(
                          offset: offset,
                          child: Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: depth * 8.0,
                                  left: depth * 6.0,
                                ),
                                child: ClipPath(
                                  clipper: CardWithNotchClipper(),
                                  child: Container(
                                    width: 340,
                                    height: 510,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 32,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0B440E),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          step.step,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          step.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 30),
                                        Container(
                                          padding: const EdgeInsets.all(30),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Image.asset(
                                            step.image,
                                            height: 180,
                                            width: 180,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 180,
                                                width: 180,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 80,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        Text(
                                          step.description,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const Spacer(),
                                        if (isTop)
                                          ElevatedButton(
                                            onPressed: nextStep,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFFEF8C2),
                                              foregroundColor:
                                                  const Color(0xFF0B440E),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 60,
                                                vertical: 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              step.buttonText,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).reversed.toList(),
                ),
              ),
            ),
          ),

          // Information Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 140,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0B440E),
                  width: 2,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Information:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0B440E),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'These guidelines ensure safe and proper operation of the NutriCycle machine. Following these steps helps prevent damage, maintains consistent performance, and keeps users safe during the processing of waste.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF0B440E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardWithNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 25.0;
    const notchW = 80.0;
    const notchH = 30.0;
    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height - notchH - radius)
      ..quadraticBezierTo(size.width, size.height - notchH,
          size.width - radius, size.height - notchH)
      ..lineTo(size.width / 2 + notchW / 2, size.height - notchH)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 - notchW / 2, size.height - notchH)
      ..lineTo(radius, size.height - notchH)
      ..quadraticBezierTo(
          0, size.height - notchH, 0, size.height - notchH - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

class StepData {
  final String step, title, description, image, buttonText;
  StepData(this.step, this.title, this.description, this.image, this.buttonText);
}