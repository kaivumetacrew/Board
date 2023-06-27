// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const customSwatch = MaterialColor(
    0xFFFF5252,
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFFF5252),
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFC62828),
      900: Color(0xFFB71C1C),
    },
  );

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: customSwatch,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int currentIndex = 0;
  // PageController pageController = PageController();

  List<GalleryExampleItem> galleryItems = <GalleryExampleItem>[
    GalleryExampleItem(id: "tag1", image: "assets/images/galaxy.jpg",),
    GalleryExampleItem(id: "tag2", image: "assets/images/galaxy2.jpg",),
    GalleryExampleItem(id: "tag3", image: "assets/images/galaxy3.jpg",),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo View"),
      ),
      /// UNCOMMENT THIS IF YOU ONLY WANT TO USE THE PHOTOVIEW
      /// for simple photoview for zooming in & out
      // body: PhotoView(
      //   imageProvider: AssetImage("assets/galaxy.jpeg"), /// or use: NetworkImage()
      //   enableRotation: true,
      // ),

      /// COMMENT THIS IF YOU ONLY WANT TO USE THE PHOTOVIEW
      /// photo_view gallery
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(galleryItems[index].image), /// or NetworkImage()
            initialScale: PhotoViewComputedScale.contained * 0.8,
            heroAttributes: PhotoViewHeroAttributes(tag: galleryItems[index].id),
          );
        },
        itemCount: galleryItems.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event==null? 0 : event.cumulativeBytesLoaded/event.expectedTotalBytes!,
            ),
          ),
        ),
        // pageController: pageController,
        // onPageChanged: onPageChanged,
      ),
    );
  }

  // void onPageChanged(int index) {
  //   setState(() {
  //     currentIndex = index;
  //   });
  // }

}

class GalleryExampleItem {
  final String id;
  final String image;

  GalleryExampleItem({
    required this.id,
    required this.image,
  });
}
