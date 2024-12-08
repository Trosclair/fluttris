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
import 'package:fluttris/resources/game_state.dart';
import 'package:fluttris/resources/piece.dart';
import 'package:fluttris/resources/piece_type.dart';

class Tetris extends FlameGame with HasPerformanceTracker, KeyboardEvents {
  static const double msPerFrame = 16.67;
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
  int level = 0;
  int score = 0;
  int speed = 0;
  int totalLinesCleared = 0;
  bool hasHeldAPiece = false;
  bool tetrisCleared = false;
  bool tSpin = false;
  int screenWipeIndex = 19;
  String? statusMessage;
  int lastStatusTime = 0;
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
  double scorePositionX = 0;
  double scorePositionY = 0;
  double linesClearedPositionX = 0;
  double linesClearedPositionY = 0;
  double levelClearedPositionX = 0;
  double levelClearedPositionY = 0;
  double statusPositionX = 0;
  double statusPositionY = 0;
  int lastWipeTime = 0;
  late GameState gameState = GameState.start;
  TextPaint reg = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.white.color));
  
  static Map<int, int> levelsToSpeeds = <int, int>{
    0: (48 * msPerFrame).toInt(),
    1: (43 * msPerFrame).toInt(),
    2: (38 * msPerFrame).toInt(),
    3: (33 * msPerFrame).toInt(),
    4: (28 * msPerFrame).toInt(),
    5: (23 * msPerFrame).toInt(),
    6: (18 * msPerFrame).toInt(),
    7: (13 * msPerFrame).toInt(),
    8: (8 * msPerFrame).toInt(), 
    9: (6 * msPerFrame).toInt(),
    10: (5 * msPerFrame).toInt(),
    11: (5 * msPerFrame).toInt(),
    12: (5 * msPerFrame).toInt(),
    13: (4 * msPerFrame).toInt(),
    14: (4 * msPerFrame).toInt(),
    15: (4 * msPerFrame).toInt(),
    16: (3 * msPerFrame).toInt(),
    17: (3 * msPerFrame).toInt(),
    18: (3 * msPerFrame).toInt(),
    19: (2 * msPerFrame).toInt(),
    20: (2 * msPerFrame).toInt(),
    21: (2 * msPerFrame).toInt(),
    22: (2 * msPerFrame).toInt(),
    23: (2 * msPerFrame).toInt(),
    24: (2 * msPerFrame).toInt(),
    25: (2 * msPerFrame).toInt(),
    26: (2 * msPerFrame).toInt(),
    27: (2 * msPerFrame).toInt(),
    28: (2 * msPerFrame).toInt(),
    29: (msPerFrame).toInt(),
  };

  Tetris() {
    pauseWhenBackgrounded = true;
    globalTimer.start();
    reset();
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
    overlays.add(GameState.start.name);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    setSizes();
  }

  @override
  void render(Canvas canvas) {
    boardBackground.render(canvas, position: Vector2(boardStartingPositionX, boardStartingPositionY), size: Vector2(blockSideLength * 10, blockSideLength * 20));

    drawPieceBox(canvas, nextPiecePositionX, nextPiecePositionY, nextPieceBlockSideLength);
    drawPieceBox(canvas, nextPiecePositionX, nextPiece1PositionY, nextPieceBlockSideLength * .8);
    drawPieceBox(canvas, nextPiecePositionX, nextPiece2PositionY, nextPieceBlockSideLength * .8);
    drawPieceBox(canvas, nextPiecePositionX, nextPiece3PositionY, nextPieceBlockSideLength * .8);

    drawPiece(nextPiecePositionX, nextPiecePositionY, nextPieceBlockSideLength, nextPiece, canvas);
    drawPiece(nextPiecePositionX, nextPiece1PositionY, nextPieceBlockSideLength * .8, nextPiece1, canvas);
    drawPiece(nextPiecePositionX, nextPiece2PositionY, nextPieceBlockSideLength * .8, nextPiece2, canvas);
    drawPiece(nextPiecePositionX, nextPiece3PositionY, nextPieceBlockSideLength * .8, nextPiece3, canvas);

    drawPieceBox(canvas, holdPiecePositionX, holdPiecePositionY, nextPieceBlockSideLength);
    if (holdPiece != null) {
      drawPiece(holdPiecePositionX, holdPiecePositionY, nextPieceBlockSideLength, holdPiece!, canvas);
    }
    

    if (gameState == GameState.playing) {
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

    if (gameState == GameState.playing) {
      drawPiece(boardStartingPositionX + (currentPiece.x * blockSideLength), boardStartingPositionY + (currentPiece.y * blockSideLength), blockSideLength, currentPiece, canvas);
    }

    fpsCount++;
    if (globalTimer.elapsedMilliseconds > lastFPSPollTime + 1000) {
        displayFPS = fpsCount;
        fpsCount = 0;
        lastFPSPollTime = globalTimer.elapsedMilliseconds;
    }
    
    reg.render(canvas, displayFPS.toString(), Vector2.all(0));

    canvas.drawRect(Rect.fromLTWH(scorePositionX - 1, scorePositionY - 1, (nextPieceBlockSideLength * 4) + 2, (nextPieceBlockSideLength * 7) + 2), Paint()..color = Colors.blue);
    canvas.drawRect(Rect.fromLTWH(scorePositionX, scorePositionY, (nextPieceBlockSideLength * 4), (nextPieceBlockSideLength * 7)), Paint()..color = Color(0xFF1C1C84));
    reg.render(canvas, 'SCORE:', Vector2(scorePositionX, scorePositionY));
    reg.render(canvas, score.toString(), Vector2(scorePositionX, scorePositionY + 15));
    reg.render(canvas, 'Lines:', Vector2(linesClearedPositionX, linesClearedPositionY));
    reg.render(canvas, totalLinesCleared.toString(), Vector2(linesClearedPositionX, linesClearedPositionY + 15));
    reg.render(canvas, 'Level:', Vector2(levelClearedPositionX, levelClearedPositionY));
    reg.render(canvas, level.toString(), Vector2(levelClearedPositionX, levelClearedPositionY + 15));

    if (statusMessage != null) {
      reg.render(canvas, statusMessage!, Vector2(statusPositionX, statusPositionY));

      if (globalTimer.elapsedMilliseconds > lastStatusTime + 3000) {
        statusMessage = null;
      }
    }

    super.render(canvas);
  }

  void drawPieceBox(Canvas canvas, double startX, double startY, double sideLength) {
    canvas.drawRect(Rect.fromLTWH(startX - 1, startY - 1, (sideLength * 4) + 2, (sideLength * 4) + 2), Paint()..color = Colors.blue);
    canvas.drawRect(Rect.fromLTWH(startX, startY, (sideLength * 4), (sideLength * 4)), Paint()..color = Color(0xFF1C1C84));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (gameState == GameState.playing) {
      if (speed == 0) {
        speed = levelsToSpeeds[min(29, level)]!.toInt();
      }
      if (globalTimer.elapsedMilliseconds > lastPieceDroppedTime + speed) {
        down(false);
        lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
      }
    }
    else if (gameState == GameState.gameOver ){
      if (screenWipeIndex >= 0) {
        
        if (globalTimer.elapsedMilliseconds > lastWipeTime + 150) {
          for (int x = 0; x < 10; x++) {
            board[x][screenWipeIndex] = PieceType.empty;
          }

          screenWipeIndex--;
          lastWipeTime = globalTimer.elapsedMilliseconds;
        }
      }
      else {
        setGameState(GameState.gameOver);
      }
    }
    
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    if (gameState == GameState.playing) {
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
          rotate(1);
          break;
        case '.':
          rotate(currentPiece.rotations.length - 1);
        case ',':
          rotate(2);
          break;
      }
    }

    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() {
    return Colors.black;
  }

  void reset() {
    board.clear();
    for (int i = 0; i < 10; i++) {
      List<PieceType?> row = [];
      for (int j = 0; j < 20; j++) {
        row.add(null);
      }
      board.add(row);
    }
    tSpin = false;
    screenWipeIndex = 19;
    statusMessage = null;
    tetrisCleared = false;
    hasHeldAPiece = false;
    lastWipeTime = 0;
    lastStatusTime = 0;
    lastPieceDroppedTime = 0;
    lastFPSPollTime = 0;
    speed = 0;
    score = 0;
    level = 0;
    totalLinesCleared = 0;
    holdPiece = null;
    Piece.pieces.clear();
    currentPiece = Piece.getPiece();
    nextPiece = Piece.getPiece();
    nextPiece1 = Piece.getPiece();
    nextPiece2 = Piece.getPiece();
    nextPiece3 = Piece.getPiece();

    globalTimer.reset();
  }

  void setGameState(GameState gs) {
    gameState = gs;

    switch (gameState) {
      case GameState.gameOver:
        overlays.add(GameState.gameOver.name);
        break;
      case GameState.playing:
        overlays.clear();
        reset();
        break;
      case GameState.start:
        overlays.add(GameState.start.name);
    }
  }

  void setStatus(String status) {
    statusMessage = status;
    lastStatusTime = globalTimer.elapsedMilliseconds;
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

    nextPiecePositionX = boardStartingPositionX + (blockSideLength * 10) + 10;
    nextPiecePositionY = boardStartingPositionY + 20;
    nextPieceBlockSideLength = blockSideLength * .7;

    nextPiece1PositionY = nextPiecePositionY + (nextPieceBlockSideLength * 4) + 20;
    nextPiece2PositionY = nextPiecePositionY + (nextPieceBlockSideLength * 4 + (nextPieceBlockSideLength * 4 * .8)) + 40;
    nextPiece3PositionY = nextPiecePositionY + (nextPieceBlockSideLength * 4 + (nextPieceBlockSideLength * 8* .8)) + 60;

    holdPiecePositionX = 10;
    holdPiecePositionY = boardStartingPositionY + 20;

    scorePositionX = 10;
    scorePositionY = holdPiecePositionY + (nextPieceBlockSideLength * 4) + 20;

    linesClearedPositionX = 10;
    linesClearedPositionY = scorePositionY + 60;

    levelClearedPositionX = 10;
    levelClearedPositionY = linesClearedPositionY + 60;

    statusPositionX = 10;
    statusPositionY = levelClearedPositionY + 60;
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

  void rotate(int rotationStateMutation) {
    int oldRotationState = currentPiece.rotationState;
    currentPiece.rotationState = (currentPiece.rotationState + rotationStateMutation) % currentPiece.rotations.length;

    if (checkCollision(currentPiece.x, currentPiece.y)) {
      currentPiece.rotationState = oldRotationState;
    }
    else {
      if (currentPiece.pieceType == PieceType.t && currentPiece.rotationState == 0) {
        if (oldRotationState == 1) {
          tSpin = 
            board[currentPiece.x + 2][currentPiece.y] != null && 
            board[currentPiece.x][currentPiece.y + 2] != null && 
            board[currentPiece.x + 2][currentPiece.y + 2] != null;
        }
        else if (oldRotationState == 3) {
          tSpin = 
            board[currentPiece.x][currentPiece.y] != null && 
            board[currentPiece.x][currentPiece.y + 2] != null && 
            board[currentPiece.x + 2][currentPiece.y + 2] != null;
        }
      }
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
      holdPiece?.rotationState = 0;

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
      level = totalLinesCleared ~/ 10;
      
      speed = levelsToSpeeds[min(29, level)]!.toInt();
      setStatusAndScoreAfterLineClear(linesCleared);

      tetrisCleared = linesCleared == 4 || (tSpin && linesCleared == 2);
    }
    else {
      if (tSpin) {
        setStatus('T-Spin!');
      }
    }
  }

  void setStatusAndScoreAfterLineClear(int linesCleared) {
    double multiplier = 1;
    multiplier *= tSpin ? 12 : 1;
    multiplier *= (tetrisCleared && linesCleared == 4) ? 2 : 1;

    if (linesCleared == 1) {
      if (tSpin) {
        setStatus('T-Spin Single!');
      }
      else {
        setStatus('Single!');
      }
      score += (40 * (level + 1) * multiplier).toInt();
    }
    else if (linesCleared == 2) {
      if (tSpin) {
        if (tetrisCleared) {
          setStatus('Back-to-back T-Spin!');
        }
        else {
          setStatus('T-Spin Double!!');
        }
      }
      else {
        setStatus('Double!!');
      }
      score += (100 * (level + 1) * multiplier).toInt();
    }
    else if (linesCleared == 3) {
      setStatus('Triple!!!');
      score += (300 * (level + 1) * multiplier).toInt();
    }
    else if (linesCleared == 4) {
      if (tetrisCleared) {
        setStatus('Back-to-back Tetris!');
      }
      else {
        setStatus('Tetris!!!!');
      }
      score += (1200 * (level + 1) * multiplier).toInt();
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
    if (checkCollision(currentPiece.x, currentPiece.y)) {
      gameState = GameState.gameOver;
    }
  }

  void hardDrop() {
    while (moveDirection(GameInput.down)) {
      score += 10;
    }
    afterDropCollision();
    tSpin = false;
    lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
  }

  void down(bool isHoldingDown) {

    if (!moveDirection(GameInput.down)) {
      afterDropCollision();
    }
    else {
      if (isHoldingDown) {
        score += 10;
      }
    }
    tSpin = false;
    lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
  }
}