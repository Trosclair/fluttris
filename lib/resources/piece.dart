import 'dart:math';
import 'package:fluttris/resources/piece_type.dart';

class Piece {
  int rotationState = 0;
  int x = 4;
  int y = 0;
  final List<int> rotations;
  final PieceType pieceType;
  static Random rng = Random();

  Piece({required this.pieceType, required this.rotations});

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

  static final List<int> pieces = [0, 1, 2, 3, 4, 5, 6];

  static Piece getPiece() {
    if (pieces.isEmpty) {
      for (int i = 0; i < 7; i++) {
        pieces.add(i);
      }
    }

    int i = rng.nextInt(pieces.length);
    switch(pieces.removeAt(i)) {
      case 0:
        return Piece(pieceType: PieceType.i, rotations: Piece.i);
      case 1:
        return Piece(pieceType: PieceType.j, rotations: Piece.j);
      case 2:
        return Piece(pieceType: PieceType.l, rotations: Piece.l);
      case 3:
        return Piece(pieceType: PieceType.o, rotations: Piece.o);
      case 4:
        return Piece(pieceType: PieceType.s, rotations: Piece.s);
      case 5:
        return Piece(pieceType: PieceType.t, rotations: Piece.t);
      case 6:
        return Piece(pieceType: PieceType.z, rotations: Piece.z);
      default:
        return Piece(pieceType: PieceType.i, rotations: Piece.i);
    }
  }
}