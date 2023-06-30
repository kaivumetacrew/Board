import 'package:board/ui/board/board_state.dart';
import 'package:flutter/material.dart';

import '../../res/color.dart';
import 'board_model.dart';

class BoardPage2 extends StatefulWidget {
  BoardPage2({super.key});

  @override
  State<BoardPage2> createState() => _BoardPage2State();
}

class _BoardPage2State extends State<BoardPage2> with TickerProviderStateMixin {
  BoardController boardController = BoardController();
  ActionItem _selectedAction = ActionItem.none;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Board")),
      body: SafeArea(
        child: Column(
          children: [
            BoardView(controller: boardController),
            Container(width: double.infinity, height: 1, color: Colors.grey),
            Expanded(
              child: Column(
                children: [],
              ),
            ),
            Container(width: double.infinity, height: 1, color: Colors.grey),
            _actionBar()
          ],
        ),
      ),
    );
  }

  Widget _actionBar() {
    return Container(
      color: Colors.white,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionButton(ActionItem.textItem, (isSelected) async {
            //_pickText(BoardItem.none);
          }),
          _actionButton(ActionItem.imageItem, (isSelected) {
            //_pickImage();
          }),
          _actionButton(ActionItem.stickerItem, (isSelected) {
            //_pickSticker();
          }),
          _actionButton(ActionItem.drawItem, (isSelected) {
            if (isSelected) {
              //_selectedItem = BoardItem.none;
              //_syncMapWidget();
            }
          })
        ],
      ),
    );
  }

  Widget _actionButton(
      ActionItem item,
      Function(bool isSelected) callback,
      ) {
    Color iconColor = (item.selectable && _selectedAction == item)
        ? Colors.blue
        : Colors.grey;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            icon: Icon(item.icon),
            color: iconColor,
            onPressed: () {
              setState(() {
                if (!item.selectable) {
                  _selectedAction = ActionItem.none;
                  callback(false);
                  return;
                }
                if (_selectedAction != item) {
                  _selectedAction = item;
                  callback(true);
                  return;
                }
                _selectedAction = ActionItem.none;
                callback(false);
              });
            },
          ),
          Text(
            item.text,
            style:  TextStyle(
              color: iconColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}
