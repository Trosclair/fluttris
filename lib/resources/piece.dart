import 'dart:math';

import 'package:flutter/material.dart';

class Piece {
  int rotationState = 0;
  int x = 4;
  int y = 0;
  final List<int> rotations;
  final Color pieceColor;
  static Random rng = Random();

  Piece({required this.pieceColor, required this.rotations});

  int getRotationState() {
    return rotations[rotationState % rotations.length];
  }

  static final List<int> i = <int>[0x00F0, 0x2222];
  static final List<int> o = <int>[0xCC00];
  static final List<int> j = <int>[0x44C0, 0x8E00, 0x6440, 0x0E20];
  static final List<int> l = <int>[0x4460, 0x0E80, 0xC440, 0x2E00];
  static final List<int> s = <int>[0x06C0, 0x4620];
  static final List<int> z = <int>[0x0C60, 0x2640];
  static final List<int> t = <int>[0x0E40, 0x4C40, 0x4E00, 0x4640];

  static Piece getPiece() {
    int i = rng.nextInt(6);
    switch(i % 7) {
      case 0:
        return Piece(pieceColor: Colors.cyan, rotations: Piece.i);
      case 1:
        return Piece(pieceColor: const Color.fromARGB(255, 2, 82, 219), rotations: Piece.j);
      case 2:
        return Piece(pieceColor: Colors.orange, rotations: Piece.l);
      case 3:
        return Piece(pieceColor: Colors.yellow, rotations: Piece.o);
      case 4:
        return Piece(pieceColor: const Color.fromARGB(255, 6, 156, 11), rotations: Piece.s);
      case 5:
        return Piece(pieceColor: Colors.deepPurple, rotations: Piece.t);
      case 6:
        return Piece(pieceColor: Colors.red, rotations: Piece.z);
      default:
        return Piece(pieceColor: Colors.cyan, rotations: Piece.i);
    }
  }
}