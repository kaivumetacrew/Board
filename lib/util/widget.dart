import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

extension WidgetExtension on Widget {}

void getWidgetInfo(GlobalKey globalKey) {
  final RenderBox renderBox =
      globalKey.currentContext?.findRenderObject() as RenderBox;

  final Size size = renderBox.size; // or _widgetKey.currentContext?.size
  print('Size: ${size.width}, ${size.height}');

  final Offset offset = renderBox.localToGlobal(Offset.zero);
  print('Offset: ${offset.dx}, ${offset.dy}');
  print(
      'Position: ${(offset.dx + size.width) / 2}, ${(offset.dy + size.height) / 2}');
}

void setOnlyPortraitScreen() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void setOnlyLandscapeScreen() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

void enableScreenRotation() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

typedef OnWidgetSizeChange = void Function(Size size);

class WidgetSizeRenderObject extends RenderProxyBox {
  final OnWidgetSizeChange onSizeChange;
  Size? currentSize;

  WidgetSizeRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    try {
      Size? newSize = child?.size;

      if (newSize != null && currentSize != newSize) {
        currentSize = newSize;
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          onSizeChange(newSize);
        });
      }
    } catch (e) {
      print(e);
    }
  }
}

class WidgetSizeOffsetWrapper extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChange;

  const WidgetSizeOffsetWrapper({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return WidgetSizeRenderObject(onSizeChange);
  }
}

class WidgetSizeAndPositionExample extends StatefulWidget {
  const WidgetSizeAndPositionExample({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WidgetSizeAndPositionExampleState();
  }
}

class _WidgetSizeAndPositionExampleState
    extends State<WidgetSizeAndPositionExample> {
  double _size = 300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Woolha.com Flutter Tutorial'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Center(
            // left: 50,
            // top: 100,
            child: WidgetSizeOffsetWrapper(
              onSizeChange: (Size size) {
                print('Size: ${size.width}, ${size.height}');
              },
              child: AnimatedContainer(
                duration: const Duration(seconds: 3),
                width: _size,
                height: _size,
                color: Colors.teal,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _size = _size == 300 ? 100 : 300;
                });
              },
              child: const Text('Change size'),
            ),
          ),
        ],
      ),
    );
  }
}

class RowIfPortraitElseCol extends StatelessWidget {
  List<Widget> children;
  bool isPortrait;

  RowIfPortraitElseCol(
      {super.key, required this.isPortrait, required this.children});

  @override
  Widget build(BuildContext context) {
    if (isPortrait) {
      return Row(children: children);
    }
    return Column(children: children);
  }
}

class ColumnIfPortraitElseRow extends StatelessWidget {
  List<Widget> children;
  bool isPortrait;

  ColumnIfPortraitElseRow({
    super.key,
    required this.isPortrait,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (isPortrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
