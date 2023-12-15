import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gametime/View/free_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isTextContainerVisible = false;
  Color _selectedColor = Colors.red;
  double _selectedFontSize = 20.0;
  bool _isBold = false;
  bool _isFlippedHorizontally = false;
  bool _showCropOptions = false;
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
    imageFile = widget.imageFile;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _toggleTextContainerVisibility() {
    setState(() {
      _isTextContainerVisible = !_isTextContainerVisible;
    });
  }

  void _saveChanges() {
   
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

  Future<void> _loadPreferences() async {
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
    _prefs.setString(
        'text_weight', _textWeight == FontWeight.bold ? 'bold' : 'normal');
    _prefs.setString(
        'text_style', _textStyle == FontStyle.italic ? 'italic' : 'normal');
  }

  Color _getColorFromInt(int value) {
    return Color(value);
  }

  @override
  Widget build(BuildContext context) {
    bool isTextNotEmpty = _displayedText.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Edit Image'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCropOptions = !_showCropOptions;
                  _toggleTextContainerVisibility();
                });
              },
              child: Stack(
                children: [
                  Transform(
                    transform: Matrix4.identity()
                      ..scale(_isFlippedHorizontally ? -1.0 : 1.0, 1.0),
                    alignment: Alignment.center,
                    child: Container(
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
                  ),
                  Positioned(
                    left: _textPosition.dx,
                    top: _textPosition.dy,
                    child: Visibility(
                      visible: _isTextContainerVisible,
                      child: GestureDetector(
                        onTapDown: (details) {
                          _startPosition =
                              details.localPosition - _textPosition;
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            _textPosition =
                                details.localPosition - _startPosition;
                          });
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          color: _displayedText.isEmpty
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white.withOpacity(0),
                          padding: EdgeInsets.all(8),
                          child: TextFormField(
                            controller: _textEditingController,
                            style: TextStyle(
                              color: _selectedColor,
                              fontSize: _selectedFontSize,
                              fontWeight: _isBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Your text here',
                              hintStyle:
                                  TextStyle(color: Colors.black.withOpacity(0.5)),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.green,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTextNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
             if (_showCropOptions) 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  
                 TextButton(
              onPressed: () {
                setState(() {
                    Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FreeView()),
            );
                });
              },
              child: Text('Free Hand'),
            ),
                   TextButton(
              onPressed: () {
                setState(() {
                  
                });
              },
              child: Text('Square'),
            ),
                 TextButton(
              onPressed: () {
                setState(() {
                  
                });
              },
              child: Text('Circle'),
            ),
                ],
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _angle += 90 * (3.1415926535 / 180);
                    });
                  },
                  icon: Icon(Icons.rotate_left),
                  tooltip: 'Rotate',
                ),
                IconButton(
                  onPressed: () {
                    
                    setState(() {
                      _showCropOptions = false;
                    });
                  },
                  icon: Icon(Icons.crop),
                  tooltip: 'Crop',
                ),
                IconButton(
                  onPressed: () {
                    _toggleTextContainerVisibility();
                  },
                  icon: Icon(Icons.text_decrease_sharp),
                  tooltip: 'Text',
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isFlippedHorizontally = !_isFlippedHorizontally;
                    });
                  },
                  icon: Icon(Icons.flip),
                  tooltip: 'Flip',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
