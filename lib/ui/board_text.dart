import 'package:auto_size_text/auto_size_text.dart';
import 'package:board/ui/widget/textfield.dart';
import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  TextPage({super.key, this.text, this.font = ''});

  String? text;
  String font = '';

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final ScrollController fontListScrollCtrl = ScrollController();
  String? itemText;
  List<String> fontList = [
    'BabasNeue',
    'Fasthand',
    'Inter',
    'Lobster',
    'Montserrat',
    'NunitoSans',
    'Pacifico',
    'PlayfairDisplay',
    'Roboto',
  ];
  String? _selectedFont;

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.font;
    if (_selectedFont?.isEmpty ?? true) {
      _selectedFont = fontList.first;
    }
    _textController.text = widget.text ?? '';
    syncText(widget.text ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset :false,
      appBar: AppBar(title: const Text("Text")),
      body: Center(
        child: Column(
          children: <Widget>[
            textField(),
            Expanded(
              child: fontListWidget(),
            ),
            addButton(),
          ],
        ),
      ),
    );
  }

  void syncText(String text) {
    if (text == null || text.isEmpty) {
      itemText =
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris id vehicula ligula. Donec non est non nibh varius vestibulum.';
    } else if (text.length >= 80) {
      itemText = text.substring(0, 80);
    } else {
      itemText = text;
    }
  }

  Widget textField() {
    return TextFieldOutline(
      controller: _textController,
      focusNode: _textFocusNode,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: "Type text here",
      height: 100,
      maxLength: 1000,
      maxLines: 50,
      onChange: (text) {
        setState(() {
          syncText(text);
        });
      },
    );
  }

  Widget addButton() {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: 50,
        color: Theme.of(context).colorScheme.primary,
        child: const Center(
            child: Text('Add', style: TextStyle(color: Colors.white))),
      ),
      onTap: () {
        if (_textController.text.isEmpty) {
          return;
        }
        Navigator.pop(context, {
          'text': _textController.text,
          'font': _selectedFont,
        });
      },
    );
  }

  Widget fontListWidget() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      controller: fontListScrollCtrl,
      shrinkWrap: false,
      padding: const EdgeInsets.only(left: 0, right: 0),
      itemCount: fontList.length,
      itemBuilder: (context, index) {
        final item = fontList[index];
        final checkIcon = item == _selectedFont
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : const SizedBox();

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFont = item;
            });
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      checkIcon
                    ],
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: AutoSizeText(
                        itemText ?? '',
                        style: TextStyle(
                          fontFamily: fontList[index],
                          fontSize: 20,
                        ),
                        minFontSize: 8,
                        maxFontSize: 20,
                        maxLines: 10,
                      ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Future<List<String>> getFontData() async {
//   final manifestContent = await rootBundle.loadString('AssetManifest.json');
//
//   final Map<String, dynamic> manifestMap = json.decode(manifestContent);
//   // >> To get paths you need these 2 lines
//
//   var list = manifestMap.keys
//       .where((String key) => key.contains('fonts/'))
//       .where((String key) => key.contains('.ttf'))
//       .toList();
//
//   return list;
// }
}
