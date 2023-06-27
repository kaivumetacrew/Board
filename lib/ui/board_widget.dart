import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size oldSize = Size.zero;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject({required this.onChange});

  @override
  void performLayout() {
    super.performLayout();

    Size? newSize = child?.size;
    if (newSize == null ||
        newSize.width == 0 ||
        newSize.height == 0 ||
        oldSize == newSize) {
      return;
    }
    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange: (Size size) {});
  }
}

class FocalPointPainter extends CustomPainter {
  Animation<Alignment>? focalPointAnimation;
  Path? cross;
  late Paint foregroundPaint;

  FocalPointPainter(this.focalPointAnimation)
      : super(repaint: focalPointAnimation) {
    foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (cross == null) {
      initCross(size);
    }
    Offset translation = focalPointAnimation!.value.alongSize(size);
    canvas.translate(translation.dx, translation.dy);
    canvas.drawPath(cross!, foregroundPaint);
  }

  @override
  bool hitTest(Offset position) => true;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void initCross(Size size) {
    var s = size.shortestSide / 8;
    cross = Path()
      ..moveTo(-s, 0)
      ..relativeLineTo(s * 0.75, 0)
      ..moveTo(s, 0)
      ..relativeLineTo(-s * 0.75, 0)
      ..moveTo(0, s)
      ..relativeLineTo(0, -s * 0.75)
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: s * 0.85));
  }
}


