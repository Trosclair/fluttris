import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttris/pages/home_page.dart';
import 'package:fluttris/resources/options.dart';

void main() async {
  await Options.initializeOptions();
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}