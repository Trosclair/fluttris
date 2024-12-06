import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Block extends SpriteComponent {
  final Color color;
  final String filename;

  Block({required this.color, required this.filename}) : super(size: Vector2.all(40));

  @override FutureOr<void> onLoad() async {
    sprite = await Sprite.load(filename);
  }
}