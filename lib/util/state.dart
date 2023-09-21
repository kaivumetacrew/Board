import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

extension StateExtension on State {

  void showToast(String? s) {
    Fluttertoast.showToast(
      msg: s ?? 'null',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  void showSnackBar(String? s) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s ?? '')));
  }

  void showBottomDialog(Widget widget) {
    showModalBottomSheet(
        context: context,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        barrierColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          //side: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            topLeft: Radius.circular(8),
          ),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return widget;
        });
  }

  void sampleShowDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('sample alert dialog'),
          content: Text("dismiss by touch outside"),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void transparentStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // set Status bar icons color in Android devices
      statusBarIconBrightness: Brightness.dark,
      // set Status bar icon color in iOS
      statusBarBrightness: Brightness.dark,
    ));
  }

  Future<void> showMessageDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: EdgeInsets.only(top: 16),
            child: Container(
              height: 60,
              child: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Size get screenSize => MediaQuery.of(context).size;

  Orientation get orientation => MediaQuery.of(context).orientation;

  bool get isPortrait => orientation == Orientation.portrait;

  FlutterView get flutterView => View.of(context);

  double get screenWidthPx => flutterView.physicalSize.width;

  double get screenHeightPx => flutterView.physicalSize.height;

  double pixelToDip(double pixel) {
    return pixel / flutterView.devicePixelRatio;
  }

  double dipToPixel(double dip) {
    return dip * flutterView.devicePixelRatio;
  }

  /// Open New Screen:
  Future<R?> push<R extends Object?>(
    Widget widget, {
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => widget,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Open New Screen and Clear Current Route:
  Future<void> pushReplacement(Widget widget) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
    );
  }

  /// Open New Screen and Clear all Previous Navigation History:
  Future<void> pushAndRemove(Widget widget) async {
    await Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(builder: (BuildContext context) => widget),
      //if you want to disable back feature set to false
      (route) => false,
    );
  }

  Future<R?> pushFullScreenDialog<R extends Object?>(Widget widget) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => widget,
        fullscreenDialog: true,
      ),
    );
  }
}
