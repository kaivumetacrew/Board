import 'package:flutter/material.dart';

import '../util/asset.dart';
import '../util/color.dart';

class BackgroundPage extends StatefulWidget {
  BackgroundPage({super.key});

  @override
  State<BackgroundPage> createState() => _BackgroundPageState();
}

class _BackgroundPageState extends State<BackgroundPage> {
  List<String> imageList = [
    'board1.jpg',
    'board2.jpg',
    'board3.jpg',
    'sample.png',
  ];

  List<String> colorList = [
    '#FFCDD2',
    '#F8BBD0',
    '#E1BEE7',
    '#D1C4E9',
    '#C5CAE9',
    '#BBDEFB',
    '#B3E5FC',
    '#B2EBF2',
    '#B2DFDB',
    '#C8E6C9',
    '#DCEDC8',
    '#F0F4C3',
    '#FFF9C4',
    '#FFECB3',
    '#FFE0B2',
    '#FFCCBC',
    '#D7CCC8',
    '#F5F5F5',
    '#CFD8DC',
  ];
  late Widget listView;

  @override
  void initState() {
    listView = imageListWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Background")),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text('Image'),
                  onPressed: () {
                    setState(() {
                      listView = imageListWidget();
                    });
                  },
                ),
                TextButton(
                  child: Text('Color'),
                  onPressed: () {
                    setState(() {
                      listView = colorListWidget();
                    });
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: listView,
          ),
        ],
      ),
    );
  }

  Widget imageListWidget() {
    return backgroundListWidget(
      list: imageList,
      itemBuilder: (item) {
        return Image.asset(
          boardPath(item),
          fit: BoxFit.cover,
        );
      },
      onItemTap: (item) {
        Navigator.pop(context, {
          'image': item,
        });
      },
    );
  }

  Widget colorListWidget() {
    return backgroundListWidget(
      list: colorList,
      itemBuilder: (item) {
        return Container(color: fromHex(item));
      },
      onItemTap: (item) {
        Navigator.pop(context, {
          'color': item,
        });
      },
    );
  }

  Widget backgroundListWidget<T>({
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
      padding: const EdgeInsets.all(1),
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
