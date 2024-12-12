import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:fluttris/resources/game_controls.dart';
import 'package:fluttris/resources/game_state.dart';
import 'package:fluttris/resources/level.dart';
import 'package:fluttris/resources/piece.dart';
import 'package:fluttris/resources/piece_type.dart';

class Tetris extends FlameGame with HasPerformanceTracker {
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
  GameState gameState = GameState.playing;
  TextPaint reg = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.white.color));
  final GameControls gameControls;

  Tetris({required this.gameControls}) {
    gameControls.down = down;
    gameControls.rotate = rotate;
    gameControls.pause = () {};
    gameControls.hold = hold;
    gameControls.moveLeft = moveLeft;
    gameControls.moveRight = moveRight;
    gameControls.hardDrop = hardDrop;
    gameControls.reset = reset;

    globalTimer.start();
    reset();
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    setSizes();
    // load in the few images that'll be used.
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
    // Render the background of the board
    boardBackground.render(canvas, position: Vector2(boardStartingPositionX, boardStartingPositionY), size: Vector2(blockSideLength * 10, blockSideLength * 20));

    // draw the next piece backing boxes.
    drawPieceBox(canvas, nextPiecePositionX, nextPiecePositionY, nextPieceBlockSideLength);
    drawPieceBox(canvas, nextPiecePositionX, nextPiece1PositionY, nextPieceBlockSideLength * .8);
    drawPieceBox(canvas, nextPiecePositionX, nextPiece2PositionY, nextPieceBlockSideLength * .8);
    drawPieceBox(canvas, nextPiecePositionX, nextPiece3PositionY, nextPieceBlockSideLength * .8);

    // draw the next piece previews
    drawPiece(nextPiecePositionX, nextPiecePositionY, nextPieceBlockSideLength, nextPiece, canvas);
    drawPiece(nextPiecePositionX, nextPiece1PositionY, nextPieceBlockSideLength * .8, nextPiece1, canvas);
    drawPiece(nextPiecePositionX, nextPiece2PositionY, nextPieceBlockSideLength * .8, nextPiece2, canvas);
    drawPiece(nextPiecePositionX, nextPiece3PositionY, nextPieceBlockSideLength * .8, nextPiece3, canvas);

    // draw the hold piece backing box and then draw the hold piece if the player has one held.
    drawPieceBox(canvas, holdPiecePositionX, holdPiecePositionY, nextPieceBlockSideLength);
    if (holdPiece != null) {
      drawPiece(holdPiecePositionX, holdPiecePositionY, nextPieceBlockSideLength, holdPiece!, canvas);
    }
    
    // Render the shadow of the piece that is currently in play
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
    
    // Render the block of the pieces that have been locked into place.
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

    // Draw the current piece that is in play
    if (gameState == GameState.playing) {
      drawPiece(boardStartingPositionX + (currentPiece.x * blockSideLength), boardStartingPositionY + (currentPiece.y * blockSideLength), blockSideLength, currentPiece, canvas);
    }

    // FPS counter
    fpsCount++;
    if (globalTimer.elapsedMilliseconds > lastFPSPollTime + 1000) {
        displayFPS = fpsCount;
        fpsCount = 0;
        lastFPSPollTime = globalTimer.elapsedMilliseconds;
    }
    
    // draw fps count
    reg.render(canvas, displayFPS.toString(), Vector2.all(0));

    // draw the score/lines/level data.
    canvas.drawRect(Rect.fromLTWH(scorePositionX - 1, scorePositionY - 1, (nextPieceBlockSideLength * 4) + 2, scorePositionY + 72), Paint()..color = Colors.blue);
    canvas.drawRect(Rect.fromLTWH(scorePositionX, scorePositionY, (nextPieceBlockSideLength * 4), scorePositionY + 70), Paint()..color = Color(0xFF1C1C84));
    reg.render(canvas, 'SCORE:', Vector2(scorePositionX, scorePositionY));
    reg.render(canvas, score.toString(), Vector2(scorePositionX, scorePositionY + 15));
    reg.render(canvas, 'Lines:', Vector2(linesClearedPositionX, linesClearedPositionY));
    reg.render(canvas, totalLinesCleared.toString(), Vector2(linesClearedPositionX, linesClearedPositionY + 15));
    reg.render(canvas, 'Level:', Vector2(levelClearedPositionX, levelClearedPositionY));
    reg.render(canvas, level.toString(), Vector2(levelClearedPositionX, levelClearedPositionY + 15));

    // If there is a status message, then go ahead and draw it!
    if (statusMessage != null) {
      reg.render(canvas, statusMessage!, Vector2(statusPositionX, statusPositionY));

      // clear the message after 3 sec.
      if (globalTimer.elapsedMilliseconds > lastStatusTime + 3000) {
        statusMessage = null;
      }
    }

    super.render(canvas);
  }

  /// draws the backing box for the hold and next pieces.
  void drawPieceBox(Canvas canvas, double startX, double startY, double sideLength) {
    canvas.drawRect(Rect.fromLTWH(startX - 1, startY - 1, (sideLength * 4) + 2, (sideLength * 4) + 2), Paint()..color = Colors.blue);
    canvas.drawRect(Rect.fromLTWH(startX, startY, (sideLength * 4), (sideLength * 4)), Paint()..color = Color(0xFF1C1C84));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    gameControls.checkForKeyPresses(gameState, currentPiece);

    if (gameState == GameState.playing) {

      // During startup there wasn't a good place for this, because I eventually want the user to select levels...
      if (speed == 0) {
        speed = Level.levelsToSpeeds[min(29, level)]!;
      }

      // if the timer elapses the time + levelSpeed then drop the piece down one block.
      if (globalTimer.elapsedMilliseconds > lastPieceDroppedTime + speed) {
        down(false);
        lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
      }

    }
    else if (gameState == GameState.gameOver) {
      if (screenWipeIndex >= 0) { // while we are still not at the top of the board...
        
        // Every 150ms add a row of black blocks to the board.
        // This makes it look like the board is being wiped.
        if (globalTimer.elapsedMilliseconds > lastWipeTime + 150) {
          for (int x = 0; x < 10; x++) {
            board[x][screenWipeIndex] = PieceType.empty;
          }

          screenWipeIndex--;
          lastWipeTime = globalTimer.elapsedMilliseconds;
        }
      }
      else if (gameState == GameState.results) {

      }
      else { // animation finished, so call setGameState to refresh the overlays.
        gameState = GameState.results;
      }
    }
  }

  @override
  Color backgroundColor() {
    return Colors.black;
  }

  // Reset the game, so the user can play a new round.
  void reset() {

    // clear and reset the board
    board.clear();
    for (int i = 0; i < 10; i++) {
      List<PieceType?> row = [];
      for (int j = 0; j < 20; j++) {
        row.add(null);
      }
      board.add(row);
    }

    // reset important state information.
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
    Piece.pieces.clear(); // clear this to get rid of stale pieces.
    currentPiece = Piece.getPiece();
    nextPiece = Piece.getPiece();
    nextPiece1 = Piece.getPiece();
    nextPiece2 = Piece.getPiece();
    nextPiece3 = Piece.getPiece();

    // Reset the timer as well since I reset the time variables.
    globalTimer.reset();
    gameState = GameState.playing;
  }

  /// Setter function for the status messages.
  void setStatus(String status) {
    statusMessage = status;
    lastStatusTime = globalTimer.elapsedMilliseconds;
  }
  
  /// Draw the piece given at the coords given.
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

  /// everytime the game window is resized we recalculate all these values that control how and where things are drawn.
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

  // Try to move the Piece left
  bool moveLeft() {
    if (!checkCollision(currentPiece.x - 1, currentPiece.y)) {
      currentPiece.x--;
      return true;
    }
    return false;
  }

  // Try to move the Piece right
  bool moveRight() {
    if (!checkCollision(currentPiece.x + 1, currentPiece.y)) {
      currentPiece.x++;
      return true;
    }
    return false;
  }
  
  // Try to move the Piece down
  bool moveDown() {
    if (!checkCollision(currentPiece.x, currentPiece.y + 1)) {
      currentPiece.y++;
      return true;
    }
    return false;
  }

  // check to see if the currentPiece's given location and rotationState collide with anything on the board.
  // Return true if a collision is found.
  bool checkCollision(int x, int y) {
    bool b = false;
    int iterations = 0;

    while (iterations < 16) {
      if (!b && (currentPiece.getRotationState() & (0x8000 >> iterations)) > 0) {
        b |= areXAndYCoordIllegal(x + (iterations % 4), y + (iterations ~/ 4));
      }
      
      iterations++;
    }

    return b;
  }

  // Return true if the x/y coordinates are out of bounds or if the space is full on the board.
  bool areXAndYCoordIllegal(int x, int y) {
    return (x < 0) || (x >= 10) || (y < 0) || (y >= 20) || (board[x][y] != null);
  }

  // Get the y coordinate of where the drop shadow needs to be.
  int getDropShadowYCoord() {
    int y = currentPiece.y;
    while (!checkCollision(currentPiece.x, y)){
      y++;
    }
    return y - 1;
  }

  // rotate the piece by the desired amount of rotations.
  void rotate(int rotationStateMutation) {
    int oldRotationState = currentPiece.rotationState;
    currentPiece.rotationState = (currentPiece.rotationState + rotationStateMutation) % currentPiece.rotations.length;

    // check to see if the proposed rotation collides with anything.
    if (checkCollision(currentPiece.x, currentPiece.y)) {
      currentPiece.rotationState = oldRotationState; // rotation didn't work out...
    }
    else { // rotation did work out!

      // if the piece is a T-piece and the new rotation is:
      // New T-Spin rotationstate:
      //OOOOO
      //O***O
      //OO*OO
      if (currentPiece.pieceType == PieceType.t && currentPiece.rotationState == 0) {

        // If the old rotationstate is:
        //OX*OO
        //OO**O
        //OX*XO
        // The X's need to be filled in for it to count as a T-Spin
        if (oldRotationState == 1) {
          tSpin = 
            board[currentPiece.x + 2][currentPiece.y] != null && 
            board[currentPiece.x][currentPiece.y + 2] != null && 
            board[currentPiece.x + 2][currentPiece.y + 2] != null;
        }
        // If the old rotationstate is:
        //OO*XO
        //O**OO
        //OX*XO
        // The X's need to be filled in for it to count as a T-Spin
        else if (oldRotationState == 3) {
          tSpin = 
            board[currentPiece.x][currentPiece.y] != null && 
            board[currentPiece.x][currentPiece.y + 2] != null && 
            board[currentPiece.x + 2][currentPiece.y + 2] != null;
        }
      }
    }
  }

  /// Move the current piece to the hold box if we haven't done it yet.
  void hold() {
    if (!hasHeldAPiece) {   // can only hold a piece once per new piece.
      hasHeldAPiece = true;

      // First time holding a piece.
      if (holdPiece != null) {
        Piece temp = holdPiece!;
        holdPiece = currentPiece;
        currentPiece = temp;
      }
      else { // Next time holding a piece.
        holdPiece = currentPiece;
        currentPiece = nextPiece;
        nextPiece = nextPiece1;
        nextPiece1 = nextPiece2;
        nextPiece2 = nextPiece3;
        nextPiece3 = Piece.getPiece();
      }

      // reset the new held piece to the top of the board and reset the rotation state.
      holdPiece?.x = 4;
      holdPiece?.y = 0;
      holdPiece?.rotationState = 0;

      // reset drop timer.
      lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
    }
  }

  // Take current piece and add its four blocks to the board.
  void commitPieceToBoard() {
    int iterations = 0;
    
    while (iterations < 16) {
      if ((currentPiece.getRotationState() & (0x8000 >> iterations)) > 0) {
        board[currentPiece.x + (iterations % 4)][currentPiece.y + (iterations ~/ 4)] = currentPiece.pieceType;
      }
      iterations++;
    }
  }

  /// remove a specified line, and move all the rest of the blocks from lower y vals down.
  void removeLine(int y) {
    do {
      for (int x = 0; x < 10; x++) {
        board[x][y] = (y == 0) ? null : board[x][y - 1];
      }
      y--;
    } while (y >= 0);
  }

  // Check the entire board for lines to remove.
  void removeLines() {
    int linesCleared = 0;

    // loop backwards through the board.
    for (int y = 19; y >= 0; y--) {
      // check for complete line.
      bool isLineComplete = true;
      for (int x = 0; x < 10; x++) {
        isLineComplete &= !(board[x][y] == null);
      }

      // if line is complete remove it then add a cleared line and test the line again.
      if (isLineComplete) {
        removeLine(y);
        linesCleared++;
        y++;            // increment the y coordinate since we just shifted a row down.
      }
    }

    if (linesCleared > 0) {

      totalLinesCleared += linesCleared;
      level = totalLinesCleared ~/ 10;
      
      // Reset the speed to what the level's is.
      speed = Level.levelsToSpeeds[min(29, level)]!.toInt();

      // Set status and update score.
      setStatusAndScoreAfterLineClear(linesCleared);

      // if 4 lines are cleared at once or if we have a T-Spin double set the bonus points bool to true;
      tetrisCleared = linesCleared == 4 || (tSpin && linesCleared == 2);
    }
    else { // no lines cleared, but look for a T-Spin. This doesn't earn points, but nothing compares the dopamine rush of getting a T-Spin!
      if (tSpin) {
        setStatus('T-Spin!');
      }
    }
  }

  // Set the status and the score if we've cleared line(s).
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

  // The piece has tried to move down and can't so we get to lock it in place!
  void afterDropCollision() {
    // move current piece to the board.
    commitPieceToBoard();
    // check for lines to remove.
    removeLines();
    // Move next pieces
    currentPiece = nextPiece;
    nextPiece = nextPiece1;
    nextPiece1 = nextPiece2;
    nextPiece2 = nextPiece3;
    nextPiece3 = Piece.getPiece();

    // reset the held piece flag.
    hasHeldAPiece = false;

    // We've dropped a new piece and it immediately has a collision. 
    // Game Over!
    if (checkCollision(currentPiece.x, currentPiece.y)) {
      gameState = GameState.gameOver;
    }
  }

  // try to drop the current piece to the bottom of the board until it collides with another piece or the bottom.
  void hardDrop() {
    while (moveDown()) {
      score += 10;
    }
    afterDropCollision();
    tSpin = false;
    lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
  }

  // try to move the piece down one block.
  void down(bool isHoldingDown) {

    if (!moveDown()) {
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