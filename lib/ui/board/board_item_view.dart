import 'dart:io';

import 'package:flutter/material.dart';

import '../../util/asset.dart';
import 'board_draw.dart';
import 'board_model.dart';

class BoardItemView extends StatelessWidget {
  BoardItem item;
  bool isSelected;
  Function(BoardItem) onTap;

  BoardItemView({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item.isTextItem) {
      return isSelected ? _animatedText : _positionedText;
    }
    if (item.isImageItem || item.isStickerItem) {
      return isSelected ? _animatedImage : _positionedImage;
    }
    if (item.isDrawItem) {
      return _drawWidget;
    }
    return _errorImage();
  }

  /// Space between selected item widget and border
  EdgeInsets get _boardItemMargin => const EdgeInsets.all(2.0);

  /// Border of selected item
  Widget get _boardItemBorder => Positioned(
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5)),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 0.5)),
          ),
        ),
      );

  Widget _positionedItem(Widget itemWidget) {
    return Transform(
      transform: item.matrix,
      child: Container(
        margin: _boardItemMargin,
        child: Container(
          child: itemWidget,
        ),
      ),
    );
  }

  Widget _animatedItem(Widget itemWidget) {
    return AnimatedBuilder(
      animation: item.matrixNotifier,
      builder: (ctx, child) {
        return Transform(
          transform: item.matrix,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _boardItemBorder,
              Container(
                margin: _boardItemMargin,
                child: Container(child: itemWidget),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _text() {
    var textWidget = Text(
      item.text!,
      style: TextStyle(
        fontFamily: item.font,
        color: item.uiColor,
        fontSize: 24,
      ),
    );
    return GestureDetector(
      child: textWidget,
      onTap: () {
        onTap(item);
      },
    );
  }

  Widget get _positionedText => _positionedItem(_text());

  Widget get _animatedText => _animatedItem(_text());

  Widget _errorImage({String message = 'item error'}) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
      child: Center(
        widthFactor: double.infinity,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 8, color: Colors.white),
        ),
      ),
    );
  }

  Widget _image(BoardItem item) {
    Widget imageWidget;
    if (item.isImageItem) {
      imageWidget = Image.file(File(item.imagePath!), errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return _errorImage(message: 'This image error');
      });
    } else if (item.isStickerItem) {
      imageWidget = Image.asset(stickerPath(item.sticker!), errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return _errorImage(message: 'This image error');
      });
    } else {
      return _errorImage();
    }
    return GestureDetector(
      child: imageWidget,
      onTap: () {
        onTap(item);
      },
    );
  }

  Widget get _positionedImage => _positionedItem(_image(item));

  Widget get _animatedImage => _animatedItem(_image(item));

  Widget get _drawWidget => Container(
        color: const Color.fromARGB(100, 163, 93, 65),
        child: CustomPaint(
          painter: PointPainter(
              points: item.drawPoints ?? [],
              strokeColor: item.uiDrawColor,
              strokeWidth: item.drawWidth,
              strokeCap: item.strokeCap,
              strokeJoin: item.strokeJoin),
        ),
      );
}
