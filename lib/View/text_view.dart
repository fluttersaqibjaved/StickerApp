import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
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
late Color _textBackgroundColor;
  @override
  void initState() {
    super.initState();
    _initializeValues();
     _textBackgroundColor = Colors.transparent;
  }

  void _initializeValues() {
    _userText = 'Customizable Text';
    _textColor = Colors.black;
    _textSize = 16.0;
    _textWeight = FontWeight.normal;
    _textStyle = FontStyle.normal;
  }

   Future<File> _resizeImage(File imageFile) async {
    img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
    const int maxSizeBytes = 100 * 1024;
    const int targetWidth = 512;
    const int targetHeight = 512;

    int quality = 90;
    File resizedFile;

    do {
      img.Image resizedImage =
          img.copyResize(image, width: targetWidth, height: targetHeight);

      List<int> resizedImageBytes = img.encodePng(resizedImage);
      Uint8List resizedUint8List = Uint8List.fromList(resizedImageBytes);
      final compressedImage = await FlutterImageCompress.compressWithList(
        resizedUint8List,
        minHeight: targetHeight,
        minWidth: targetWidth,
        quality: quality,
        format: CompressFormat.webp,
      );

      resizedFile = File(imageFile.path.replaceAll(
          RegExp(r'\.(?:jpg|webp|png|gif)', caseSensitive: false),
          '_resized.webp'));
      await resizedFile.writeAsBytes(compressedImage);

      quality -= 5;
    } while (resizedFile.lengthSync() > maxSizeBytes && quality > 0);

    return resizedFile;
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

        File resizedImage = await _resizeImage(tempFile);
        await _saveImageToGallery(resizedImage);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
  color: Colors.red,
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RepaintBoundary(
          
          child: GestureDetector(
            onTap: () {
              setState(() {
               
              });
            },
            
            child: Stack(
              children: [
                
              ],
            ),
          ),
        ),
      
      ],
    ),
  ),
),

              Text(
              'Write Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              width: 90.w,
              height: 10.h,
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
              width: 90.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: _textBackgroundColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green, width: 2),
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
             TextButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = _textColor;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.color_lens, 
                    color: Colors.green, 
                  ),
                  SizedBox(width: 10), 
                  Text('Colors'),
                ],
              ),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  showLabel: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK', style: TextStyle(color: Colors.green)),
                  onPressed: () {
                    setState(() {
                      _textColor = selectedColor;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  },
  child: Column(
    children: [
      Icon(
        Icons.color_lens, 
        color: Colors.green, 
      ),
      SizedBox(width: 10),
      Text('Color', style: TextStyle(color: Colors.green)),
    ],
  ),
),


                 TextButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double selectedSize = _textSize;

        return AlertDialog(
          title: Text('Choose Text Size'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: selectedSize,
                  min: 1,
                  max: 200,
                  divisions: 199,
                  label: selectedSize.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      selectedSize = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.green)),
              onPressed: () {
                setState(() {
                  _textSize = selectedSize;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  },
  child:  Column(
    children: [
      Icon(
        Icons.photo_size_select_actual, 
        color: Colors.green, 
      ),
      SizedBox(width: 10),
      Text('Size', style: TextStyle(color: Colors.green)),
    ],
  ),
),

                TextButton(
  onPressed: () {
    setState(() {
      _textWeight = (_textWeight == FontWeight.bold)
          ? FontWeight.normal
          : FontWeight.bold;
    });
  },
  child: Column(
    children: [
   
      Icon(
        Icons.star, 
        color: Colors.green, 
        size: 24, 
      ),
         Text(
        _textWeight == FontWeight.bold ? 'Unbold' : 'Bold',
        style: TextStyle(
          color: Colors.green,
          fontWeight: _textWeight,
        ),
      ),
    ],
  ),
),

                TextButton(
  onPressed: () {
    setState(() {
      _textStyle = (_textStyle == FontStyle.italic)
          ? FontStyle.normal
          : FontStyle.italic;
    });
  },
  child: Column(
    children: [
    
      Icon(
        Icons.star, 
        color: Colors.green, 
        size: 24, 
      ),
        Text(
        _textStyle == FontStyle.italic ? 'Normal' : 'Italic',
        style: TextStyle(
          color: Colors.green,
          fontStyle: _textStyle,
        ),
      ),
    ],
  ),
),
             TextButton(
              onPressed: () async {
                Color? selectedBackgroundColor = await showDialog<Color>(
                  context: context,
                  builder: (BuildContext context) {
                    Color selectedColor = _textBackgroundColor;

                    return AlertDialog(
                      title: Text('Select Text Background Color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (Color color) {
                            selectedColor = color;
                          },
                          showLabel: true,
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK', style: TextStyle(color: Colors.green)),
                          onPressed: () {
                            Navigator.of(context).pop(selectedColor);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (selectedBackgroundColor != null) {
                  setState(() {
                    _textBackgroundColor = selectedBackgroundColor;
                  });
                }
              },
              child: Column(
                children: [
                  Icon(
                    Icons.remove_circle_outline_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                  Text('BG', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),


                ],
              ),
              ],
            ),
        ),
    );
  }
}
