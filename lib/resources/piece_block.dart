import 'dart:async';
import 'package:flame/components.dart';

class PieceBlock extends SpriteComponent {
  final String filename;

  PieceBlock({required this.filename}) : super();

  @override FutureOr<void> onLoad() async {
    sprite = await Sprite.load(filename);
  }
}