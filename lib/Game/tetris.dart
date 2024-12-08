import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttris/resources/game_input.dart';
import 'package:fluttris/resources/piece.dart';
import 'package:fluttris/resources/piece_type.dart';

class Tetris extends FlameGame with HasPerformanceTracker, KeyboardEvents, TapDetector {
  Paint transparentPaint = BasicPalette.transparent.paint();
  Stopwatch globalTimer = Stopwatch();
  Map<PieceType, Sprite> blockTypes = {};
  late Sprite boardBackground;
  List<List<PieceType?>> board = [];
  late Piece currentPiece;
  late Piece nextPiece; 
  late Piece nextPiece1; 
  late Piece nextPiece2; 
  late Piece nextPiece3; 
  Piece? holdPiece;
  int lastFPSPollTime = 0;
  int displayFPS = 0;
  int fpsCount = 0;
  int lastPieceDroppedTime = 0;
  int score = 0;
  int totalLinesCleared = 0;
  bool hasHeldAPiece = false;
  bool isPlaying = true;
  double blockSideLength = 0;
  double boardStartingPositionX = 0;
  double boardStartingPositionY = 0;
  double nextPiecePositionX = 0;
  double nextPiecePositionY = 0;
  double nextPieceBlockSideLength = 0;
  double nextPiece1PositionY = 0;
  double nextPiece2PositionY = 0;
  double nextPiece3PositionY = 0;
  double holdPiecePositionX = 0;
  double holdPiecePositionY = 0;
  TextPaint reg = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.white.color));

  Tetris() {
    pauseWhenBackgrounded = true;
    globalTimer.start();
    
    for (int i = 0; i < 10; i++) {
      List<PieceType?> row = [];
      for (int j = 0; j < 20; j++) {
        row.add(null);
      }
      board.add(row);
    }

    currentPiece = Piece.getPiece();
    nextPiece = Piece.getPiece();
    nextPiece1 = Piece.getPiece();
    nextPiece2 = Piece.getPiece();
    nextPiece3 = Piece.getPiece();
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    setSizes();
    boardBackground = Sprite(await Flame.images.load('board_background.png'));
    blockTypes.addEntries(<PieceType, Sprite>{
        PieceType.empty: Sprite(await Flame.images.load('black.png')),
        PieceType.z: Sprite(await Flame.images.load('red.png')),
        PieceType.j: Sprite(await Flame.images.load('blue.png')),
        PieceType.s: Sprite(await Flame.images.load('green.png')),
        PieceType.o: Sprite(await Flame.images.load('yellow.png')),
        PieceType.i: Sprite(await Flame.images.load('cyan.png')),
        PieceType.t: Sprite(await Flame.images.load('purple.png')),
        PieceType.l: Sprite(await Flame.images.load('orange.png')),
        PieceType.shadow: Sprite(await Flame.images.load('white.png')),
      }.entries
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    setSizes();
  }

  @override
  void render(Canvas canvas) {

    drawPiece(nextPiecePositionX, nextPiecePositionY, nextPieceBlockSideLength, nextPiece, canvas);
    drawPiece(nextPiecePositionX, nextPiece1PositionY, nextPieceBlockSideLength * .8, nextPiece1, canvas);
    drawPiece(nextPiecePositionX, nextPiece2PositionY, nextPieceBlockSideLength * .8, nextPiece2, canvas);
    drawPiece(nextPiecePositionX, nextPiece3PositionY, nextPieceBlockSideLength * .8, nextPiece3, canvas);

    if (holdPiece != null) {
      drawPiece(holdPiecePositionX, holdPiecePositionY, nextPieceBlockSideLength, holdPiece!, canvas);
    }
    
    boardBackground.render(canvas, position: Vector2(boardStartingPositionX, boardStartingPositionY), size: Vector2(blockSideLength * 10, blockSideLength * 20));

    int shadowY = getDropShadowYCoord();
    for (int i = 0; i < 16; i++) {
      if (currentPiece.getRotationState() & (0x8000 >> i) > 0) {
        Vector2 pos = Vector2(boardStartingPositionX + (blockSideLength * (currentPiece.x.toDouble() + (i % 4)).toDouble()), boardStartingPositionY + (blockSideLength * (shadowY + (i ~/ 4)).toDouble()));
        blockTypes[PieceType.shadow]!.render(
          canvas,
          position: pos,
          size: Vector2.all(blockSideLength)
        );
      }
    }
    
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 20; j++) {
        PieceType? pt = board[i][j];
        if (pt != null) {
          Sprite block = blockTypes[pt]!;
          block.render(
            canvas, 
            position: Vector2(boardStartingPositionX + (i * blockSideLength), boardStartingPositionY + (j * blockSideLength)), 
            size: Vector2.all(blockSideLength)
          );
        }
      }
    }

    drawPiece(boardStartingPositionX + (currentPiece.x * blockSideLength), boardStartingPositionY + (currentPiece.y * blockSideLength), blockSideLength, currentPiece, canvas);

    fpsCount++;
    if (globalTimer.elapsedMilliseconds > lastFPSPollTime + 1000) {
        displayFPS = fpsCount;
        fpsCount = 0;
        lastFPSPollTime = globalTimer.elapsedMilliseconds;
    }
    
    canvas.drawRect(Rect.fromLTWH(0, 0, 100, 20), BasicPalette.black.paint());
    reg.render(canvas, displayFPS.toString(), Vector2.all(0));

    super.render(canvas);
  }
  
  @override
  void update(double dt) {
    super.update(dt);

    if (globalTimer.elapsedMilliseconds > lastPieceDroppedTime + (1000 - (5 * totalLinesCleared))) {
        down(false);
        lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
      }
  }

  @override
  void onTap() {
    super.onTap();

  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    switch (event.character) {
      case 'w':
        hardDrop();
        break;
      case 'd':
        moveDirection(GameInput.right);
        break;
      case 's':
        down(true);
      case 'a':
        moveDirection(GameInput.left);
        break;
      case 'e':
        hold();
        break;
      case '/':
        rotateClockwise();
        break;
      case '.':
        rotateCounterClockwise();
        break;
    }

    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() {
    return Colors.black;
  }
  
  void drawPiece(double piecePositionX, double piecePositionY, double sideLength, Piece piece, Canvas canvas) {
    for (int i = 0; i < 16; i++) {
      if (piece.getRotationState() & (0x8000 >> i) > 0) {
        Vector2 pos = Vector2(piecePositionX + (sideLength * (i % 4).toDouble()), piecePositionY + (sideLength * (i ~/ 4).toDouble()));
        blockTypes[piece.pieceType]!.render(
          canvas,
          position: pos,
          size: Vector2.all(sideLength)
        );
      }
    }
  }

  void setSizes() {
    blockSideLength = (size.y) / 20;
    boardStartingPositionX = (size.x / 2) - (blockSideLength * 5);
    boardStartingPositionY = 0;

    nextPiecePositionX = boardStartingPositionX + (blockSideLength * 10) + 20;
    nextPiecePositionY = boardStartingPositionY + 20;
    nextPieceBlockSideLength = blockSideLength * .7;

    nextPiece1PositionY = nextPiecePositionY + (nextPieceBlockSideLength * 4) + 20;
    nextPiece2PositionY = nextPiecePositionY + (nextPieceBlockSideLength * 4 + (nextPieceBlockSideLength * 4 * .8)) + 20;
    nextPiece3PositionY = nextPiecePositionY + (nextPieceBlockSideLength * 4 + (nextPieceBlockSideLength * 8* .8)) + 20;

    holdPiecePositionX = boardStartingPositionX - (blockSideLength * 4) - 20;
    holdPiecePositionY = boardStartingPositionY + 20;
  }

  bool moveDirection(GameInput input) {
    int x = currentPiece.x;
    int y = currentPiece.y;

    if (input == GameInput.left) {
      x--;
    }
    else if (input == GameInput.right) {
      x++;
    }
    else if (input == GameInput.down) {
      y++;
    }

    if (!checkCollision(x, y)) {
      currentPiece.x = x;
      currentPiece.y = y;
      return true;
    }
    return false;
  }

  bool checkCollision(int x, int y) {
    bool b = false;
    int iterations = 0;

    while (iterations < 16) {
      if (!b && (currentPiece.getRotationState() & (0x8000 >> iterations)) > 0) {
        b = areXAndYCoordIllegal(b, x + (iterations % 4), y + (iterations ~/ 4));
      }
      
      iterations++;
    }

    return b;
  }

  bool areXAndYCoordIllegal(bool b, int x, int y) {
    if ((x < 0) || (x >= 10) || (y < 0) || (y >= 20)) {
      b = true;
    }
    else {
      b = b | (board[x][y] != null);
    }
    return b;
  }

  int getDropShadowYCoord() {
    int y = currentPiece.y;
    while (!checkCollision(currentPiece.x, y)){
      y++;
    }
    return y - 1;
  }

  void rotateCounterClockwise() {
    int oldRotationState = currentPiece.rotationState;
    currentPiece.rotationState = (currentPiece.rotationState + currentPiece.rotations.length - 1) % currentPiece.rotations.length;

    if (checkCollision(currentPiece.x, currentPiece.y)) {
      currentPiece.rotationState = oldRotationState;
    }
  }

  void rotateClockwise() {
    int oldRotationState = currentPiece.rotationState;
    currentPiece.rotationState = (currentPiece.rotationState + 1) % currentPiece.rotations.length;

    if (checkCollision(currentPiece.x, currentPiece.y)) {
      currentPiece.rotationState = oldRotationState;
    }
  }

  void hold() {
    if (!hasHeldAPiece) {
      hasHeldAPiece = true;

      if (holdPiece != null) {
        Piece temp = holdPiece!;
        holdPiece = currentPiece;
        currentPiece = temp;
      }
      else {
        holdPiece = currentPiece;
        currentPiece = nextPiece;
        nextPiece = nextPiece1;
        nextPiece1 = nextPiece2;
        nextPiece2 = nextPiece3;
        nextPiece3 = Piece.getPiece();
      }

      holdPiece?.x = 4;
      holdPiece?.y = 0;

      lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
    }
  }

  void commitPieceToBoard() {
    int iterations = 0;
    
    while (iterations < 16) {
      if ((currentPiece.getRotationState() & (0x8000 >> iterations)) > 0) {
        board[currentPiece.x + (iterations % 4)][currentPiece.y + (iterations ~/ 4)] = currentPiece.pieceType;
      }
      iterations++;
    }
  }

  void removeLine(int y) {
    do {
      for (int x = 0; x < 10; x++) {
        board[x][y] = (y == 0) ? null : board[x][y - 1];
      }
      y--;
    } while (y >= 0);
  }

  void removeLines() {
    int linesCleared = 0;

    for (int y = 19; y >= 0; y--) {
      bool isLineComplete = true;
      for (int x = 0; x < 10; x++) {
        isLineComplete &= !(board[x][y] == null);
      }

      if (isLineComplete) {
        removeLine(y);
        linesCleared++;
        y++;            //run it back!
      }
    }

    if (linesCleared > 0) {
      totalLinesCleared += linesCleared;
      score += (pow(linesCleared, 2) * 100) as int;
    }
  }

  void afterDropCollision() {
    commitPieceToBoard();
    removeLines();
    currentPiece = nextPiece;
    nextPiece = nextPiece1;
    nextPiece1 = nextPiece2;
    nextPiece2 = nextPiece3;
    nextPiece3 = Piece.getPiece();
    hasHeldAPiece = false;
    isPlaying = !checkCollision(currentPiece.x, currentPiece.y);
  }

  void hardDrop() {
    while (moveDirection(GameInput.down)) {
      score += 10;
    }
    afterDropCollision();
  }

  void down(bool isHoldingDown) {
    if (isHoldingDown) {
      score += 10;
    }

    if (!moveDirection(GameInput.down)) {
      afterDropCollision();
    }
  }
}