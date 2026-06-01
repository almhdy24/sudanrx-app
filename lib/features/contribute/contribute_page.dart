import 'package:flutter/material.dart';

class ContributePage extends StatelessWidget {
  const ContributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Hero Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 16),
                Text(
                  'Build SudanRx Together',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'A community-driven platform for Sudanese clinical guidelines, protocols, and medical knowledge.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _sectionCard(
            icon: Icons.groups,
            title: 'Who Can Contribute?',
            content:
                'Doctors, Pharmacists, Medical Students, Nurses, Researchers, Public Health Professionals, Translators, Designers, and Software Developers.',
          ),

          _sectionCard(
            icon: Icons.fact_check,
            title: 'How You Can Help',
            content:
                '• Submit local clinical guidelines\n'
                '• Review and validate medical content\n'
                '• Report errors and outdated recommendations\n'
                '• Translate content between Arabic and English\n'
                '• Improve the open-source application\n'
                '• Help maintain community resources',
          ),

          _sectionCard(
            icon: Icons.verified,
            title: 'Our Mission',
            content:
                'To provide free, accessible, evidence-based clinical guidance tailored for healthcare professionals in Sudan.',
          ),

          _sectionCard(
            icon: Icons.code,
            title: 'Open Source Project',
            content:
                'SudanRx welcomes developers, designers, and contributors who want to help build sustainable healthcare tools for Sudan.',
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: const [
                Text(
                  'Get Involved',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16),

                ListTile(
                  leading: Icon(
                    Icons.email,
                    color: Color(0xFF1976D2),
                  ),
                  title: Text('contact@sudanrx.org'),
                ),

                ListTile(
                  leading: Icon(
                    Icons.telegram,
                    color: Color(0xFF1976D2),
                  ),
                  title: Text('@sudanrx'),
                ),

                ListTile(
                  leading: Icon(
                    Icons.code_off,
                    color: Color(0xFF1976D2),
                  ),
                  title: Text('github.com/sudanrx'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Every contribution—whether medical, technical, or educational—helps improve access to trusted clinical knowledge across Sudan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionCard({
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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color(0xFFE3F2FD),
                  child: Icon(
                    icon,
                    color:
                        const Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
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