//  import 'dart:io';

//         import 'package:flutter/material.dart';
//         import 'dart:ui' as ui;
//         import 'package:flutter/services.dart' show rootBundle;
//         import 'dart:async';
//         import 'dart:typed_data';
//         import 'dart:math' as math;
//         import 'package:path/path.dart';
//         import 'package:path_provider/path_provider.dart';

//         class CircleView extends StatefulWidget {
//           CircleView({Key key, this.title}) : super(key: key);

//           final String title;

//           @override
//           _CircleViewState createState() => _CircleViewState();
//         }

//         class _CircleViewState extends State<CircleView> {
//           ui.Image image;
//           bool isImageloaded = false;
//           void initState() {
//             super.initState();
//             init();
//           }

//           Future<Null> init() async {
//             final ByteData data = await rootBundle.load('assets/image.jpeg');
//             image = await loadImage(Uint8List.view(data.buffer));
//           }

//           Future<ui.Image> loadImage(List<int> img) async {
//             final Completer<ui.Image> completer = Completer();
//             ui.decodeImageFromList(img, (ui.Image img) {
//               setState(() {
//                 isImageloaded = true;
//               });
//               return completer.complete(img);
//             });
//             return completer.future;
//           }

//           Widget _buildImage() {
//             if (this.isImageloaded) {
//               return CustomPaint(
//                 painter: PngImagePainter(image: image),
//               );
//             } else {
//               return Center(child: Text('loading'));
//             }
//           }

//           @override
//           Widget build(BuildContext context) {
//             return Scaffold(
//                 appBar: AppBar(
//                   title: Text(widget.title),
//                 ),
//                 body: Container(
//                   child: _buildImage(),
//                 ));
//           }
//         }

//         class PngImagePainter extends CustomPainter {
//           PngImagePainter({
//             this.image,
//           });

//           ui.Image image;

//           @override
//           void paint(Canvas canvas, Size size) {
//             _drawCanvas(size, canvas);
//             _saveCanvas(size);
//           }

//           Canvas _drawCanvas(Size size, Canvas canvas) {
//             final center = Offset(150, 50);
//             final radius = math.min(size.width, size.height) / 8;

           
//             Paint paintCircle = Paint()..color = Colors.black;
//             Paint paintBorder = Paint()
//               ..color = Colors.white
//               ..strokeWidth = size.width / 36
//               ..style = PaintingStyle.stroke;
//             canvas.drawCircle(center, radius, paintCircle);
//             canvas.drawCircle(center, radius, paintBorder);

//             double drawImageWidth = 0;
//             var drawImageHeight = -size.height * 0.8;

//             Path path = Path()
//               ..addOval(Rect.fromLTWH(drawImageWidth, drawImageHeight,
//                   image.width.toDouble(), image.height.toDouble()));

//             canvas.clipPath(path);

//             canvas.drawImage(image, Offset(drawImageWidth, drawImageHeight), Paint());
//             return canvas;
//           }

//           _saveCanvas(Size size) async {
//             var pictureRecorder = ui.PictureRecorder();
//             var canvas = Canvas(pictureRecorder);
//             var paint = Paint();
//             paint.isAntiAlias = true;

//             _drawCanvas(size, canvas);

//             var pic = pictureRecorder.endRecording();
//             ui.Image img = await pic.toImage(image.width, image.height);
//             var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//             var buffer = byteData.buffer.asUint8List();
//             var documentDirectory = await getApplicationDocumentsDirectory();
//             File file = File(join(documentDirectory.path,
//                 '${DateTime.now().toUtc().toIso8601String()}.png'));
//             file.writeAsBytesSync(buffer);

//             print(file.path);
//           }

//           @override
//           bool shouldRepaint(CustomPainter oldDelegate) {
//             return false;
//           }
//         }