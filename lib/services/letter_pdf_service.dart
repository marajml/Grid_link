import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:syncfusion_flutter_pdf/pdf.dart';

// Office Word → PDF conversion belongs in Phase 2 (server/Edge); this helper
// only merges a signature image onto an existing PDF.

/// Appends the supervisor signature image to the bottom-right of the last PDF page.
Uint8List mergeSignatureOntoPdfLastPage({
  required Uint8List pdfBytes,
  required Uint8List signatureImageBytes,
}) {
  final document = PdfDocument(inputBytes: pdfBytes);
  try {
    final page = document.pages[document.pages.count - 1];
    final pageSize = page.size;
    final graphics = page.graphics;
    final bitmap = PdfBitmap(signatureImageBytes);

    const sigW = 140.0;
    const sigH = 56.0;
    final x = pageSize.width - sigW - 32;
    final y = pageSize.height - sigH - 48;

    graphics.drawImage(bitmap, Rect.fromLTWH(x, y, sigW, sigH));

    final out = document.saveSync();
    return Uint8List.fromList(out);
  } finally {
    document.dispose();
  }
}
