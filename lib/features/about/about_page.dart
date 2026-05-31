import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE0E0E0), // Match app background
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            title: 'Our Mission',
            icon: Icons.health_and_safety,
            content: 'SudanRx is a community-driven platform providing free, '
                'accessible medical guidelines for healthcare professionals in Sudan. '
                'We aim to support clinical decisions with locally relevant, '
                'evidence-based information.',
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Educational Purpose',
            icon: Icons.school,
            content: 'All guidelines are for educational and clinical support. '
                'Always use professional judgment in practice.',
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Offline First',
            icon: Icons.cloud_off,
            content: 'SudanRx works offline. Guidelines are cached locally after '
                'your first network sync, keeping crucial data available anywhere.',
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Version',
            icon: Icons.info,
            content: '1.0.0',
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required String content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1976D2), size: 24),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
