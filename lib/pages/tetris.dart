import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttris/resources/game_input.dart';
import 'package:fluttris/resources/piece.dart';

class Tetris extends StatefulWidget {
  const Tetris({super.key});

  @override
  State<Tetris> createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  int score = 0;
  int totalLinesCleared = 0;
  bool hasHeldAPiece = false;
  late Piece currentPiece;
  late Piece nextPiece; 
  late Piece nextPiece1; 
  late Piece nextPiece2; 
  late Piece nextPiece3; 
  Piece? holdPiece;
  List<List<Color>> board = [];
  Stopwatch globalTimer = Stopwatch();
  int lastPieceDroppedTime = 0;
  bool isPlaying = true;
  late Future<void> gameTask;
  double boxHeight = 0;
  int lastFPSPollTime = 0;
  int displayFPS = 0;
  int fpsCount = 0;
  

  _TetrisState() {
    globalTimer.start();

    for (int i = 0; i < 20; i++) {
      List<Color> row = [];
      for (int j = 0; j < 10; j++) {
        row.add(Colors.grey);
      }
      board.add(row);
    }

    currentPiece = Piece.getPiece();
    nextPiece = Piece.getPiece();
    nextPiece1 = Piece.getPiece();
    nextPiece2 = Piece.getPiece();
    nextPiece3 = Piece.getPiece();

    gameTask = game();
  }

  @override
  Widget build(BuildContext context) {
    boxHeight = MediaQuery.sizeOf(context).height / 20;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildPieceDisplay(holdPiece, boxHeight * .7)
              ],
            ),
          ),
          buildBoard(),
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                buildPieceDisplay(nextPiece, boxHeight * .7),
                Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 5), child: buildPieceDisplay(nextPiece1, boxHeight *.5)),
                Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5), child: buildPieceDisplay(nextPiece2, boxHeight *.5)),
                Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5), child: buildPieceDisplay(nextPiece3, boxHeight *.5)),
                Text(displayFPS.toString())
              ],
            ),
          )
        ],
      )
    );
  }

  Future<void> game() async {
    await Future.delayed(Duration(seconds: 1));
    while (isPlaying) {
      if (globalTimer.elapsedMilliseconds > lastPieceDroppedTime + (1000 - (5 * totalLinesCleared))) {
        down(false);
        lastPieceDroppedTime = globalTimer.elapsedMilliseconds;
      }

      if (globalTimer.elapsedMilliseconds > lastFPSPollTime + 1000) {
        displayFPS = fpsCount;
        fpsCount = 0;
        lastFPSPollTime = globalTimer.elapsedMilliseconds;
      }

      context.visitAncestorElements((e) {
        e.markNeedsBuild();
        return true;
      });

      setState(() {
        
      });

      fpsCount++;
    }
  }

  Widget buildBoard() {
    List<Row> rows = [];

    for (List<Color> row in board) {
      rows.add(Row(children: row.map((Color color) => buildBlock(color, boxHeight)).toList()));
    }

    return SizedBox(
      width: boxHeight * 10,
      height: boxHeight * 20,
      child: Column(
        children: rows
      ),
    );
  }

  Widget buildPieceDisplay(Piece? piece, double sideLength) {
    List<Row> rows = [];
    for (int i = 0; i < 4; i++) {
      List<Widget> row = [];
      for (int j = 0; j < 4; j++) {
        if (piece != null && piece.rotations[piece.rotationState] & (0x8000 >> (j + (i * 4))) > 0) {
          row.add(buildBlock(piece.pieceColor, sideLength));
        }
        else {
          row.add(SizedBox(width: sideLength, height: sideLength));
        }
      }
      rows.add(Row(children: row));
    }

    return Container(
      height: (sideLength * 4) + 30,
      width: (sideLength * 4) + 30,
      color: const Color.fromARGB(150, 24, 23, 23),
      child: Center(child: SizedBox(width: sideLength * 4, height: sideLength * 4, child: Column(children: rows))),
    );
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
      b = b | (board[y][x] != Colors.grey);
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

  void rotateLeft() {
    int oldRotationState = currentPiece.rotationState;
    currentPiece.rotationState = (currentPiece.rotationState + currentPiece.rotations.length - 1) % currentPiece.rotations.length;

    if (checkCollision(currentPiece.x, currentPiece.y)) {
      currentPiece.rotationState = oldRotationState;
    }
  }

  void rotateRight() {
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
        board[currentPiece.y + (iterations % 4)][currentPiece.x + (iterations ~/ 4)] = currentPiece.pieceColor;
      }
      iterations++;
    }
  }

  void removeLine(int y) {
    do {
      for (int x = 0; x < 10; x++) {
        board[x][y] = (y == 0) ? Colors.grey : board[x][y - 1];
      }
    } while (y != 0);
  }

  void removeLines() {
    int linesCleared = 0;

    for (int y = 19; y > 0; y--) {
      bool isLineComplete = true;
      for (int x = 0; x < 10; x++) {
        isLineComplete &= !(board[y][x] == Colors.grey);
      }

      if (isLineComplete) {
        removeLine(y);
        linesCleared++;
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