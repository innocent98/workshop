import 'dart:io';
import 'package:image/image.dart' as img;

class ImageCompressor {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int targetWidth = 1024;
  static const int jpegQuality = 85;

  static Future<File?> compress(File imageFile) async {
    try {
      final fileSize = await imageFile.length();

      if (fileSize > maxFileSizeBytes) {
        throw Exception('Image size exceeds 5MB limit');
      }

      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Unable to decode image');
      }

      img.Image resized;
      if (image.width > targetWidth) {
        resized = img.copyResize(image, width: targetWidth);
      } else {
        resized = image;
      }

      final compressedBytes = img.encodeJpg(resized, quality: jpegQuality);

      final tempPath = '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> validateFileSize(File file) async {
    final fileSize = await file.length();
    return fileSize <= maxFileSizeBytes;
  }
}
