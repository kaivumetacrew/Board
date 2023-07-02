import 'package:board/util/color.dart';
import 'package:flutter/material.dart';

const double imageButtonSize = 32;

Widget imageButton({
  IconData? icon,
  Color backgroundColor = Colors.white,
  required VoidCallback onPressed,
}) {
  var iconWidget = icon == null
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

  var row = 2;
  var size = (imageButtonSize * row + row * 2);
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
          var color = colorList[index];
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
