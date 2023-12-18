import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gametime/View/editimage_view.dart';
import 'package:gametime/View/text_view.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class StickerView extends StatefulWidget {
  const StickerView({Key? key}) : super(key: key);

  @override
  State<StickerView> createState() => _StickerViewState();
}

class _StickerViewState extends State<StickerView> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  int tappedContainerIndex = -1;

  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _setImage(File(pickedFile.path));
    }
  }

  Future<void> _openGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _setImage(File(pickedFile.path));
    }
  }

  Future<void> _setImage(File pickedFile) async {
    File resizedImage = await _resizeImage(pickedFile);
    setState(() {
      _image = resizedImage;
    });
    _saveImageToGallery(resizedImage);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditImageView(imageFile: _image!),
      ),
    );
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

  Future<void> _saveImageToGallery(File imageFile) async {
    try {
      final result = await GallerySaver.saveImage(imageFile.path);
      if (result != null) {
        print('Image saved to gallery');
      } else {
        print('Failed to save image');
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Pick Image From',
                style: TextStyle(color: Colors.green),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _openCamera();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 30.0,
                    ),
                    SizedBox(width: 2.w),
                    Text('Open Camera'),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _openGallery();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 30.0,
                    ),
                    SizedBox(width: 2.w),
                    Text('Open Gallery'),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TextView(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.text_format,
                      size: 30.0,
                    ),
                    SizedBox(width: 2.w),
                    Text('Text'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageContainer(File? image) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      width: 40.0.w,
      height: 20.0.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.green,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (image != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.file(image),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Icon(
                  Icons.camera_alt,
                  size: 30.0,
                  color: Colors.grey.withOpacity(0.8),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Sticker', style: TextStyle(color: Colors.white),),
        leading:  IconButton(
  icon: Icon(
    Icons.arrow_back,
    color: Colors.white,
  ),
  onPressed: () {
   Navigator.pop(context);
  },
),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < 10; i++)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int j = 0; j < 3; j++)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              int index = i * 3 + j;
                              setState(() {
                                tappedContainerIndex = index;
                              });
                              _showBottomSheet(context);
                            },
                            child: _buildImageContainer(
                              tappedContainerIndex == i * 3 + j ? _image : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
