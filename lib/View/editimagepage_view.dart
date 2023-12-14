import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class EditImagePage extends StatefulWidget {
  final File imageFile;

  const EditImagePage({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  late File imageFile;
  TextEditingController _textEditingController = TextEditingController();
  String _displayedText = "Your text here";
  double _angle = 0;
 Offset _textPosition = Offset(50, 50);
  Offset _startPosition = Offset.zero; 
  @override
  void initState() {
    super.initState();
    imageFile = widget.imageFile;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
    );

    if (croppedFile != null) {
      setState(() {
        imageFile = File(croppedFile.path);
      });
    }
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: [
                Container(
                  child: AspectRatio(
                    aspectRatio: 400 / 400,
                    child: Transform.rotate(
                      angle: _angle,
                      child: Container(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1),
                          child: Image.file(imageFile, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ),
                 Positioned(
  left: _textPosition.dx,
  top: _textPosition.dy,
  child: GestureDetector(
    onTapDown: (details) {
      _startPosition = details.localPosition - _textPosition;
    },
    onPanUpdate: (details) {
      setState(() {
        _textPosition = details.localPosition - _startPosition;
      });
    },
    child: Container(
      width: 200,
      height: 50,
      color: _displayedText.isEmpty ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0),
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: _textEditingController,
        style: TextStyle(
          color: Colors.red, 
          fontSize: 20, 
          fontStyle: FontStyle.normal, 
          fontWeight: FontWeight.normal, 
        ),
        decoration: InputDecoration(
          hintText: 'Your text here',
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            _displayedText = value;
          });
        },
      ),
    ),
  ),
),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _angle += 45 * (3.1415926535 / 180);
                          });
                        },
                        child: Text('Rotate'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _cropImage();
                        },
                        child: Text('Select All'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                         
                        },
                        child: Text('Background Remove'),
                      ),
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
