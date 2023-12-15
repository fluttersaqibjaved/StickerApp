import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class TextView extends StatefulWidget {
  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  
  late SharedPreferences _prefs;
  late String _userText;
  late List<Color> _availableColors;
  late Color _textColor;
  late double _textSize;
  late FontWeight _textWeight;
  late FontStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _loadPreferences();
  }

  void _initializeValues() {
    _userText = 'Customizable Text';
    _availableColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.transparent,
      Colors.pink,
      Colors.yellow,
      Colors.white,
      Colors.brown,
      Colors.grey,
      Colors.black,
    ];
    _textColor = Colors.black;
    _textSize = 16.0;
    _textWeight = FontWeight.normal;
    _textStyle = FontStyle.normal;
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userText = _prefs.getString('user_text') ?? 'Customizable Text';
      _textColor =
          _getColorFromInt(_prefs.getInt('text_color') ?? Colors.black.value);
      _textSize = _prefs.getDouble('text_size') ?? 16.0;
      _textWeight = _prefs.getString('text_weight') == 'bold'
          ? FontWeight.bold
          : FontWeight.normal;
      _textStyle = _prefs.getString('text_style') == 'italic'
          ? FontStyle.italic
          : FontStyle.normal;
    });
  }

  void _savePreferences() {
    _prefs.setString('user_text', _userText);
    _prefs.setInt('text_color', _textColor.value);
    _prefs.setDouble('text_size', _textSize);
    _prefs.setString('text_weight', _textWeight == FontWeight.bold ? 'bold' : 'normal');
    _prefs.setString('text_style', _textStyle == FontStyle.italic ? 'italic' : 'normal');
  }

  Color _getColorFromInt(int value) {
    return Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Colors.green, 
        title: Text('Edit Text'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
           
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save), 
            onPressed: () {
              
              _savePreferences();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 20.h,
               decoration: BoxDecoration(
                color: Colors.transparent, 
          border: Border.all(
            color: Colors.green,
          ),
        ),
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
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    _userText = text;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Text',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  final random = Random();
                  _textColor =
                      _availableColors[random.nextInt(_availableColors.length)];
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
                  _textWeight = (_textWeight == FontWeight.bold)
                      ? FontWeight.normal
                      : FontWeight.bold;
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
              child: Text(
                (_textStyle == FontStyle.italic) ? 'Normal' : 'Italic',
                style: TextStyle(
                  fontStyle: _textStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
