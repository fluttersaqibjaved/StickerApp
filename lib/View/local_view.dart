import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class LocalView extends StatefulWidget {
  @override
  _LocalViewState createState() => _LocalViewState();
}

class _LocalViewState extends State<LocalView> {
  // List of colors for text
  List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  Color _textColor = Colors.black;
  double _textSize = 16.0;
  FontWeight _textWeight = FontWeight.normal;
  FontStyle _textStyle = FontStyle.normal;
  double _zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Customization'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: _zoomLevel,
              child: Text(
                'Customizable Text',
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Change text color randomly from the list
                  final random = Random();
                  _textColor = _availableColors[random.nextInt(_availableColors.length)];
                });
              },
              child: Text('Change Color'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _textSize = 20.0;
                });
              },
              child: Text('Increase Size'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _textWeight = FontWeight.bold;
                });
              },
              child: Text('Bold Text'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _textStyle = FontStyle.italic;
                });
              },
              child: Text('Italic Text'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _zoomLevel = 1.5;
                });
              },
              child: Text('Zoom In'),
            ),
          ],
        ),
      ),
    );
  }
}
