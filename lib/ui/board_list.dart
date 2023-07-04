import 'dart:io';

import 'package:board/ui/board/board_model.dart';
import 'package:board/util/state.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'board/board_page.dart';

class BoardListPage extends StatefulWidget {
  BoardListPage({super.key});

  @override
  State<BoardListPage> createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardListPage> {
  List<BoardData> boards = [];

  @override
  void initState() {
    super.initState();
    _getBoards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My boards')),
      body: Container(
        child: _boardList(),
      ),
    );
  }

  Widget _boardList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 4,
      ),
      shrinkWrap: false,
      padding: const EdgeInsets.all(4),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        BoardData item = boards[index];
        return GestureDetector(
          onTap: () {
            push(BoardPage(board: item));
          },
          onLongPress: () {
            _showItemDialog(item);
          },
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: SizedBox(
              width: double.infinity,
              child: _boardItem(item),
            ),
          ),
        );
      },
    );
  }

  Widget _boardItem(BoardData item) {
    Widget child;
    final thumb = item.thumbnail;
    if (thumb != null) {
      child = Image.file(
        File(thumb),
        fit: BoxFit.cover,
      );
    } else {
      child = const Center(
        child: Text(
          'could not load\nimage',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: child,
      ),
    );
  }

  Future _getBoards() async {
    editBoardsData((Box<BoardData> box) {
      setState(() {
        boards = box.values.toList();
      });
    });
  }

  Future<void> _showItemDialog(BoardData board) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text(board.name),
          actions: <Widget>[
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteBox(board).then((value) => Navigator.pop(context));
              },
            ),
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

  Future _deleteBox(BoardData board) async {
    editBoardsData((Box<BoardData> box) {
      box.delete(board.id.toString());
      setState(() {
        boards = box.values.toList();
      });
    });
  }

}
