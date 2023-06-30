import 'package:flutter/material.dart';

Widget imageButton({
  IconData? icon,
  Color backgroundColor = Colors.grey,
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

Widget separator(){
  return Container(width: double.infinity, height: 1, color: Colors.grey);
}