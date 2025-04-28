import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart'; // Подключаем библиотеку gal

class ScreenshotService {
  static Future<void> handleScreenshot(File screenshot) async {
    // Загружаем изображение
    img.Image image = img.decodeImage(screenshot.readAsBytesSync())!;

    // Логика обрезки: по центру экрана, размер квадрата равен ширине экрана
    int size = image.width; // Ширина экрана
    int offsetY = (image.height - size) ~/ 2; // Центрируем по вертикали

    // Обрезаем изображение
    img.Image cropped = img.copyCrop(
      image,
      x: 0,
      y: offsetY,
      width: size,
      height: size,
    );

    // Сохраняем обрезанное изображение в файл
    File croppedFile = File('/path/to/save/cropped_image.png');
    await croppedFile.writeAsBytes(img.encodePng(cropped));

    // Сохраняем в галерею в папку "SquareShots"
    await Gal.putImage(croppedFile.path, album: "SquareShots");
  }
}

