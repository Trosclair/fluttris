import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttris/pages/home_page.dart';
import 'package:fluttris/resources/options.dart';

void main() async {
  Options options = await Options.getOptions();
  runApp(MyApp(options: options));
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
}

class MyApp extends StatelessWidget {
  final Options options;

  const MyApp({super.key, required this.options});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(options: options),
    );
  }
}