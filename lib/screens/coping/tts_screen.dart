import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/file_service.dart';   // ✅ FIXED
import 'package:flutter_tts/flutter_tts.dart'; 
class TTSScreen extends StatefulWidget {
  // NO const here - FlutterTts is not a constant
  TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  int? _highlightStart;
  int? _highlightEnd;
  bool isSpeaking = false;
  String _currentText = "";
  bool isTtsReady = false;
  bool isProcessingFile = false;
  double _speechRate = 0.5;

  int _currentPosition = 0;
  bool _hasStopped = false;

  String _spokenText = "";
  DateTime? _speakStartTime;
  static const int _charsPerSecond = 15;
  static const int _maxTextLength = 5000;

  @override
  void initState() {
    super.initState();
    _initTts();

    _textController.addListener(() {
      if (!isSpeaking && mounted) {
        setState(() {
          _currentText = _textController.text;
          _highlightStart = null;
          _highlightEnd = null;
        });
      }
    });
  }

  Future<void> _initTts() async {
    try {
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(_speechRate);
      await flutterTts.setPitch(1.0);
      await flutterTts.setVolume(1.0);

      if (!kIsWeb) {
        await flutterTts.setQueueMode(0);
      }

      flutterTts.setStartHandler(() {
        if (mounted) {
          setState(() {
            isSpeaking = true;
            _speakStartTime = DateTime.now();
          });
        }
      });

      flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            isSpeaking = false;
            _highlightStart = null;
            _highlightEnd = null;
            if (!_hasStopped) {
              _currentPosition = 0;
              _spokenText = "";
            }
            _hasStopped = false;
          });
        }
      });

      flutterTts.setCancelHandler(() {
        print("TTS Cancelled at position: $_currentPosition");
      });

      flutterTts.setErrorHandler((msg) {
        if (msg.toString().toLowerCase().contains('canceled') ||
            msg.toString().toLowerCase().contains('stop')) {
          print("TTS Stopped normally: $msg");
          return;
        }
        print("TTS Error: $msg");
        if (mounted) {
          setState(() => isSpeaking = false);
        }
      });

      if (!kIsWeb) {
        flutterTts.setProgressHandler((String text, int start, int end, String word) {
          if (mounted && word.trim().isNotEmpty) {
            setState(() {
              _highlightStart = start;
              _highlightEnd = end;
              _currentPosition = start;
            });
          }
        });
      }

      setState(() => isTtsReady = true);
    } catch (e) {
      print("TTS Init Error: $e");
      setState(() => isTtsReady = true);
    }
  }

  String cleanExtractedText(String text) {
    return text
        .replaceAll(RegExp(r'\$\d+'), ' ')
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s+([.,!?;:])'), r'$1')
        .trim();
  }

  Future<void> _pickDocument() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File upload not supported on web. Please type or paste text.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (isSpeaking || isProcessingFile) return;

    setState(() => isProcessingFile = true);

    FileResult? result = await FileService.pickAndExtractText();

    setState(() => isProcessingFile = false);

    if (result == null) {
      _showErrorSnackBar(
        'Could not read file.\n\n'
            '• Use text-based PDFs (not scanned images)\n'
            '• Max file size: 10MB\n'
            '• Max PDF pages: 100',
      );
      return;
    }

    String extractedText = cleanExtractedText(result.text);

    if (extractedText.length > _maxTextLength) {
      extractedText = extractedText.substring(0, _maxTextLength);
      _showWarningSnackBar('File was long - loaded first $_maxTextLength characters only');
    }

    setState(() {
      _textController.text = extractedText;
      _currentText = extractedText;
      _highlightStart = null;
      _highlightEnd = null;
      _currentPosition = 0;
      _spokenText = "";
      _hasStopped = false;
    });

    _showSuccessSnackBar('Loaded: ${result.fileName}');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _decreaseSpeed() {
    setState(() {
      _speechRate = (_speechRate - 0.1).clamp(0.1, 1.0);
      flutterTts.setSpeechRate(_speechRate);
    });
  }

  void _increaseSpeed() {
    setState(() {
      _speechRate = (_speechRate + 0.1).clamp(0.1, 1.0);
      flutterTts.setSpeechRate(_speechRate);
    });
  }

  Future<void> _speak() async {
    String fullText = _textController.text.trim();
    if (fullText.isEmpty || isSpeaking) return;

    if (fullText.length > _maxTextLength) {
      fullText = fullText.substring(0, _maxTextLength);
      _showWarningSnackBar('Text truncated to $_maxTextLength characters for TTS');
    }

    fullText = cleanExtractedText(fullText);

    String textToSpeak = fullText;
    if (_currentPosition > 0 && _currentPosition < fullText.length) {
      textToSpeak = fullText.substring(_currentPosition);
    }

    _spokenText = textToSpeak;

    String sanitizedText = textToSpeak;
    if (!kIsWeb) {
      sanitizedText = textToSpeak
          .replaceAll(RegExp(r'([.!?])\s+'), r'$1')
          .replaceAll(RegExp(r',\s+'), ',');
    }

    setState(() {
      _currentText = fullText;
      isSpeaking = true;
      _hasStopped = false;
      _speakStartTime = DateTime.now();
    });

    await flutterTts.stop();
    await Future.delayed(const Duration(milliseconds: 100));

    var result = await flutterTts.speak(sanitizedText);

    if (result != 1) {
      setState(() => isSpeaking = false);
      _showErrorSnackBar("Error starting speech");
    }
  }

  Future<void> _stop() async {
    _hasStopped = true;

    if (kIsWeb && _speakStartTime != null) {
      final elapsed = DateTime.now().difference(_speakStartTime!).inMilliseconds / 1000;
      final estimatedChars = (elapsed * _charsPerSecond * _speechRate).round();
      _currentPosition += estimatedChars.clamp(0, _spokenText.length);
    }

    try {
      await flutterTts.stop();
    } catch (e) {
      print("Stop error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isSpeaking = false;
          _highlightStart = null;
          _highlightEnd = null;
        });
      }
    }
  }

  void _resetPosition() {
    setState(() {
      _currentPosition = 0;
      _hasStopped = false;
      _spokenText = "";
      _highlightStart = null;
      _highlightEnd = null;
    });
    _showSuccessSnackBar('Position reset to beginning');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text to Speech"),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (_currentPosition > 0)
            IconButton(
              icon: const Icon(Icons.replay),
              tooltip: 'Reset to beginning',
              onPressed: _resetPosition,
            ),
          IconButton(
            icon: isProcessingFile
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Icon(kIsWeb ? Icons.upload_file_outlined : Icons.upload_file),
            tooltip: kIsWeb ? 'Upload not available on web' : 'Upload Document',
            onPressed: (isSpeaking || isProcessingFile) ? null : _pickDocument,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kIsWeb)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Web mode: File upload and word highlighting not available.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),

            if (_currentPosition > 0 && !isSpeaking)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_outline, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resume from position $_currentPosition',
                        style: const TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

            if (!isTtsReady || isProcessingFile)
              const LinearProgressIndicator(),

            const SizedBox(height: 8),

            TextField(
              controller: _textController,
              maxLines: 5,
              enabled: !isSpeaking,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: kIsWeb
                    ? "Type or paste text here..."
                    : "Type text or upload a document (PDF, DOCX, TXT)",
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      _currentText = "";
                      _highlightStart = null;
                      _highlightEnd = null;
                      _currentPosition = 0;
                      _spokenText = "";
                      _hasStopped = false;
                    });
                  },
                )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: _buildHighlightedText(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.speed, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text("Speed:", style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: _decreaseSpeed,
                      tooltip: 'Slower',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${(_speechRate * 100).round()}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: _increaseSpeed,
                      tooltip: 'Faster',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: (isSpeaking || !isTtsReady || isProcessingFile) ? null : _speak,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(isSpeaking
                      ? "Speaking..."
                      : _currentPosition > 0
                      ? "Resume"
                      : "Speak"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(width: 16),

                ElevatedButton.icon(
                  onPressed: isSpeaking ? _stop : null,
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              isProcessingFile
                  ? "Processing document..."
                  : isSpeaking
                  ? kIsWeb
                  ? "Speaking..."
                  : "Highlighting words as spoken..."
                  : _currentPosition > 0
                  ? "Press Resume to continue or Reset to start over"
                  : "Enter text and press Speak",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText() {
    final displayText = _currentText.isEmpty ? _textController.text : _currentText;

    if (displayText.isEmpty) {
      return const Text(
        "Text will appear here...\n\nUpload a file or type text above.",
        style: TextStyle(
          fontSize: 22,
          height: 1.6,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final start = _highlightStart;
    final end = _highlightEnd;

    if (start == null || end == null || !isSpeaking || kIsWeb) {
      return Text(
        displayText,
        style: const TextStyle(
          fontSize: 22,
          height: 1.6,
          color: Colors.black87,
          fontFamily: 'OpenDyslexic',
        ),
      );
    }

    final safeStart = start.clamp(0, displayText.length);
    final safeEnd = end.clamp(0, displayText.length);

    if (safeStart >= safeEnd) {
      return Text(
        displayText,
        style: const TextStyle(
          fontSize: 22,
          height: 1.6,
          color: Colors.black87,
          fontFamily: 'OpenDyslexic',
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 22,
          height: 1.6,
          color: Colors.black87,
          fontFamily: 'OpenDyslexic',
        ),
        children: [
          TextSpan(text: displayText.substring(0, safeStart)),
          TextSpan(
            text: displayText.substring(safeStart, safeEnd),
            style: TextStyle(
              backgroundColor: Colors.yellow.shade300,
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue.shade800,
              decorationThickness: 2,
            ),
          ),
          TextSpan(text: displayText.substring(safeEnd)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }
}