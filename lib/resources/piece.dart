import 'dart:math';
import 'package:fluttris/resources/piece_type.dart';

class Piece {
  final List<int> rotations;
  final PieceType pieceType;

  static final Random _rng = Random();
  
  static const List<int> _i = <int>[0x00F0, 0x2222];
  static const List<int> _o = <int>[0xCC00];
  static const List<int> _j = <int>[0x44C0, 0x8E00, 0x6440, 0x0E20];
  static const List<int> _l = <int>[0x4460, 0x0E80, 0xC440, 0x2E00];
  static const List<int> _s = <int>[0x06C0, 0x4620];
  static const List<int> _z = <int>[0x0C60, 0x2640];
  static const List<int> _t = <int>[0x0E40, 0x4C40, 0x4E00, 0x4640];

  static final List<int> _pieces = [0, 1, 2, 3, 4, 5, 6];

  int rotationState = 0;
  int x = 4;
  int y = 0;

  Piece({required this.pieceType, required this.rotations});

  int getRotationState() {
    return rotations[rotationState % rotations.length];
  }

  static void resetBag() {
    _pieces.clear();
  }

  static Piece getPiece() {
    if (_pieces.isEmpty) {
      for (int i = 0; i < 7; i++) {
        _pieces.add(i);
      }
    }

    int i = _rng.nextInt(_pieces.length);
    switch(_pieces.removeAt(i)) {
      case 0:
        return Piece(pieceType: PieceType.i, rotations: Piece._i);
      case 1:
        return Piece(pieceType: PieceType.j, rotations: Piece._j);
      case 2:
        return Piece(pieceType: PieceType.l, rotations: Piece._l);
      case 3:
        return Piece(pieceType: PieceType.o, rotations: Piece._o);
      case 4:
        return Piece(pieceType: PieceType.s, rotations: Piece._s);
      case 5:
        return Piece(pieceType: PieceType.t, rotations: Piece._t);
      case 6:
        return Piece(pieceType: PieceType.z, rotations: Piece._z);
      default:
        return Piece(pieceType: PieceType.i, rotations: Piece._i);
    }
  }
}