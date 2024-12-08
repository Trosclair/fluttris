import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttris/pages/homepage.dart';

void main() {
  runApp(HomePage());
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
}