import 'package:flutter/material.dart';
import '../../services/file_service.dart';   // ✅ FIXED
import '../../services/tts_service.dart';   // ✅ FIXED
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  String _extractedText = '';
  String _fileName = '';
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final TTSService _ttsService = TTSService();

  @override
  void initState() {
    super.initState();
    _ttsService.init();
  }

  Future<void> _pickAndReadDocument() async {
    setState(() => _isLoading = true);

    FileResult? result = await FileService.pickAndExtractText();

    setState(() => _isLoading = false);

    if (result == null) {
      _showErrorDialog(
        'Could not read document.\n\n'
            'Possible reasons:\n'
            '• PDF contains only images (scanned document)\n'
            '• File is too large (max 10MB)\n'
            '• PDF has more than 100 pages\n'
            '• File is corrupted\n\n'
            'Please try a text-based PDF, DOCX, or TXT file.',
      );
      return;
    }

    setState(() {
      _extractedText = result.text;
      _fileName = result.fileName;
    });
  }

  void _clearText() {
    setState(() {
      _extractedText = '';
      _fileName = '';
    });
    _ttsService.stop();
  }

  void _speakText() {
    if (_extractedText.isNotEmpty) {
      // Warn if text is long
      if (_extractedText.length > 5000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text is long - only first 5000 characters will be read'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      _ttsService.speak(_extractedText);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Cannot Read File',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Document Reader',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_extractedText.isNotEmpty) ...[
            IconButton(
              onPressed: _speakText,
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Read aloud',
            ),
            IconButton(
              onPressed: () => _ttsService.stop(),
              icon: const Icon(Icons.stop),
              tooltip: 'Stop',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Upload Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickAndReadDocument,
                  icon: const Icon(Icons.upload_file, size: 24),
                  label: const Text(
                    'Upload Document',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                ),
                if (_fileName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Selected: $_fileName',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4A90E2)),
                    SizedBox(height: 16),
                    Text(
                      'Processing document...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

          // Text Display Area
          if (!_isLoading && _extractedText.isNotEmpty)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          child: SelectableText(
                            _extractedText,
                            style: const TextStyle(
                              fontFamily: 'OpenDyslexic',
                              fontSize: 18,
                              height: 1.8,
                              letterSpacing: 0.5,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _clearText,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE74C3C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Empty State
          if (!_isLoading && _extractedText.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 80,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No document uploaded yet.\nTap the button above to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ttsService.dispose();
    super.dispose();
  }
}