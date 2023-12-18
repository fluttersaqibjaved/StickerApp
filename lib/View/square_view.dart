import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;





class SquareView extends StatefulWidget {
  final File imageFile;

  const SquareView({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<SquareView> createState() => _SquareViewState();
}

class _SquareViewState extends State<SquareView> {
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
      appBar: AppBar(
        title: Text('Image Cropping'),
      ),
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
                  Image.asset(
                    'assets/images/Image.png',
                    fit: BoxFit.contain,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_startCrop != null && _endCrop != null) {
            _cropImage();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select an area to crop.'),
              ),
            );
          }
        },
        child: Icon(Icons.crop),
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
