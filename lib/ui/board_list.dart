import 'dart:io';

import 'package:board/main.dart';
import 'package:flutter/material.dart';

class BoardListPage extends StatefulWidget {
  BoardListPage({super.key});

  @override
  State<BoardListPage> createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Background")),
      body: Container(
        child: listBuilder(
          list: myBoards,
          itemBuilder: (item) {
            Widget child;
            var thumb = item.thumbnail;
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
          },
          onItemTap: (item) {},
        ),
      ),
    );
  }

  Widget listBuilder<T>({
    required List<T> list,
    required Widget Function(T) itemBuilder,
    required Function(T) onItemTap,
  }) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3 / 4,
      ),
      shrinkWrap: false,
      padding: const EdgeInsets.all(4),
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return GestureDetector(
          onTap: () {
            onItemTap(item);
          },
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: SizedBox(
              width: double.infinity,
              child: itemBuilder(item),
            ),
          ),
        );
      },
    );
  }
}
