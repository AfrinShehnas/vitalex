import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class DyslexiaTestingModule extends StatefulWidget {
  final int userAge;
  final String ageGroup;
  const DyslexiaTestingModule({Key? key, required this.userAge,required this.ageGroup}) : super(key: key);

  @override
  State<DyslexiaTestingModule> createState() => _DyslexiaTestingModuleState();
}

class _DyslexiaTestingModuleState extends State<DyslexiaTestingModule> {
  // Test stages
  int currentStage = 0; // 0: Reading Test, 1: Typing Test, 2: Results
  
  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  
  // Test data
  String currentSentence = '';
  DateTime? testStartTime;
  DateTime? testEndTime;
  
  // Reading test results
  double readingSpeed = 0.0; // words per minute
  double readingAccuracy = 0.0; // percentage
  
  // Typing test results
  String typedText = '';
  double typingSpeed = 0.0;
  double typingAccuracy = 0.0;
  int missingLetters = 0;
  int extraLetters = 0;
  
  // Final risk assessment
  String riskLevel = '';
  
  // Sentences for different age groups
 final Map<String, List<String>> sentences = {
  '6-7': [
    'The cat sits.',
    'I see a dog.',
    'Sun is hot.',
  ],
  '8-9': [
    'The cat sits on the mat.',
    'I like to play outside.',
    'Birds fly in the sky.',
  ],
  '10-12': [
    'The sun shines brightly in the sky.',
    'Reading books improves your knowledge.',
  ],
  '13-15': [
    'The curious student explored the ancient library.',
    'Learning new skills requires consistent practice.',
  ],
  '16-18': [
    'Technology has significantly changed modern communication.',
    'Critical thinking is essential for problem solving.',
  ],
  '18+': [
    'Environmental sustainability requires collective global effort.',
    'Advancements in science continue to shape our future.',
  ],
};
Map<String, Map<String, double>> strictBenchmarks = {
  '6-7':  {'readMin': 30,  'typeMin': 8,  'accMin': 60},
  '8-9':  {'readMin': 50,  'typeMin': 12, 'accMin': 65},
  '10-12':{'readMin': 80,  'typeMin': 20, 'accMin': 70},
  '13-15':{'readMin': 110, 'typeMin': 30, 'accMin': 75},
  '16-18':{'readMin': 140, 'typeMin': 40, 'accMin': 80},
  '18+':  {'readMin': 160, 'typeMin': 50, 'accMin': 85},
};

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestMicPermission();
    _initializeSpeech();
    _selectSentence();
  }
  Future<void> _requestMicPermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    await Permission.microphone.request();
  }
}


  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
    if (!available) {
      print('Speech recognition not available');
    }
  }

 void _selectSentence() {
  final sentenceList = sentences[widget.ageGroup]!;
  currentSentence = (sentenceList..shuffle()).first;
}

  void _startReadingTest() {
    setState(() {
      _recognizedText = '';
      testStartTime = DateTime.now();
    });
    _startListening();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 120),
          pauseFor: Duration(seconds: 5),
          cancelOnError: true,
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        testEndTime = DateTime.now();
      });
      _calculateReadingResults();
    }
  }

  void _calculateReadingResults() {
    if (testStartTime != null && testEndTime != null) {
      // Calculate reading speed (words per minute)
      final duration = testEndTime!.difference(testStartTime!).inSeconds;
      final wordCount = currentSentence.split(' ').length;
      readingSpeed = duration > 0 ? (wordCount / duration) * 60 : 0;


      // Calculate accuracy using Levenshtein distance
      
      readingAccuracy = _calculateAccuracy(
  currentSentence.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), ''),
  _recognizedText.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), ''),
);
    }
  }

  double _calculateAccuracy(String original, String recognized) {
    final distance = _levenshteinDistance(original, recognized);
    final maxLength = original.length > recognized.length ? original.length : recognized.length;
    double acc = ((maxLength - distance) / maxLength * 100);
return acc < 0 ? 0 : acc;
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= s2.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[s1.length][s2.length];
  }
  double _detectLetterConfusion(String original, String input) {
  List<List<String>> confusionPairs = [
    ['b', 'd'],
    ['p', 'q'],
    ['m', 'w'],
    ['n', 'u'],
  ];

  int confusionCount = 0;
  int len = original.length < input.length ? original.length : input.length;

  for (int i = 0; i < len; i++) {
    for (var pair in confusionPairs) {
      if ((original[i] == pair[0] && input[i] == pair[1]) ||
          (original[i] == pair[1] && input[i] == pair[0])) {
        confusionCount++;
      }
    }
  }

  return len > 0 ? confusionCount / len : 0;
}

  void _moveToTypingTest() {
    _selectSentence(); // Get new sentence for typing test
    setState(() {
      currentStage = 1;
      typedText = '';
      testStartTime = null;
      testEndTime = null;
    });
  }

  void _startTypingTest() {
    setState(() {
      testStartTime = DateTime.now();
    });
  }

  void _completeTypingTest() {
    setState(() {
      testEndTime = DateTime.now();
    });
    _calculateTypingResults();
    _assessRiskLevel();
    setState(() {
      currentStage = 2;
    });
  
  }
  double _getExpectedTypingSpeed() {
  switch (widget.ageGroup) {
    case '6-7':
      return 15;
    case '8-9':
      return 20;
    case '10-12':
      return 30;
    case '13-15':
      return 40;
    case '16-18':
      return 50;
    case '18+':
      return 60;
    default:
      return 40;
  }
}
void _calculateTypingResults() {
  if (testStartTime != null && testEndTime != null) {
    final duration = testEndTime!.difference(testStartTime!).inSeconds;
    final wordCount = typedText.trim().isEmpty
    ? 0
    : typedText.trim().split(RegExp(r'\s+')).length;

    typingSpeed = duration > 0 ? (wordCount / duration) * 60 : 0;

    String original = currentSentence.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    String typed = typedText.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    typingAccuracy = _calculateAccuracy(original, typed);

    missingLetters = 0;
    extraLetters = 0;

    int minLen = original.length < typed.length ? original.length : typed.length;

    for (int i = 0; i < minLen; i++) {
      if (original[i] != typed[i]) {
        missingLetters++;
      }
    }

    if (original.length > typed.length) {
      missingLetters += original.length - typed.length;
    } else {
      extraLetters += typed.length - original.length;
    }
  }
}

