import 'dart:ui';

import 'package:flutter/material.dart';

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
