import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditImageView extends StatefulWidget {
  final File imageFile;

  const EditImageView({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<EditImageView> createState() => _EditImageViewState();
}

class _EditImageViewState extends State<EditImageView> {
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

  void _performFreeHandCrop() async {
    Uint8List? imageBytes = await _cropImage();
    
    if (imageBytes != null) {
      
    }
  }
  late File imageFile;
  TextEditingController _textEditingController = TextEditingController();
  String _displayedText = "Your text here";
  double _angle = 0;
  Offset _textPosition = Offset(50, 50);
  Offset _startPosition = Offset.zero;
  bool _isTextContainerVisible = false;
  bool _isFlippedHorizontally = false;
  bool _showCropOptions = false;
  bool _isCircularCrop = false;
  late SharedPreferences _prefs;
  late String _userText;
  late List<Color> _availableColors;
  late Color _textColor;
  late double _textSize;
  late FontWeight _textWeight;
  late FontStyle _textStyle;
 
void _performSquareCrop() async {
  
  Uint8List? imageBytes = await _cropImage();
  
  if (imageBytes != null) {
   
  }
}

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

  void _initializeValues() {
    _userText = 'Customizable Text';
    _availableColors = [
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
void _toggleCircularCrop() {
    setState(() {
      _isCircularCrop = !_isCircularCrop;
    });
  }
  
   void _saveChanges() {
   
    

    print('Changes Saved');
  }
  
  @override
  Widget build(BuildContext context) {
    bool isTextNotEmpty = _displayedText.isNotEmpty;
  Widget imageWidget = Image.file(
      imageFile,
      fit: BoxFit.cover,
    );

    if (_isCircularCrop) {
      imageWidget = ClipOval(
        child: imageWidget,
      );
    } 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Edit Image', style: TextStyle(color: Colors.white),),
        leading:
        IconButton(
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
    
  },
)

        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(
            key: _repaintKey,
            child:
              
           GestureDetector(
  onTap: () {
    setState(() {
      
      _toggleTextContainerVisibility();
    });
  },
  
  onPanStart: _handlePanStart,
  onPanUpdate: _handlePanUpdate,
  onPanEnd: _handlePanEnd,
  
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
                             child: imageWidget,
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
                              color: _textColor,
                              fontSize: _textSize,
                              fontWeight: _textWeight,
                              fontStyle: _textStyle,
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
            ),
               CustomPaint(
                    painter: TouchPainter(points: _points),
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
                    child: Text('Color',style: TextStyle(color: Colors.white),),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _textSize = (_textSize == 20.0) ? 16.0 : 20.0;
                      });
                    },
                    child: Text(_textSize == 20.0 ? 'Decrease' : 'Increase',style: TextStyle(color: Colors.white),),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _textWeight = (_textWeight == FontWeight.bold)
                            ? FontWeight.normal
                            : FontWeight.bold;
                      });
                    },
                    child: Text(_textWeight == FontWeight.bold ? 'Unbold' : 'Bold',style: TextStyle(color: Colors.white),),
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
                        color: Colors.white,
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
          onPressed: _performFreeHandCrop,
          child: Text('Free Hand',style: TextStyle(color: Colors.white),
          ),
          ),
 TextButton(
  onPressed: _performSquareCrop,
  child: Text(
    'Square Crop',
    style: TextStyle(color: Colors.white),
  ),
),

  TextButton(
              onPressed: _toggleCircularCrop,
              child: Text(
                _isCircularCrop ? 'Square' : 'Circle',
                style: TextStyle(color: Colors.white),
              ),
            ),
                ],
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                  Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _angle += 90 * (pi / 180);
              });
            },
           icon: Icon(Icons.rotate_left,color: Colors.white,),
            
          ),
          Text('Rotate', style: TextStyle(fontSize: 12,color: Colors.white,)),
        ],
      ),
               Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _showCropOptions = !_showCropOptions;
              });
            },
            icon: Icon(Icons.crop, size: 28,color: Colors.white,),
            
          ),
          Text('Crop', style: TextStyle(fontSize: 12,color: Colors.white)),
        ],
      ),
       Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _toggleTextContainerVisibility();
              });
            },
            icon: Icon(Icons.text_fields,color: Colors.white,),
            
          ),
          Text('Text', style: TextStyle(fontSize: 12,color: Colors.white,)),
        ],
      ),
        Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                 _isFlippedHorizontally = !_isFlippedHorizontally;
              });
            },
            icon: Icon(Icons.flip,color: Colors.white,),
            
          ),
          Text('Flip', style: TextStyle(fontSize: 12,color: Colors.white,)),
        ],
      ),       
              ],
            ),
          ],
        ),
      ),
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