void _assessRiskLevel() {
  double avgAccuracy = (readingAccuracy + typingAccuracy) / 2;

  double minRead = strictBenchmarks[widget.ageGroup]!['readMin']!;
  double minType = strictBenchmarks[widget.ageGroup]!['typeMin']!;

  double readingPerf = (readingSpeed / minRead);
  double typingPerf = (typingSpeed / minType);

  double errorTendency = _calculateErrorTendency();

  // ✅ 1. EASY NORMAL CHECK (HUMAN REALISTIC 🔥)
  if (avgAccuracy >= 88 &&
      readingPerf >= 0.6 &&
      typingPerf >= 0.5) {
    riskLevel = 'Normal';
    return;
  }

  // 🎯 2. STRICT NORMAL (EXCELLENT PERFORMANCE)
  if (avgAccuracy >= 93 &&
      readingPerf >= 0.7 &&
      typingPerf >= 0.6 &&
      errorTendency < 0.3) {
    riskLevel = 'Normal';
    return;
  }

  // 🟡 3. LOW RISK
  if (avgAccuracy >= 80 && errorTendency < 0.5) {
    riskLevel = 'Low Risk';
    return;
  }

  // 🟠 4. MEDIUM RISK
  if (avgAccuracy >= 65) {
    riskLevel = 'Medium Risk';
    return;
  }

  // 🔴 5. HIGH RISK
  riskLevel = 'High Risk';
}
  double _calculateErrorTendency() {
  String original = currentSentence.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  String typed = typedText.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

  double avgAccuracy = (readingAccuracy + typingAccuracy) / 2;

  double accuracyError = (100 - avgAccuracy) / 100;

  double letterError = (missingLetters + extraLetters) / (original.length + 1);

  double confusionError = _detectLetterConfusion(original, typed);

  // ✅ Age-based typing speed
  double expectedSpeed = _getExpectedTypingSpeed();
  double typingSpeedPenalty = 0;

  if (typingSpeed < expectedSpeed) {
    typingSpeedPenalty = (expectedSpeed - typingSpeed) / expectedSpeed;
  }
  if (letterError < 0.05) letterError = 0;
  if (confusionError < 0.05) confusionError = 0;
  
  return (accuracyError * 0.6 +
          letterError * 0.15 +
          confusionError * 0.1 +
          typingSpeedPenalty * 0.05).clamp(0, 1);
}
  double _getReadingScore() {
  double minRead = strictBenchmarks[widget.ageGroup]!['readMin']!;

  return (readingSpeed / minRead * 100).clamp(0, 100);
}
double _getReadingPerformance() {
  double minRead = strictBenchmarks[widget.ageGroup]!['readMin']!;

  if (readingSpeed >= minRead) return 1.0;

  return (readingSpeed / minRead).clamp(0, 1);
}
double _getTypingPerformance() {
  double minType = strictBenchmarks[widget.ageGroup]!['typeMin']!;

  if (typingSpeed >= minType) return 1.0;

  return (typingSpeed / minType).clamp(0, 1);
}
double _getTypingScore() {
  double minType = strictBenchmarks[widget.ageGroup]!['typeMin']!;

  return (typingSpeed / minType * 100).clamp(0, 100);
}
double _getAccuracyScore() {
  double minAcc = strictBenchmarks[widget.ageGroup]!['accMin']!;

  double avgAccuracy = (readingAccuracy + typingAccuracy) / 2;

  return (avgAccuracy / minAcc * 100).clamp(0, 100);
}
double _getTotalErrorPercentage() {
  double avgAccuracy = (readingAccuracy + typingAccuracy) / 2;
  return (100 - avgAccuracy);
}
double _getMinPerformanceRequired() {
  switch (widget.ageGroup) {
    case '6-7':
      return 0.5;
    case '8-9':
      return 0.6;
    case '10-12':
      return 0.7;
    case '13-15':
      return 0.75;
    case '16-18':
      return 0.8;
    case '18+':
      return 0.8;
    default:
      return 0.7;
  }
}
double _getAllowedError() {
  switch (widget.ageGroup) {
    case '6-7':
      return 13; // kids make more mistakes
    case '8-9':
      return 12;
    case '10-12':
      return 10;
    case '13-15':
      return 7;
    case '16-18':
      return 5;
    case '18+':
      return 3; // 🔥 strict for adults
    default:
      return 5;
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFE6F2E6), // ✅ added line
    appBar: AppBar(
      title: Text('Dyslexia Assessment Test'),
      backgroundColor: const Color.fromARGB(255, 129, 235, 215),
    ),
    body: SafeArea(
      child: _buildCurrentStage(),
    ),
  );
}


  Widget _buildCurrentStage() {
    switch (currentStage) {
      case 0:
        return _buildReadingTest();
      case 1:
        return _buildTypingTest();
      case 2:
        return _buildResults();
      default:
        return Container();
    }
  }

  Widget _buildReadingTest() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Reading Test',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Text(
            'Read the following sentence aloud:',
            style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 64, 56, 56)),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              currentSentence,
              style: TextStyle(fontSize: 22, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
          if (_recognizedText.isNotEmpty) ...[
            Text(
              'Recognized:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _recognizedText,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
          ],
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isListening ? _stopListening : _startReadingTest,
            icon: Icon(_isListening ? Icons.stop : Icons.mic),
            label: Text(
              _isListening ? 'Stop Reading' : 'Start Reading',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              backgroundColor: _isListening ? Colors.red : Colors.blue,
            ),
          ),
          SizedBox(height: 20),
          if (!_isListening && _recognizedText.isNotEmpty)
            ElevatedButton(
              onPressed: _moveToTypingTest,
              child: Text('Next: Typing Test', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingTest() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Typing Test',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Text(
            'Type the following sentence:',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Text(
              currentSentence,
              style: TextStyle(fontSize: 22, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
          TextField(
            onChanged: (value) {
              if (testStartTime == null) {
                _startTypingTest();
              }
              setState(() {
                typedText = value;
              });
            },
            maxLines: 3,
            style: TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Type here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: typedText.isNotEmpty ? _completeTypingTest : null,
            child: Text('Submit & View Results', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    Color riskColor;
    switch (riskLevel) {
      case 'Normal':
        riskColor = Colors.green;
        break;
      case 'Low Risk':
        riskColor = Colors.yellow[700]!;
        break;
      case 'Medium Risk':
        riskColor = Colors.orange;
        break;
      case 'High Risk':
        riskColor = Colors.red;
        break;
      default:
        riskColor = Colors.grey;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Assessment Results',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: riskColor, width: 3),
            ),
            child: Column(
              children: [
                Icon(Icons.assessment, size: 60, color: riskColor),
                SizedBox(height: 16),
                Text(
                  riskLevel,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          _buildResultCard('Reading Performance', [
            _buildResultRow('Speed', '${readingSpeed.toStringAsFixed(1)} words/min'),
            _buildResultRow('Accuracy', '${readingAccuracy.toStringAsFixed(1)}%'),
          ]),
          SizedBox(height: 16),
          _buildResultCard('Typing Performance', [
            _buildResultRow('Speed', '${typingSpeed.toStringAsFixed(1)} words/min'),
            _buildResultRow('Accuracy', '${typingAccuracy.toStringAsFixed(1)}%'),
            _buildResultRow('Missing Letters', '$missingLetters'),
            _buildResultRow('Extra Letters', '$extraLetters'),
          ]),
          SizedBox(height: 16),
          _buildResultCard('Error Analysis', [
            _buildResultRow('Composite Error', '${(_calculateErrorTendency() * 100).toStringAsFixed(1)}%'),
          ]),
         
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentStage = 0;
                _selectSentence();
                _recognizedText = '';
                typedText = '';
              });
            },
            child: Text('Take Test Again', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}