import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as img;
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
  bool _showTextEditingOptions = false;
Offset? _startCrop;
  Offset? _endCrop;
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
Future<void> _saveImageToGallery(Uint8List imageBytes) async {
  try {
    img.Image image = img.decodeImage(imageBytes)!;
    img.Image resizedImage = img.copyResize(image, width: 512, height: 512);

    Uint8List resizedBytes = resizedImage.getBytes(format: img.Format.rgba);

    if (resizedBytes.lengthInBytes > 100 * 1024) {
      resizedBytes = await FlutterImageCompress.compressWithList(
        resizedBytes,
        minHeight: 512,
        minWidth: 512,
        quality: 90,
        format: CompressFormat.webp,
      );
    }

    File finalImage = File(imageFile.path.replaceAll(
      RegExp(r'\.(?:jpg|webp|png|gif)', caseSensitive: false),
      '_resized.webp',
    ));
    await finalImage.writeAsBytes(resizedBytes);

    String savedImagePath = finalImage.path;
    await GallerySaver.saveImage(savedImagePath);
    print('Image saved to gallery: $savedImagePath');
  } catch (e) {
    print('Error saving image: $e');
  }
}
 void _performSquareCrop() async {
    if (_startCrop != null && _endCrop != null) {
      Uint8List? imageBytes = await _cropImage(); 

      
      if (imageBytes != null) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an area to crop.'),
        ),
      );
    }
  }


 Rect _getCropRect() {
    double left = _startCrop!.dx < _endCrop!.dx ? _startCrop!.dx : _endCrop!.dx;
    double top = _startCrop!.dy < _endCrop!.dy ? _startCrop!.dy : _endCrop!.dy;
    double width = (_startCrop!.dx - _endCrop!.dx).abs();
    double height = (_startCrop!.dy - _endCrop!.dy).abs();
    return Rect.fromLTWH(left, top, width, height);
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
  void _toggleTextEditingOptionsVisibility() {
    setState(() {
      _isTextContainerVisible = !_isTextContainerVisible;
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
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
  onPressed: () async {
    Uint8List? croppedImage = await _cropImage(); 
    if (croppedImage != null) {
      await _saveImageToGallery(croppedImage);
    } else {
      print('Error: Unable to save the image.');
    }
  },
),


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
        onPanStart: (details) {
            setState(() {
              _startCrop = details.localPosition;
              _endCrop = details.localPosition;
            });
          };
          onPanUpdate: (details) {
            setState(() {
              _endCrop = details.localPosition;
            });
          };
          onPanEnd: (details) {
            setState(() {
              _startCrop = null;
              _endCrop = null;
            });
          };
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
                  Visibility(
              visible: _isTextContainerVisible,
              child: Positioned(
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
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showTextEditingOptions)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
               TextButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = _textColor;

        return AlertDialog(
          title: Text('Colors'),
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
  child: Text('Color', style: TextStyle(color: Colors.green)),
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
  child: Text('Size', style: TextStyle(color: Colors.green)),
),


                  TextButton(
                    onPressed: () {
                      setState(() {
                        _textWeight = (_textWeight == FontWeight.bold)
                            ? FontWeight.normal
                            : FontWeight.bold;
                      });
                    },
                    child: Text(_textWeight == FontWeight.bold ? 'Unbold' : 'Bold', style: TextStyle(color: Colors.green),),
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
                        color: Colors.green,
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
          child: Text('Free Hand', style: TextStyle(color: Colors.green),
          ),
          ),
TextButton(
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
  child: Text(
    'Square',
     style: TextStyle(color: Colors.green),
  ),
),


  TextButton(
              onPressed: _toggleCircularCrop,
              child: Text(
                _isCircularCrop ? 'Square' : 'Circle',
                style: TextStyle(color: Colors.green),
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
           icon: Icon(Icons.rotate_left,color: Colors.green),
            
          ),
          Text('Rotate', style: TextStyle(color: Colors.green),),
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
            icon: Icon(Icons.crop, size: 28,color: Colors.green),
            
          ),
          Text('Crop', style: TextStyle(color: Colors.green),),
        ],
      ),
       Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
               _toggleTextEditingOptionsVisibility();
               _showTextEditingOptions = !_showTextEditingOptions;
              });
            },
            icon: Icon(Icons.text_fields,color: Colors.green),
            
          ),
          Text('Text', style: TextStyle(color: Colors.green),),
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
            icon: Icon(Icons.flip,color: Colors.green,),
            
          ),
          Text('Flip', style: TextStyle(color: Colors.green),),
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
