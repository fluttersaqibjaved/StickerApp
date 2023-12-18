import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: TextView(),
  ));
}

class TextView extends StatefulWidget {
  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  late String _userText;
  late Color _textColor;
  late double _textSize;
  late FontWeight _textWeight;
  late FontStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    _userText = 'Customizable Text';
    _textColor = Colors.black;
    _textSize = 16.0;
    _textWeight = FontWeight.normal;
    _textStyle = FontStyle.normal;
  }

  Future<void> _saveAsImage() async {
    try {
      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(recorder);

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: _userText,
          style: GoogleFonts.getFont(
            'Open Sans',
            textStyle: TextStyle(
              color: _textColor,
              fontSize: _textSize,
              fontWeight: _textWeight,
              fontStyle: _textStyle,
            ),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset.zero);

      ui.Image img = await recorder.endRecording().toImage(
        textPainter.width.toInt(),
        textPainter.height.toInt(),
      );
      ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      Uint8List textImageBytes = byteData!.buffer.asUint8List();

      if (textImageBytes.isNotEmpty) {
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;

        File tempFile = File('$tempPath/temp_text_image.png');
        await tempFile.writeAsBytes(textImageBytes);

        await _saveImageToGallery(tempFile);
      } else {
        _showSnackBar('Failed to capture text image');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _saveImageToGallery(File imageFile) async {
    try {
      final result = await GallerySaver.saveImage(imageFile.path);
      if (result != null) {
        _showSnackBar('Image saved to gallery');
      } else {
        _showSnackBar('Failed to save image');
      }
    } catch (e) {
      _showSnackBar('Error saving image: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Edit Text',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () {
              _saveAsImage();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLength: 101,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write something...',
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.getFont(
                    'Open Sans',
                    textStyle: TextStyle(
                      color: _textColor,
                      fontSize: _textSize,
                      fontWeight: _textWeight,
                      fontStyle: _textStyle,
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _userText = text;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Preview:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              width: 250,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: Text(
                  _userText,
                  style: GoogleFonts.getFont(
                    'Open Sans',
                    textStyle: TextStyle(
                      color: _textColor,
                      fontSize: _textSize,
                      fontWeight: _textWeight,
                      fontStyle: _textStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  final colors = [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.pink,
                    Colors.yellow,
                    Colors.brown,
                    Colors.grey,
                    Colors.black,
                  ];
                  _textColor = colors[DateTime.now().millisecondsSinceEpoch %
                      colors.length];
                });
              },
              child: Text('Color'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _textSize = (_textSize == 20.0) ? 16.0 : 20.0;
                });
              },
              child: Text(_textSize == 20.0 ? 'Size' : 'Size'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _textWeight =
                      (_textWeight == FontWeight.bold) ? FontWeight.normal : FontWeight.bold;
                });
              },
              child: Text(_textWeight == FontWeight.bold ? 'Unbold' : 'Bold'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _textStyle = (_textStyle == FontStyle.italic)
                      ? FontStyle.normal
                      : FontStyle.italic;
                });
              },
              child: Text(_textStyle == FontStyle.italic ? 'Normal' : 'Italic'),
            ),
          ],
        ),
      ),
    );
  }
}
