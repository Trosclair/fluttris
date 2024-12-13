import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:fluttris/resources/game_stats.dart';
import 'package:fluttris/resources/piece.dart';
import 'package:fluttris/resources/piece_type.dart';

class GameRenderer {
  final TextPaint _reg60 = TextPaint(style: TextStyle(fontSize: 60, color: BasicPalette.white.color));
  final TextPaint _reg20 = TextPaint(style: TextStyle(fontSize: 20, color: BasicPalette.white.color));
  final TextPaint _reg12 = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.white.color));

  late Future loadAssets;
  late Sprite _boardBackground;
  late Map<PieceType, Sprite> _blockTypes;
  
  double _blockSideLength = 0;
  double _boardStartingPositionX = 0;
  double _boardStartingPositionY = 0;
  double _nextPiecePositionX = 0;
  double _nextPiecePositionY = 0;
  double _nextPieceBlockSideLength = 0;
  double _nextPiece1PositionY = 0;
  double _nextPiece2PositionY = 0;
  double _nextPiece3PositionY = 0;
  double _holdPiecePositionX = 0;
  double _holdPiecePositionY = 0;
  double _scorePositionX = 0;
  double _scorePositionY = 0;
  double _linesClearedPositionX = 0;
  double _linesClearedPositionY = 0;
  double _levelClearedPositionX = 0;
  double _levelClearedPositionY = 0;

  GameRenderer() { loadAssets = _loadAssets(); }
  
  /// everytime the game window is resized we recalculate all these values that control how and where things are drawn.
  void reset(Vector2 size) {
    _blockSideLength = (size.y) / 20;
    _boardStartingPositionX = (size.x / 2) - (_blockSideLength * 5);
    _boardStartingPositionY = 0;

    _nextPiecePositionX = _boardStartingPositionX + (_blockSideLength * 10) + 10;
    _nextPiecePositionY = _boardStartingPositionY + 20;
    _nextPieceBlockSideLength = _blockSideLength * .7;

    _nextPiece1PositionY = _nextPiecePositionY + (_nextPieceBlockSideLength * 4) + 20;
    _nextPiece2PositionY = _nextPiecePositionY + (_nextPieceBlockSideLength * 4 + (_nextPieceBlockSideLength * 4 * .8)) + 40;
    _nextPiece3PositionY = _nextPiecePositionY + (_nextPieceBlockSideLength * 4 + (_nextPieceBlockSideLength * 8* .8)) + 60;

    _holdPiecePositionX = 10;
    _holdPiecePositionY = _boardStartingPositionY + 20;

    _scorePositionX = 10;
    _scorePositionY = _holdPiecePositionY + (_nextPieceBlockSideLength * 4) + 20;

    _linesClearedPositionX = 10;
    _linesClearedPositionY = _scorePositionY + 60;

    _levelClearedPositionX = 10;
    _levelClearedPositionY = _linesClearedPositionY + 60;
  }

  Future _loadAssets() async {
    _boardBackground = Sprite(await Flame.images.load('board_background.png'));
    _blockTypes = {
        PieceType.empty: Sprite(await Flame.images.load('black.png')),
        PieceType.z: Sprite(await Flame.images.load('red.png')),
        PieceType.j: Sprite(await Flame.images.load('blue.png')),
        PieceType.s: Sprite(await Flame.images.load('green.png')),
        PieceType.o: Sprite(await Flame.images.load('yellow.png')),
        PieceType.i: Sprite(await Flame.images.load('cyan.png')),
        PieceType.t: Sprite(await Flame.images.load('purple.png')),
        PieceType.l: Sprite(await Flame.images.load('orange.png')),
        PieceType.shadow: Sprite(await Flame.images.load('white.png')),
      };
  }

  // draw fps count
  void renderFPS(Canvas canvas, int displayFPS) {
    _reg12.render(canvas, displayFPS.toString(), Vector2.all(0));
  }

  // Render the blocks of the pieces that have been locked into place.
  void renderBoard(Canvas canvas, List<List<PieceType?>> board) {
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 20; j++) {
        PieceType? pt = board[i][j];
        if (pt != null) {
          Sprite block = _blockTypes[pt]!;
          block.render(
            canvas, 
            position: Vector2(_boardStartingPositionX + (i * _blockSideLength), _boardStartingPositionY + (j * _blockSideLength)), 
            size: Vector2.all(_blockSideLength)
          );
        }
      }
    }
  }

  // draw the score/lines/level data.
  void renderStats(Canvas canvas, GameStats stats) {
    canvas.drawRect(Rect.fromLTWH(_scorePositionX - 1, _scorePositionY - 1, (_nextPieceBlockSideLength * 4) + 2, _scorePositionY + 72), Paint()..color = Colors.blue);
    canvas.drawRect(Rect.fromLTWH(_scorePositionX, _scorePositionY, (_nextPieceBlockSideLength * 4), _scorePositionY + 70), Paint()..color = Color(0xFF1C1C84));
    _reg20.render(canvas, 'Score:', Vector2(_scorePositionX + 3, _scorePositionY));
    _reg20.render(canvas, stats.score.toString(), Vector2(_scorePositionX + 3, _scorePositionY + 20));
    _reg20.render(canvas, 'Lines:', Vector2(_linesClearedPositionX + 3, _linesClearedPositionY));
    _reg20.render(canvas, stats.totalLinesCleared.toString(), Vector2(_linesClearedPositionX + 3, _linesClearedPositionY + 20));
    _reg20.render(canvas, 'Level:', Vector2(_levelClearedPositionX + 3, _levelClearedPositionY));
    _reg20.render(canvas, stats.level.toString(), Vector2(_levelClearedPositionX + 3, _levelClearedPositionY + 20));
  }

  void renderPieces(Canvas canvas, Piece currentPiece, Piece nextPiece, Piece nextPiece1, Piece nextPiece2, Piece nextPiece3, Piece? holdPiece) {

    // draw the next piece backing boxes.
    _drawPieceBox(canvas, _nextPiecePositionX, _nextPiecePositionY, _nextPieceBlockSideLength);
    _drawPieceBox(canvas, _nextPiecePositionX, _nextPiece1PositionY, _nextPieceBlockSideLength * .8);
    _drawPieceBox(canvas, _nextPiecePositionX, _nextPiece2PositionY, _nextPieceBlockSideLength * .8);
    _drawPieceBox(canvas, _nextPiecePositionX, _nextPiece3PositionY, _nextPieceBlockSideLength * .8);

    // draw the next piece previews
    _drawPiece(_nextPiecePositionX, _nextPiecePositionY, _nextPieceBlockSideLength, nextPiece, canvas);
    _drawPiece(_nextPiecePositionX, _nextPiece1PositionY, _nextPieceBlockSideLength * .8, nextPiece1, canvas);
    _drawPiece(_nextPiecePositionX, _nextPiece2PositionY, _nextPieceBlockSideLength * .8, nextPiece2, canvas);
    _drawPiece(_nextPiecePositionX, _nextPiece3PositionY, _nextPieceBlockSideLength * .8, nextPiece3, canvas);

    // draw the hold piece backing box and then draw the hold piece if the player has one held.
    _drawPieceBox(canvas, _holdPiecePositionX, _holdPiecePositionY, _nextPieceBlockSideLength);
    if (holdPiece != null) {
      _drawPiece(_holdPiecePositionX, _holdPiecePositionY, _nextPieceBlockSideLength, holdPiece, canvas);
    }
    
    _drawPiece(_boardStartingPositionX + (currentPiece.x * _blockSideLength), _boardStartingPositionY + (currentPiece.y * _blockSideLength), _blockSideLength, currentPiece, canvas);
  }

  // Render the background of the board
  void renderBoardBackground(Canvas canvas) {
    _boardBackground.render(canvas, position: Vector2(_boardStartingPositionX, _boardStartingPositionY), size: Vector2(_blockSideLength * 10, _blockSideLength * 20));
  }

  void renderCountDown(Canvas canvas, int sec) {
    canvas.drawRect(Rect.fromLTWH(_boardStartingPositionX, _boardStartingPositionY, _blockSideLength * 10, _blockSideLength * 20), Paint()..color = Colors.black);
    _reg60.render(canvas, sec.toString(), Vector2(_boardStartingPositionX + (_blockSideLength * 5), _boardStartingPositionY + (_blockSideLength * 10)));
  }

  void renderPieceShadow(Canvas canvas, int x, int y, int currentPieceRotationState) {
    for (int i = 0; i < 16; i++) {
      if (currentPieceRotationState & (0x8000 >> i) > 0) {
        Vector2 pos = Vector2(_boardStartingPositionX + (_blockSideLength * (x.toDouble() + (i % 4)).toDouble()), _boardStartingPositionY + (_blockSideLength * (y + (i ~/ 4)).toDouble()));
        _blockTypes[PieceType.shadow]!.render(
          canvas,
          position: pos,
          size: Vector2.all(_blockSideLength)
        );
      }
    }
  }

  /// draws the backing box for the hold and next pieces.
  void _drawPieceBox(Canvas canvas, double startX, double startY, double sideLength) {
    canvas.drawRect(Rect.fromLTWH(startX - 1, startY - 1, (sideLength * 4) + 2, (sideLength * 4) + 2), Paint()..color = Colors.blue);
    canvas.drawRect(Rect.fromLTWH(startX, startY, (sideLength * 4), (sideLength * 4)), Paint()..color = Color(0xFF1C1C84));
  }

  /// Draw the piece given at the coords given.
  void _drawPiece(double piecePositionX, double piecePositionY, double sideLength, Piece piece, Canvas canvas) {
    for (int i = 0; i < 16; i++) {
      if (piece.getRotationState() & (0x8000 >> i) > 0) {
        Vector2 pos = Vector2(piecePositionX + (sideLength * (i % 4).toDouble()), piecePositionY + (sideLength * (i ~/ 4).toDouble()));
        _blockTypes[piece.pieceType]!.render(
          canvas,
          position: pos,
          size: Vector2.all(sideLength)
        );
      }
    }
  }
}