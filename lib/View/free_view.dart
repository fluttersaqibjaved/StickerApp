import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';




class FreeView extends StatefulWidget {
  const FreeView({Key? key}) : super(key: key);

  @override
  _FreeViewState createState() => _FreeViewState();
}

class _FreeViewState extends State<FreeView> {
  List<Offset> _points = <Offset>[];
  GlobalKey _repaintKey = GlobalKey();

  Future<Uint8List?> _cropImage() async {
    try {
      RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error while cropping image: $e');
      return null;
    }
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _handlePanEnd(DragEndDetails details) async {
    Uint8List? imageBytes = await _cropImage();
    setState(() {
      _points.clear();
     
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: RepaintBoundary(
            key: _repaintKey,
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: Stack(
                children: <Widget>[
                 Image.asset(
            'assets/images/Image.png',
            fit: BoxFit.contain,
          ),
                  CustomPaint(
                    painter: TouchPainter(points: _points),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        _points.isEmpty
            ? Container()
            : Expanded(
                child: Image.memory(
                  Uint8List(0), 
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
      ],
    );
  }
}

class TouchPainter extends CustomPainter {
  final List<Offset> points;

  TouchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
