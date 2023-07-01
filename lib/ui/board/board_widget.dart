import 'package:flutter/material.dart';

Widget imageButton({
  IconData? icon,
  Color backgroundColor = Colors.black12,
  required VoidCallback onPressed,
}) {
  var iconWidget = icon == null ? const SizedBox() : Icon(icon);
  return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Container(
          color: backgroundColor,
          width: 36,
          height: 36,
          child: iconWidget,
        ),
      ));
}

Widget colorPickerWidget(Function(Color) onTap) {
  List<Color> colorList = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple
  ];
  return SizedBox(
    height: 38,
    width: double.infinity,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 0, right: 0),
      itemCount: colorList.length,
      itemBuilder: (context, index) {
        var color = colorList[index];
        return imageButton(
            backgroundColor: color,
            onPressed: () {
              onTap(color);
            });
      },
    ),
  );
}

Widget separator({Axis axis = Axis.vertical}) {
  if (axis == Axis.vertical) {
    return Container(width: double.infinity, height: 1, color: Colors.grey);
  }
  return Container(height: double.infinity, width: 1, color: Colors.grey);
}
