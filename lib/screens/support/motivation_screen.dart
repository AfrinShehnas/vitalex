import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {

  final List<Map<String, String>> quotes = [
    {"text": "Your brain is wired differently, not wrongly. That's your superpower.", "author": "Dr. Sally Shaywitz"},
    {"text": "Dyslexia is not a disability, it's a different ability.", "author": "Richard Branson"},
    {"text": "I didn't succeed despite my dyslexia, but because of it.", "author": "Richard Branson"},
    {"text": "The greatest minds in history saw the world differently too.", "author": "Unknown"},
    {"text": "You are not broken. You are powerful.", "author": "Unknown"},
  ];

  final List<Map<String, dynamic>> videos = [
    {
      "title": "TED Talk: Dyslexic Mind",
      "duration": "18 min",
      "url": "https://www.youtube.com/results?search_query=ted+talk+dyslexia",
    },
    {
      "title": "Branson Success Story",
      "duration": "12 min",
      "url": "https://www.youtube.com/results?search_query=richard+branson+dyslexia",
    },
  ];

  final List<String> challenges = [
    "Read one page of a book",
    "Write 3 strengths",
    "Take a short walk",
    "Listen to a podcast",
    "Text a friend",
  ];

  int currentQuote = 0;
  int currentDay = 1;
  bool challengeCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDay = prefs.getInt('day') ?? 1;
    final savedDate = prefs.getString('date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (savedDate != today) {
      currentDay = savedDay >= challenges.length ? 1 : savedDay + 1;
      await prefs.setInt('day', currentDay);
      await prefs.setString('date', today);
      await prefs.setBool('done', false);
    } else {
      currentDay = savedDay;
      challengeCompleted = prefs.getBool('done') ?? false;
    }

    setState(() {});
  }

  Future<void> _completeChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('done', true);
    setState(() => challengeCompleted = true);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support Hub")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // QUOTE
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(quotes[currentQuote]["text"] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    Text("- ${quotes[currentQuote]["author"]}"),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentQuote = Random().nextInt(quotes.length);
                        });
                      },
                      child: const Text("New Quote"),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // VIDEOS
            Column(
              children: videos.map((video) {
                return Card(
                  child: ListTile(
                    title: Text(video["title"]),
                    subtitle: Text(video["duration"]),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () => _launchURL(video["url"]),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // CHALLENGE
            Card(
              color: Colors.orange.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Day $currentDay"),
                    Text(challenges[currentDay - 1]),
                    ElevatedButton(
                      onPressed: challengeCompleted ? null : _completeChallenge,
                      child: Text(
                        challengeCompleted ? "Done ✅" : "Mark Done",
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}