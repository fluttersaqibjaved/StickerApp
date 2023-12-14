import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
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

  Future<void> _openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      _setImage(file);
    } else {
      
    }
  }

  Future<void> _setImage(File pickedFile) async {
    File resizedImage = await _resizeImage(pickedFile);
    setState(() {
      _image = resizedImage;
    });
    _saveImageToGallery(resizedImage);
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

      List<int> resizedImageBytes = img.encodePng(resizedImage); // Convert the image to PNG bytes
      Uint8List resizedUint8List = Uint8List.fromList(resizedImageBytes); // Convert to Uint8List
      final compressedImage = await FlutterImageCompress.compressWithList(
        resizedUint8List, // Pass Uint8List to FlutterImageCompress
        minHeight: targetHeight,
        minWidth: targetWidth,
        quality: quality,
        format: CompressFormat.webp, // Save as WebP format
      );

      resizedFile = File(imageFile.path.replaceAll(RegExp(r'\.(?:jpg|webp|png|gif)', caseSensitive: false), '_resized.webp'));
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
    Navigator.pop(context);
    _openFile();
  },
  child: Row(
    children: [
      Icon(
        Icons.file_copy_sharp,
        size: 30.0,
      ),
      SizedBox(width: 2.w),
      Text('Select File'),
    ],
  ),
),

              SizedBox(height: 2.h),
              

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 80.w,
          height: 40.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _image != null ? Image.file(_image!) : Container(),
              Positioned(
                right: 150.0,
                child: GestureDetector(
                  onTap: () {
                    _showBottomSheet(context);
                  },
                  child: Icon(
                    Icons.camera_alt,
                    size: 40.0,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
