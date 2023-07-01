import 'package:flutter/material.dart';

class ActionBarController extends ValueNotifier<ActionItem> {
  List<ActionItem> items = [
    ActionItem.textItem,
    ActionItem.imageItem,
    ActionItem.stickerItem,
    ActionItem.drawItem
  ];

  ActionBarController() : super(ActionItem.none);

  void selectAction(ActionItem actionItem) {
    value = actionItem;
    notifyListeners();
  }
}

class ActionBar extends StatefulWidget {
  ActionBarController controller;

  Function(ActionItem item, bool isSelected) onItemTap;

  ActionBar({super.key, required this.controller, required this.onItemTap});

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  ActionItem get selectedAction => widget.controller.value;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (ActionItem e in widget.controller.items) {
      e.id = widgets.length + 1;
      widgets.add(_actionButton(e));
    }
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (
        BuildContext context,
        ActionItem value,
        Widget? child,
      ) {
        return Container(
          color: Colors.white,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widgets,
          ),
        );
      },
    );
  }

  Widget _actionButton(ActionItem item) {
    Color iconColor =
        (item.selectable && selectedAction == item) ? Colors.blue : Colors.grey;
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
                  widget.controller.value = ActionItem.none;
                  widget.onItemTap(item, false);
                  return;
                }
                if (selectedAction != item) {
                  widget.controller.value = item;
                  widget.onItemTap(item, true);
                  return;
                }
                widget.controller.value = ActionItem.none;
                widget.onItemTap(item, false);
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
}

class ActionItem {
  int id = -1;
  IconData icon;
  String text;
  bool selectable = false;

  ActionItem(this.icon, this.text, {this.id = -1, this.selectable = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static ActionItem none = ActionItem(Icons.abc, 'none');

  static ActionItem textItem = ActionItem(Icons.abc, 'text');

  static ActionItem imageItem = ActionItem(Icons.image, 'image');

  static ActionItem stickerItem = ActionItem(Icons.emoji_emotions, 'sticker');

  static ActionItem drawItem = ActionItem(Icons.draw, 'draw', selectable: true);
}
