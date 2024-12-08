import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fluttris/Game/tetris.dart';

void main() {
  runApp(GameWidget(game: Tetris()));
}