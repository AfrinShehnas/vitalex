import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

////////////////////////////////////////////////////////////
/// GAME MENU
////////////////////////////////////////////////////////////

class GameMenu extends StatelessWidget {
  const GameMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.atkinsonHyperlegibleTextTheme(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Dyslexia Games")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _btn(context, "Mirror Letter Match", const MirrorLetterGame()),
              _btn(context, "Word Builder", const WordBuilderGame()),
              _btn(context, "Find the Different Letter", const DifferenceGame()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
          child: Text(title, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 1️⃣ MIRROR LETTER MATCH
////////////////////////////////////////////////////////////

class MirrorLetterGame extends StatefulWidget {
  const MirrorLetterGame({super.key});

  @override
  State<MirrorLetterGame> createState() => _MirrorLetterGameState();
}

class _MirrorLetterGameState extends State<MirrorLetterGame> {
  final letters = ["b","d","p","q","m","w","n","u"];
  final random = Random();

  String correct = "";
  int score = 0;
  int round = 1;
  final int maxRounds = 8;
  String feedback = "";

  @override
  void initState() {
    super.initState();
    nextRound();
  }

  void nextRound() {
    if (round > maxRounds) {
      showResult();
      return;
    }

    correct = letters[random.nextInt(letters.length)];
    feedback = "";
    setState(() {});
  }

  void check(String selected) {
    if (selected == correct) {
      score++;
      feedback = "Correct ✅";
    } else {
      score--; // ❌ minus point
      feedback = "Wrong ❌";
    }

    setState(() {});

    Future.delayed(const Duration(seconds: 1), () {
      round++;
      nextRound();
    });
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Score: $score / $maxRounds"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mirror Match")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Round $round / $maxRounds"),
            const SizedBox(height: 20),

            Text(correct.toUpperCase(),
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),

            const SizedBox(height: 30),

            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: letters.map((l) {
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => check(l),
                    child: Text(l.toLowerCase()),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Text(feedback),
            Text("Score: $score"),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 2️⃣ WORD BUILDER
////////////////////////////////////////////////////////////

class WordBuilderGame extends StatefulWidget {
  const WordBuilderGame({super.key});

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame> {
  final words = ["CAT","DOG","SUN","BAT","TRAIN","PLANT","god","life","worm"];
  final random = Random();

  String word = "";
  List<String> shuffled = [];
  String answer = "";
  int score = 0;
  int round = 1;
  final int maxRounds = 8;
  String feedback = "";

  @override
  void initState() {
    super.initState();
    nextRound();
  }

  void nextRound() {
    if (round > maxRounds) {
      showResult();
      return;
    }

    word = words[random.nextInt(words.length)];
    shuffled = word.split("")..shuffle();
    answer = "";
    feedback = "";
    setState(() {});
  }

  void select(String l) {
    answer += l;

    if (answer.length == word.length) {
      if (answer == word) {
        score++;
        feedback = "Correct ✅";
      } else {
        score--; // ❌ minus
        feedback = "Wrong ❌";
      }

      setState(() {});

      Future.delayed(const Duration(seconds: 1), () {
        round++;
        nextRound();
      });
    }
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Score: $score / $maxRounds"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Word Builder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Round $round / $maxRounds"),
            const SizedBox(height: 20),

            Text(answer,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              children: shuffled.map((l) {
                return ElevatedButton(
                  onPressed: () => select(l),
                  child: Text(l, style: const TextStyle(fontSize: 24)),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Text(feedback),
            Text("Score: $score"),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 3️⃣ DIFFERENCE GAME
////////////////////////////////////////////////////////////

class DifferenceGame extends StatefulWidget {
  const DifferenceGame({super.key});

  @override
  State<DifferenceGame> createState() => _DifferenceGameState();
}

class _DifferenceGameState extends State<DifferenceGame> {
  final pairs = [["b","d"],["p","q"],["m","w"],["n","u"]];
  final random = Random();

  List<String> grid = [];
  String odd = "";
  int score = 0;
  int round = 1;
  final int maxRounds = 8;
  String feedback = "";

  @override
  void initState() {
    super.initState();
    nextRound();
  }

  void nextRound() {
    if (round > maxRounds) {
      showResult();
      return;
    }

    var pair = pairs[random.nextInt(pairs.length)];
    grid = [pair[0], pair[0], pair[0], pair[1]];
    odd = pair[1];
    grid.shuffle();
    feedback = "";
    setState(() {});
  }

  void check(String s) {
    if (s == odd) {
      score++;
      feedback = "Correct ✅";
    } else {
      score--; // ❌ minus
      feedback = "Wrong ❌";
    }

    setState(() {});

    Future.delayed(const Duration(seconds: 1), () {
      round++;
      nextRound();
    });
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Score: $score / $maxRounds"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Different")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Round $round / $maxRounds"),
            const SizedBox(height: 20),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: grid.map((l) {
                return ElevatedButton(
                  onPressed: () => check(l),
                  child: Text(l.toLowerCase(),
                      style: const TextStyle(fontSize: 40)),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Text(feedback),
            Text("Score: $score"),
          ],
        ),
      ),
    );
  }
}