import 'package:flutter/material.dart';

class ContributePage extends StatelessWidget {
  const ContributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            title: 'Join the Community',
            icon: Icons.people,
            content: 'SudanRx is built by Sudanese doctors, pharmacists, and students. '
                'Your expertise can help improve healthcare across Sudan.',
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Ways to Contribute',
            icon: Icons.handshake,
            content: '• Submit or review guidelines\n'
                '• Report errors or suggest improvements\n'
                '• Help with translations (Arabic/English)\n'
                '• Develop the open-source app',
          ),
          const SizedBox(height: 12),
          _card(
            title: 'Contact & Updates',
            icon: Icons.email,
            content: 'For contributions or inquiries, please reach out:\n'
                'Email: contact@sudanrx.org\n'
                'Telegram: @sudanrx\n'
                'GitHub: github.com/sudanrx/sudanrx',
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required String content,
  }) {
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
