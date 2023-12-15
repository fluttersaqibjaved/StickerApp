import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class NewView extends StatefulWidget {
  final File imageFile;

  const NewView({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<NewView> createState() => _NewViewState();
}

class _NewViewState extends State<NewView> {
  late File imageFile;
  Offset? _startCrop;
  Offset? _endCrop;

  @override
  void initState() {
    super.initState();
    imageFile = widget.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:null,
      body: Center(
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              _startCrop = details.localPosition;
              _endCrop = details.localPosition;
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _endCrop = details.localPosition;
            });
          },
          onPanEnd: (details) {
            setState(() {
              _startCrop = null;
              _endCrop = null;
            });
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                if (_startCrop != null && _endCrop != null)
                  Positioned.fromRect(
                    rect: _getCropRect(),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Rect _getCropRect() {
    double left = _startCrop!.dx < _endCrop!.dx ? _startCrop!.dx : _endCrop!.dx;
    double top = _startCrop!.dy < _endCrop!.dy ? _startCrop!.dy : _endCrop!.dy;
    double width = (_startCrop!.dx - _endCrop!.dx).abs();
    double height = (_startCrop!.dy - _endCrop!.dy).abs();
    return Rect.fromLTWH(left, top, width, height);
  }

  Future<void> _cropImage() async {
    Rect cropRect = _getCropRect();
    final image = img.decodeImage(await imageFile.readAsBytes())!;
    img.Image croppedImage = img.copyCrop(
      image,
      cropRect.left.toInt(),
      cropRect.top.toInt(),
      cropRect.width.toInt(),
      cropRect.height.toInt(),
    );

    final Directory extDir = Directory('/storage/emulated/0/YourDirectory');
    final String imagePath = '${extDir.path}/cropped_image.png';
    File(imagePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(img.encodePng(croppedImage));

    print('Cropped image saved at: $imagePath');
  }
}
