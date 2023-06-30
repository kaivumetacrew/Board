import 'package:flutter/material.dart';

import '../util/asset.dart';

class BackgroundPage extends StatefulWidget {
  BackgroundPage({super.key});

  @override
  State<BackgroundPage> createState() => _BackgroundPageState();
}

class _BackgroundPageState extends State<BackgroundPage> {

  List<String> boardList = [
    'board1.jpg',
    'board2.jpg',
    'board3.jpg',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Background")),
      body: Column(
        children: [
          Expanded(child: stickerListWidget(),),
        ],
      ),
    );
  }

  Widget stickerListWidget() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      shrinkWrap: false,
      padding: const EdgeInsets.all(1),
      itemCount: boardList.length,
      itemBuilder: (context, index) {
        var item = boardList[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              Navigator.pop(context, {
                'image': item,
              });
            });
          },
          child: AspectRatio(
            aspectRatio: 3/4,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Image.asset(boardPath(item), fit: BoxFit.cover,),
            ),
          ),
        );
      },
    );
  }
}