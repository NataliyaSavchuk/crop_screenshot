import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

class ScreenshotService {
  Future<Uint8List?> captureScreenshot() async {
    try {
      // Create a mock screenshot: text above a square image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      const text = 'Sample Text';
      final textStyle = ui.TextStyle(
        fontSize: 20,
        color: ui.Color(0xFF000000),
      );

      final paragraph = ui.ParagraphBuilder(
        ui.ParagraphStyle(),
      )
        ..pushStyle(textStyle)
        ..addText(text);

      final paragraphBuilt = paragraph.build()
        ..layout(const ui.ParagraphConstraints(width: 200));

      canvas.drawParagraph(paragraphBuilt, const Offset(0, 0));

      canvas.drawRect(
        const Rect.fromLTWH(0, 40, 200, 200),
        Paint()..color = const ui.Color(0xFFDDDDDD),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(200, 240);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing screenshot: $e');
      return null;
    }
  }

  Future<bool> saveToGallery(Uint8List imageBytes) async {
    try {
      await Gal.putImageBytes(imageBytes, album: 'SpecialScreenshots');
      return true;
    } catch (e) {
      print('Error saving to gallery: $e');
      return false;
    }
  }
}
