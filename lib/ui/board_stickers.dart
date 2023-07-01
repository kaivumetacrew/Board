import 'package:flutter/material.dart';

import '../util/asset.dart';

class StickerPage extends StatefulWidget {
  StickerPage({super.key});

  @override
  State<StickerPage> createState() => _StickerPageState();
}

class _StickerPageState extends State<StickerPage> {
  List<String> stickerList = [
    '01.png',
    '03.png',
    '07.png',
    '10.png',
    '13.png',
    '16.png',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sticker")),
      body: Column(
        children: [
          Expanded(
            child: stickerListWidget(),
          ),
        ],
      ),
    );
  }

  Widget stickerListWidget() {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      shrinkWrap: false,
      padding: const EdgeInsets.all(1),
      itemCount: stickerList.length,
      itemBuilder: (context, index) {
        var item = stickerList[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              Navigator.pop(context, {
                'sticker': item,
              });
            });
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Image.asset(stickerPath(item)),
            ),
          ),
        );
      },
    );
  }
}
