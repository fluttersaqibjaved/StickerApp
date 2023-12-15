import 'package:flutter/material.dart';
import 'package:gametime/View/circle_view.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Sticker',
          theme: ThemeData(
            primarySwatch: Colors.pink,
          ),
          home: CircleView(), 
        );
      },
    );
  }
}
