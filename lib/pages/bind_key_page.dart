import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fluttris/resources/options.dart';

class BindKeyPage extends StatelessWidget {
  final Options options;

  const BindKeyPage({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    options.context = context;
    return Container(
      color: Colors.black,
      child: GameWidget(game: options),
    );
  }
}