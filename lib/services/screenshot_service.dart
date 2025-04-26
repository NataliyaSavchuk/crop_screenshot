import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/image_processing.dart';

class ScreenshotService with ChangeNotifier {
  StreamSubscription<FileSystemEvent>? _screenshotSubscription;

  Future<void> startWatchingScreenshots() async {
    final Directory screenshotsDir = Directory('/storage/emulated/0/Pictures/Screenshots');

    if (await screenshotsDir.exists()) {
      _screenshotSubscription = screenshotsDir.watch().listen((event) async {
        if (event.type == FileSystemEvent.create) {
          final file = File(event.path);
          if (await file.exists()) {
            await _handleNewScreenshot(file);
          }
        }
      });
    }
  }

  Future<void> _handleNewScreenshot(File screenshot) async {
    final processedImage = await ImageProcessing.detectAndCropContent(screenshot);

    final Directory appPictures = await getApplicationDocumentsDirectory();
    final File savedFile = File('${appPictures.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await savedFile.writeAsBytes(await processedImage.readAsBytes());

    // Здесь можно добавить показ всплывающего окошка с обрезанным скриншотом на секунду.
  }

  void disposeService() {
    _screenshotSubscription?.cancel();
  }
}
