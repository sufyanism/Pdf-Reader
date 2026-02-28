import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/toc_item.dart';

class TocService {

  /// Detect chapters automatically
  static Future<List<TocItem>> generateTOC(String assetPath) async {

    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    final document = PdfDocument(inputBytes: bytes);

    final List<TocItem> toc = [];

    for (int i = 0; i < document.pages.count; i++) {

      final text =
      PdfTextExtractor(document).extractText(startPageIndex: i);

      /// SIMPLE HEADING DETECTION RULES
      final lines = text.split('\n');

      for (final line in lines) {

        final clean = line.trim();

        /// Detect headings automatically
        if (_isChapterHeading(clean)) {
          toc.add(
            TocItem(
              title: clean,
              page: i + 1,
            ),
          );
          break;
        }
      }
    }

    document.dispose();
    return toc;
  }

  /// Heuristic rules for chapter detection
  static bool _isChapterHeading(String text) {

    if (text.length < 4 || text.length > 80) return false;

    final lower = text.toLowerCase();

    return lower.startsWith("chapter") ||
        lower.startsWith("unit") ||
        lower.startsWith("lesson") ||
        lower.startsWith("section") ||
        RegExp(r'^chapter\s+\d+').hasMatch(lower);
  }
}