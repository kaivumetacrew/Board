import 'package:board/ui/board/board_model.dart';
import 'package:flutter/material.dart';

class ActionBarController extends ValueNotifier<ActionItem> {
  List<ActionItem> items = [
    ActionItem.textItem,
    ActionItem.imageItem,
    ActionItem.stickerItem,
    ActionItem.drawItem
  ];

  ActionBarController(ActionItem item) : super(item);

  void selectAction(ActionItem actionItem) {
    value = actionItem;
    notifyListeners();
  }
}

class ActionBar extends StatefulWidget {
  ActionBarController controller;
  Axis axis;
  bool textVisible;
  bool iconVisible;
  Function(ActionItem item, bool isSelected) onItemTap;

  ActionBar({
    super.key,
    this.axis = Axis.horizontal,
    this.textVisible = true,
    this.iconVisible = true,
    required this.controller,
    required this.onItemTap,
  });

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
    double size = 70;
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (
        BuildContext context,
        ActionItem value,
        Widget? child,
      ) {
        return Container(
          color: Colors.white,
          width: widget.axis == Axis.horizontal ? double.infinity : size,
          height: widget.axis == Axis.horizontal ? size : double.infinity,
          child: _buttonContainer(widgets),
        );
      },
    );
  }

  Widget _buttonContainer(List<Widget> children) {
    if (widget.axis == Axis.horizontal) {
      return Row(children: children);
    }
    return Column(children: children);
  }

  Widget _actionButton(ActionItem item) {
    Color iconColor =
        (item.selectable && selectedAction == item) ? Colors.blue : Colors.grey;
    List<Widget> components = [];
    if (widget.iconVisible) {
      components.add(IconButton(
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
      ));
    }
    if (widget.textVisible) {
      components.add(Text(
        item.text,
        style: TextStyle(
          color: iconColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ));
    }
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: components,
      ),
    );
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
      identical(this, other) || other is ActionItem && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static ActionItem none = ActionItem(-1, Icons.abc, 'none');

  static ActionItem textItem = ActionItem(1, Icons.abc, 'text');

  static ActionItem imageItem = ActionItem(2, Icons.image, 'image');

  static ActionItem stickerItem =
      ActionItem(3, Icons.emoji_emotions, 'sticker');

  static ActionItem drawItem =
      ActionItem(3, Icons.draw, 'draw', selectable: true);

  static ActionItem mapFormBoardItem(BoardItem item) {
    if (item.isTextItem) {
      return ActionItem.textItem;
    }
    if (item.isImageItem) {
      return (ActionItem.imageItem);
    }
    if (item.isStickerItem) {
      return (ActionItem.stickerItem);
    }
    if (item.isDrawItem) {
      return (ActionItem.drawItem);
    }
    return ActionItem.none;
  }
}
