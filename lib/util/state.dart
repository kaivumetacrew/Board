import 'package:flutter/material.dart';

extension StateExtension on State {

  Future<R?> push<R extends Object?>(Widget page, {bool fullscreenDialog = false}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

}
