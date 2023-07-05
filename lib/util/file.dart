import 'dart:io';
import 'dart:typed_data';

class FileHelper{

  FileHelper._();

  static Future<String> save(String thumbPath, Uint8List? bytes) async {
    if (bytes == null) return '';
    try{
      File file = File(thumbPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      file.createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      return thumbPath;
    }on Exception catch (_) {
      return '';
    }
  }
}