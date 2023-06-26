import 'dart:async';

import 'package:flutter/material.dart';

class ButtonView extends StatelessWidget {
  Color backgroundColor;

  Color borderColor;
  final String text;
  Color textColor;
  final int? theme;
  final void Function()? onTap;
  final double? width;
  final EdgeInsetsGeometry? padding;
  static const outline = 1;

  ButtonView({
    Key? key,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.theme,
    required this.text,
    required this.onTap,
    this.width,
    this.padding,
    this.borderColor = Colors.black,
  }) : super(key: key);

  Timer? _debounceTime;

  @override
  Widget build(BuildContext context) {
    switch (theme) {
      case outline:
        backgroundColor = Colors.white;
        textColor = Colors.black;
        borderColor = Colors.black;
        break;
      default:
        break;
    }
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        height: 48,
        width: width ?? screen_size.width(context),
        child: ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor:
              MaterialStateProperty.all<Color>(backgroundColor),
              elevation: MaterialStateProperty.all<double>(0),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                      side: BorderSide(color: borderColor),
                      borderRadius: BorderRadius.circular(40)))),
          onPressed: () {
            if (onTap != null) {
              if (_debounceTime?.isActive ?? false) {
                _debounceTime?.cancel();
              }
              _debounceTime = Timer(const Duration(seconds: 1), () {
                onTap!();
              });
            }
          },
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}