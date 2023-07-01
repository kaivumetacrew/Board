import 'package:flutter/material.dart';

class ActionBarController extends ValueNotifier<ActionItem> {
  ActionBarController() : super(ActionItem.none);
}

class ActionBar extends StatefulWidget {
  ActionBar({super.key});

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  ActionItem _selectedAction = ActionItem.none;

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }

  ///
  Widget _actionBar() {
    return Container(
      color: Colors.white,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /*_actionButton(ActionItem.textItem, (isSelected) {
            _pickText(BoardItem.none);
          }),
          _actionButton(ActionItem.imageItem, (isSelected) {
            _pickGalleryImage();
          }),
          _actionButton(ActionItem.stickerItem, (isSelected) {
            _pickStickerImage();
          }),
          _actionButton(ActionItem.drawItem, (isSelected) {
            if (isSelected) {
              boardController.deselectItem();
              boardController.startDraw();
            } else {
              boardController.stopDraw();
            }
          })*/
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
            style: TextStyle(
              color: iconColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void selectAction(ActionItem actionItem) {
    setState(() {
      _selectedAction = actionItem;
    });
  }
}

class ActionItem {
  int id;
  IconData icon;
  String text;
  bool selectable = false;

  ActionItem(this.id, this.icon, this.text, {this.selectable = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static ActionItem none = ActionItem(-1, Icons.abc, 'none');

  static ActionItem textItem = ActionItem(1, Icons.abc, 'text');

  static ActionItem imageItem = ActionItem(2, Icons.image, 'image');

  static ActionItem stickerItem =
      ActionItem(3, Icons.emoji_emotions, 'sticker');

  static ActionItem drawItem =
      ActionItem(4, Icons.draw, 'draw', selectable: true);
}
