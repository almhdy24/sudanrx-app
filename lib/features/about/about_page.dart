import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // HEADER (BETA)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.biotech,
                      color: Colors.white,
                      size: 34,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'SudanRx',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Beta Version • Clinical Guidelines Platform',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Evidence-based medical guidance built for Sudanese healthcare professionals.',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _card(
            icon: Icons.health_and_safety,
            title: 'Clinical Mission',
            content:
                'SudanRx provides free, community-driven clinical guidelines tailored for healthcare practice in Sudan. '
                'The platform supports decision-making using evidence-based and locally relevant medical protocols.',
          ),

          _card(
            icon: Icons.warning_amber,
            title: 'Medical Disclaimer',
            content:
                'This platform is for educational and clinical reference only. '
                'It does not replace professional medical judgment, diagnosis, or treatment decisions.',
          ),

          _card(
            icon: Icons.cloud_off,
            title: 'Offline First System',
            content:
                'SudanRx is designed to work in low-connectivity environments. '
                'All guidelines can be accessed offline after initial sync.',
          ),

          _card(
            icon: Icons.groups,
            title: 'Community Driven',
            content:
                'Content is contributed and reviewed by doctors, pharmacists, students, and healthcare professionals across Sudan.',
          ),

          _card(
            icon: Icons.code,
            title: 'Open Source Project',
            content:
                'SudanRx is an open-source initiative encouraging developers and medical professionals to collaborate in building healthcare tools.',
          ),

          _card(
            icon: Icons.update,
            title: 'Beta Release Info',
            content:
                'Version: 0.1.0 (Beta)\nBuild: Community Preview\nStatus: Active Development',
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact & Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text('Email: contact@sudanrx.org'),
                Text('Telegram: @sudanrx'),
                Text('GitHub: github.com/sudanrx/sudanrx'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Built for Sudanese healthcare professionals. Designed for real clinical environments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}