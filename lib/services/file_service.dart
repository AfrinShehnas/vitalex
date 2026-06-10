import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';

class FileService {
  // Safety limits
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int _maxPdfPages = 100;

  static Future<FileResult?> pickAndExtractText() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) return null;

      File file = File(result.files.single.path!);
      String extension = result.files.single.extension?.toLowerCase() ?? '';
      String fileName = result.files.single.name;

      // Check file size
      int fileSize = await file.length();
      if (fileSize > _maxFileSize) {
        throw Exception('File too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Maximum is 10MB.');
      }

      String? text;

      switch (extension) {
        case 'pdf':
          text = await _extractFromPdf(file);
          break;
        case 'docx':
          text = await _extractFromDocx(file);
          break;
        case 'txt':
          text = await file.readAsString();
          break;
        default:
          throw Exception('Unsupported file format: $extension');
      }

      if (text == null || text.trim().isEmpty) {
        throw Exception('No text found in file. It may be an image-based document.');
      }

      return FileResult(text: text, fileName: fileName);

    } catch (e) {
      print('FileService Error: $e');
      return null;
    }
  }

  static Future<String?> _extractFromPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Check page count
      if (document.pages.count > _maxPdfPages) {
        document.dispose();
        throw Exception('PDF has ${document.pages.count} pages. Maximum is $_maxPdfPages pages.');
      }

      final PdfTextExtractor extractor = PdfTextExtractor(document);
      String text = extractor.extractText();
      document.dispose();

      if (text.trim().isEmpty) {
        throw Exception('PDF contains only images (scanned document).');
      }

      return text.trim();

    } catch (e) {
      print('PDF Extraction Error: $e');
      return null;
    }
  }

  static Future<String?> _extractFromDocx(File file) async {
    try {
      final bytes = await file.readAsBytes();
      String text = docxToText(bytes);

      if (text.trim().isEmpty) {
        throw Exception('DOCX file is empty or contains no text.');
      }

      return text.trim();

    } catch (e) {
      print('DOCX Extraction Error: $e');
      return null;
    }
  }
}

class FileResult {
  final String text;
  final String fileName;
  FileResult({required this.text, required this.fileName});
}