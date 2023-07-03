import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

img.PngEncoder pngEncoder = img.PngEncoder(level: 0, filter: 0);

img.JpegEncoder jpegEncoder = img.JpegEncoder(quality: 100);

Uint8List encodeImage(img.Image image) {
  return Uint8List.fromList(jpegEncoder.encodeImage(image));
}

Future<Uint8List> fileToBytes(XFile file) async {
  return Uint8List.fromList(await file.readAsBytes());
}

