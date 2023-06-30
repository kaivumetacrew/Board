import 'package:auto_size_text/auto_size_text.dart';
import 'package:board/ui/widget/textfield.dart';
import 'package:flutter/material.dart';

import '../util/asset.dart';

class StickerPage extends StatefulWidget {
  StickerPage({super.key});

  @override
  State<StickerPage> createState() => _StickerPageState();
}

class _StickerPageState extends State<StickerPage> {

  List<String> stickerList = ['','',''];


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Text")),
      body: Column(
        children: [
          Expanded(child: stickerListWidget(),),
        ],
      ),
    );
  }

  Widget stickerListWidget() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      shrinkWrap: false,
      padding: const EdgeInsets.only(left: 0, right: 0),

      itemCount: stickerList.length,
      itemBuilder: (context, index) {
        var item = stickerList[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              Navigator.pop(context, {
                'text': '',
              });
            });
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(stickerPath('01.png')),
          ),
        );
      },
    );
  }
}