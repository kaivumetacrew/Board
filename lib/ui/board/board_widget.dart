import 'dart:io';

import 'package:board/util/color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;

import '../board_text.dart';

mixin BoardWidget <T extends StatefulWidget> on State<T> {
  double get imageButtonSize => 32;

  Widget imageButton({
    IconData? icon,
    Color backgroundColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    final iconWidget = icon == null
        ? const SizedBox()
        : Icon(
            icon,
            color: Colors.grey,
          );
    return GestureDetector(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
            decoration: BoxDecoration(
                //borderRadius: BorderRadius.circular(1),
                border: Border.all(color: Colors.grey, width: 1),
                color: backgroundColor),
            //color: backgroundColor,
            width: imageButtonSize,
            height: imageButtonSize,
            child: iconWidget,
          ),
        ));
  }

  Widget colorPickerWidget(
      {bool isPortrait = false, required Function(String) onTap}) {
    List<String> colorList = [
      '#FFFFFF',
      '#000000',
      '#E53935',
      '#D81B60',
      '#8E24AA',
      '#5E35B1',
      '#3949AB',
      '#1E88E5',
      '#039BE5',
      '#00ACC1',
      '#00897B',
      '#43A047',
      '#43A047',
      '#7CB342',
      '#C0CA33',
      '#FDD835',
      '#FFB300',
      '#FB8C00',
      '#F4511E',
      '#6D4C41',
      '#757575',
      '#546E7A',
    ];

    final row = 2;
    final size = (imageButtonSize * row + row * 2);
    return SizedBox(
      width: isPortrait ? double.infinity : size,
      height: isPortrait ? size : double.infinity,
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          scrollDirection: isPortrait ? Axis.horizontal : Axis.vertical,
          padding: const EdgeInsets.only(left: 0, right: 0),
          itemCount: colorList.length,
          itemBuilder: (context, index) {
            final color = colorList[index];
            return imageButton(
                backgroundColor: fromHex(color),
                onPressed: () {
                  onTap(color);
                });
          }),
    );
  }

  Widget separator({Axis axis = Axis.vertical}) {
    if (axis == Axis.vertical) {
      return Container(width: double.infinity, height: 1, color: Colors.grey);
    }
    return Container(height: double.infinity, width: 1, color: Colors.grey);
  }

  Future<File?> pickImage() async {
    try {
      img_picker.ImagePicker picker = img_picker.ImagePicker();
      img_picker.XFile? pickedFile = await picker.pickImage(
        source: img_picker.ImageSource.gallery,
        maxWidth: 6000,
        maxHeight: 6000,
        imageQuality: 100,
      );
      final file = File(pickedFile!.path!);
      return file;
    } catch (e) {
      return null;
    }
  }

  Future pickText({
    required String? currentText,
    required String? currentFont,
    required Function(String text, String font) onResult,
  }) async {
    Map<String, dynamic>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TextPage(
          text: currentText,
          font: currentFont,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result == null) return;
    String text = result['text'] ?? '';
    String font = result['font'] ?? '';
    if (text.isEmpty || font.isEmpty) return;
    onResult(text, font);
  }
}
