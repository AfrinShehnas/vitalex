import 'package:flutter/material.dart';
import 'reader_screen.dart';
import 'tts_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Coping Assistance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🧠 ICON
            const Icon(
              Icons.psychology_alt,
              size: 80,
              color: Color(0xFF4A90E2),
            ),

            const SizedBox(height: 20),

            const Text(
              'Choose a Tool',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 40),

            // 📄 DOCUMENT READER
            _buildOptionCard(
              context: context,
              icon: Icons.menu_book,
              title: 'Document Reader',
              subtitle: 'Read PDF, DOCX, TXT aloud',
              color: const Color(0xFF4A90E2),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  ReaderScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 🔊 TEXT TO SPEECH
            _buildOptionCard(
              context: context,
              icon: Icons.record_voice_over,
              title: 'Text to Speech',
              subtitle: 'Type or paste text to read aloud',
              color: const Color(0xFF2ECC71),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TTSScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 CARD BUILDER
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [

              // ICON
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),

              const SizedBox(width: 16),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}