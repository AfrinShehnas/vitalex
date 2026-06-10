import 'package:flutter/material.dart';

// ✅ TEST MODULE
import '../test/age_selection_screen.dart';

// ✅ GAME MODULE
import '../games/game_menu.dart';

// ✅ COPING MODULE
import '../coping/home_screen.dart'; // ✅ correct path
import '../profile/profile_page.dart';
import '../support/motivation_screen.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),

      appBar: AppBar(
        title: const Text("Vitalex"),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 2,
        actions: [
  Padding(
    padding: const EdgeInsets.only(right: 12),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfilePage(),
          ),
        );
      },
      child: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/profile.jpeg'),
      ),
    ),
  ),
],
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          // ✅ LOGO
          Image.asset(
            'assets/images/logo.jpeg',
            height: 90,
          ),

          const SizedBox(height: 15),

          const Text(
            "Hello 👋\nLet's continue your journey",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          // ✅ GRID
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [

                // 🔍 TEST
                _buildCard(
                  context,
                  'assets/images/test.jpeg',
                  "Test",
                  Colors.green,
                  Colors.lightGreen,
                ),

                // 🧠 COPING
                _buildCard(
                  context,
                  'assets/images/coping.jpeg',
                  "Coping",
                  Colors.blue,
                  Colors.lightBlueAccent,
                ),

                // 🎮 GAMES
                _buildCard(
                  context,
                  'assets/images/gaming.jpeg',
                  "Games",
                  Colors.purple,
                  Colors.purpleAccent,
                ),

                // 🤝 SUPPORT (future)
                _buildCard(
                  context,
                  'assets/images/support.jpeg',
                  "Support",
                  Colors.orange,
                  Colors.deepOrangeAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ CARD WIDGET
  Widget _buildCard(
    BuildContext context,
    String image,
    String text,
    Color c1,
    Color c2,
  ) {
    return GestureDetector(
      onTap: () {
        if (text == "Test") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AgeSelectionScreen(),
            ),
          );
        }

        else if (text == "Games") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>  GameMenu(),
            ),
          );
        }

        else if (text == "Coping") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>  HomeScreen(),
            ),
          );
        }

        else if (text == "Support") {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const MotivationScreen(),
    ),
  );
}
      },

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(colors: [c1, c2]),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),

        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}