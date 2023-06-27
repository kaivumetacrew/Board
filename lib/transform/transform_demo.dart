import 'package:flutter/material.dart';

import '../util/gesture_detector.dart';

class TransformDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('Transform Demo 0'),
      ),
      body: MatrixGestureDetector(
        onMatrixUpdate: (state,m, tm, sm, rm) {
          notifier.value = m;
        },
        onScaleStart: () {  },
        onScaleEnd: () {  },
        child: AnimatedBuilder(
          animation: notifier,
          builder: (ctx, child) {
            return Transform(
              transform: notifier.value,
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white30,
                  ),
                  Positioned.fill(
                    child: Container(
                      transform: notifier.value,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.deepPurple.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: FlutterLogoDecoration(),
                    padding: EdgeInsets.all(32),
                    alignment: Alignment(0, -0.5),
                    child: Text(
                      'use your two fingers to translate / rotate / scale ...',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
