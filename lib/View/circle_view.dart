import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circular Crop Example',
      home: CircularCropScreen(),
    );
  }
}

class CircularCropScreen extends StatefulWidget {
  @override
  _CircularCropScreenState createState() => _CircularCropScreenState();
}

class _CircularCropScreenState extends State<CircularCropScreen> {
  ui.Image? _image;
  Uint8List? _croppedImageBytes;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    ByteData data = await rootBundle.load('assets/sample_image.jpg');
    Uint8List bytes = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (img) {
      setState(() {
        _image = img;
      });
      completer.complete(img);
    });
    await completer.future;
  }

  Future<Uint8List?> _cropImage() async {
    if (_image != null) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;
      final rect = Rect.fromCircle(center: Offset(150, 150), radius: 150);

      canvas.clipPath(Path()..addOval(rect));
      canvas.drawImage(_image!, Offset.zero, paint);

      final picture = recorder.endRecording();
      final img = await picture.toImage(300, 300);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Circular Crop'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? Container(
                    width: 300,
                    height: 300,
                    child: ClipOval(
                      child:  Image.asset(
            'assets/images/Image.png',
            fit: BoxFit.contain,
          ),
                    ),
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Uint8List? croppedImage = await _cropImage();
                setState(() {
                  _croppedImageBytes = croppedImage;
                });
              },
              child: Text('Crop Image'),
            ),
            SizedBox(height: 20),
            _croppedImageBytes != null
                ? ClipOval(
                    child: Image.memory(
                      _croppedImageBytes!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      key: UniqueKey(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
