import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

extension StateExtension on State {

  Future<R?> push<R extends Object?>(Widget page,
      {bool fullscreenDialog = false}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  void showToast(String? s) {
    Fluttertoast.showToast(
        msg: s ?? 'null',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  void showSnackBar(String? s) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s ?? '')));
  }

  Size get screenSize => MediaQuery.of(context).size;

  FlutterView get flutterView => View.of(context);

  double get screenWidthPx => flutterView.physicalSize.width;

  double get screenHeightPx => flutterView.physicalSize.height;

  double pixelToDip(double pixel) {
    return pixel / flutterView.devicePixelRatio;
  }

  double dipToPixel(double dip) {
    return dip * flutterView.devicePixelRatio;
  }
}
