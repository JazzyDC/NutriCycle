import 'package:flutter/material.dart';

class AboutNutriCycleScreen extends StatelessWidget {
  const AboutNutriCycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color( 0xFFFEF8C2),
      appBar: AppBar(
        backgroundColor: Color( 0xFFFEF8C2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1B5E20),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About NutriCycle',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NutriCycle',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NutriCycle is an IoT- and AI-powered solution designed to transform vegetable waste into poultry feed meal and organic compost. Built with sustainability and agriculture in mind, NutriCycle provides an automated way of identifying, sorting, and processing vegetable by-products from wet markets such as cabbage leaves, sweet potato tops, moringa (malunggay), malunggay, papaya and root peels, and carrot trimmings.',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'What we do',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    'Reduce Feed Waste',
                    'Use AI and IoT sensors to identify vegetable type, measure weight, and classify freshness. Fresh, usable waste goes to feed production, while spoiled ones are converted into compost.',
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureItem(
                    'Support Farmers',
                    'Produce cost-effective poultry feed and compost for backyard and smallholder farmers.',
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureItem(
                    'Smart Processing',
                    'Helps reduce greenhouse gas emissions from rotting vegetable waste.',
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Why NutriCycle?',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '• Provides affordable feed alternatives for local poultry farmers\n\n'
                    '• Helps reduce greenhouse gas emissions from rotting vegetable waste\n\n'
                    '• Contributes to the circular economy by turning waste into value-added agricultural resources\n\n'
                    '• Ensures real-time monitoring with quality control, alerts, and data tracking',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(color: Color(0xFF1B5E20), fontSize: 14, height: 1.6, fontWeight: FontWeight.w500,),
        ),
      ],
    );
  }
}
