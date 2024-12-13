import 'dart:async';
import 'dart:math';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fluttris/pages/home_page.dart';
import 'package:fluttris/pages/pause_page.dart';
import 'package:fluttris/resources/control_type.dart';
import 'package:fluttris/resources/game_controls.dart';
import 'package:fluttris/resources/game_renderer.dart';
import 'package:fluttris/resources/game_state.dart';
import 'package:fluttris/resources/game_stats.dart';
import 'package:fluttris/resources/level.dart';
import 'package:fluttris/resources/piece.dart';
import 'package:fluttris/resources/piece_type.dart';

class Tetris extends FlameGame with HasPerformanceTracker {

  final GameControls gameControls;
  final int seedLevel;
  final bool isOnline;
  final GameRenderer gameRenderer = GameRenderer();
  final List<List<PieceType?>> _board = [];

  late BuildContext context;
  late GameStats stats;

  Piece _currentPiece = Piece.getPiece();
  Piece _nextPiece = Piece.getPiece(); 
  Piece _nextPiece1 = Piece.getPiece(); 
  Piece _nextPiece2 = Piece.getPiece(); 
  Piece _nextPiece3 = Piece.getPiece(); 
  Piece? _holdPiece;
  bool _hasHeldAPiece = false;
  bool _tetrisCleared = false;
  bool _tSpin = false;
  int _lastFPSPollTime = 0;
  int _displayFPS = 0;
  int _fpsCount = 0;
  int _lastPieceDroppedTime = 0;
  int _speed = 0;
  int _screenWipeIndex = 19;
  int _lastWipeTime = 0;
  GameState _gameState = GameState.playing;

  Tetris({required this.gameControls, required this.seedLevel, required this.isOnline}) {
    gameControls.down = _down;
    gameControls.rotate = _rotate;
    gameControls.hold = hold;
    gameControls.moveLeft = moveLeft;
    gameControls.moveRight = moveRight;
    gameControls.hardDrop = hardDrop;
    gameControls.reset = _reset;
    gameControls.pause = _pause;

    _reset();
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    await gameRenderer.loadAssets;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    gameRenderer.reset(size);
  }

  @override
  void render(Canvas canvas) {
    gameRenderer.renderBoardBackground(canvas);
    // Render the blocks of the pieces that have been locked into place.
    gameRenderer.renderPieces(canvas, _currentPiece, _nextPiece, _nextPiece1, _nextPiece2, _nextPiece3, _holdPiece);
    gameRenderer.renderBoard(canvas, _board);
    
    // Render the shadow of the piece that is currently in play
    if (_gameState == GameState.playing) {
      gameRenderer.renderPieceShadow(canvas, _currentPiece.x, _getDropShadowYCoord(), _currentPiece.getRotationState());
    }

    // FPS counter
    _fpsCount++;
    if (HomePage.globalTimer.elapsedMilliseconds > _lastFPSPollTime + 1000) {
        _displayFPS = _fpsCount;
        _fpsCount = 0;
        _lastFPSPollTime = HomePage.globalTimer.elapsedMilliseconds;
    }
    
    gameRenderer.renderFPS(canvas, _displayFPS);

    gameRenderer.renderStats(canvas, stats);

    super.render(canvas);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    

    switch (_gameState) {
      case GameState.playing:
        gameControls.checkForKeyPresses(_gameState, _currentPiece);

        // During startup there wasn't a good place for this, because I eventually want the user to select levels...
        if (_speed == 0) {
          _speed = Level.levelsToSpeeds[min(29, stats.level)]!;
        }

        // if the timer elapses the time + levelSpeed then drop the piece down one block.
        if (HomePage.globalTimer.elapsedMilliseconds > _lastPieceDroppedTime + _speed) {
          _down(false);
          _lastPieceDroppedTime = HomePage.globalTimer.elapsedMilliseconds;
        }
        break;
      case GameState.gameOver:
        if (_screenWipeIndex >= 0) { // while we are still not at the top of the board...
        
          // Every 150ms add a row of black blocks to the board.
          // This makes it look like the board is being wiped.
          if (HomePage.globalTimer.elapsedMilliseconds > _lastWipeTime + 150) {
            for (int x = 0; x < 10; x++) {
              _board[x][_screenWipeIndex] = PieceType.empty;
            }

            _screenWipeIndex--;
            _lastWipeTime = HomePage.globalTimer.elapsedMilliseconds;
          }
        }
        else { // animation finished, so call setGameState to refresh the overlays.
          _gameState = GameState.results;
        }
        break;
      case GameState.pause:
        break;
      case GameState.results:

        break;
      case GameState.start:
        break;
    }
  }

  @override
  Color backgroundColor() {
    return Colors.black;
  }

  // Try to move the Piece left
  void moveLeft() {
    if (!_checkCollision(_currentPiece.x - 1, _currentPiece.y) && _gameState == GameState.playing) {
      _currentPiece.x--;
    }
  }

  // Try to move the Piece right
  void moveRight() {
    if (!_checkCollision(_currentPiece.x + 1, _currentPiece.y) && _gameState == GameState.playing) {
      _currentPiece.x++;
    }
  }

  void rotate(ControlType ct) {
    if (_gameState == GameState.playing) {
      if (ct == ControlType.flip) {
        _rotate(2);
      }
      else if (ct == ControlType.rotateRight) {
        _rotate(1);
      }
      else if (ct == ControlType.rotateLeft) {
        _rotate(_currentPiece.rotations.length - 1);
      }
    }
  }

  /// Move the current piece to the hold box if we haven't done it yet.
  void hold() {
    if (!_hasHeldAPiece && _gameState == GameState.playing) {   // can only hold a piece once per new piece.
      _hasHeldAPiece = true;

      // First time holding a piece.
      if (_holdPiece != null) {
        Piece temp = _holdPiece!;
        _holdPiece = _currentPiece;
        _currentPiece = temp;
      }
      else { // Next time holding a piece.
        _holdPiece = _currentPiece;
        _currentPiece = _nextPiece;
        _nextPiece = _nextPiece1;
        _nextPiece1 = _nextPiece2;
        _nextPiece2 = _nextPiece3;
        _nextPiece3 = Piece.getPiece();
      }

      // reset the new held piece to the top of the board and reset the rotation state.
      _holdPiece?.x = 4;
      _holdPiece?.y = 0;
      _holdPiece?.rotationState = 0;

      // reset drop timer.
      _lastPieceDroppedTime = HomePage.globalTimer.elapsedMilliseconds;
    }
  }

  // try to drop the current piece to the bottom of the board until it collides with another piece or the bottom.
  void hardDrop() {
    while (_moveDown()) {
      stats.score += 10 * stats.level;
    }
    _afterDropCollision();
    _tSpin = false;
    _lastPieceDroppedTime = HomePage.globalTimer.elapsedMilliseconds;
  }

  void down() 
  { 
    if (_gameState == GameState.playing) 
    { 
      _down(true); 
    } 
  }

  void _pause() {
    _gameState = GameState.pause;
    Navigator.push(context, MaterialPageRoute(builder: (context) => PausePage(options: gameControls.options, resume: () { _gameState = GameState.playing; }), settings: RouteSettings(name: PausePage.routeName)));
  }

  // Reset the game, so the user can play a new round.
  void _reset() {

    // clear and reset the board
    _board.clear();
    for (int i = 0; i < 10; i++) {
      List<PieceType?> row = [];
      for (int j = 0; j < 20; j++) {
        row.add(null);
      }
      _board.add(row);
    }

    // reset important state information.
    _tSpin = false;
    _screenWipeIndex = 19;
    _tetrisCleared = false;
    _hasHeldAPiece = false;
    _lastWipeTime = 0;
    _lastPieceDroppedTime = 0;
    _lastFPSPollTime = 0;
    _speed = 0;
    stats = GameStats(seedLevel: seedLevel);
    _holdPiece = null;
    Piece.resetBag(); // clear this to get rid of stale pieces.
    _currentPiece = Piece.getPiece();
    _nextPiece = Piece.getPiece();
    _nextPiece1 = Piece.getPiece();
    _nextPiece2 = Piece.getPiece();
    _nextPiece3 = Piece.getPiece();

    _gameState = GameState.playing;
  }
  
  // Try to move the Piece down
  bool _moveDown() {
    if (!_checkCollision(_currentPiece.x, _currentPiece.y + 1)) {
      _currentPiece.y++;
      return true;
    }
    return false;
  }

  // check to see if the currentPiece's given location and rotationState collide with anything on the board.
  // Return true if a collision is found.
  bool _checkCollision(int x, int y) {
    bool b = false;
    int iterations = 0;

    while (iterations < 16) {
      if (!b && (_currentPiece.getRotationState() & (0x8000 >> iterations)) > 0) {
        b |= _areXAndYCoordIllegal(x + (iterations % 4), y + (iterations ~/ 4));
      }
      
      iterations++;
    }

    return b;
  }

  // Return true if the x/y coordinates are out of bounds or if the space is full on the board.
  bool _areXAndYCoordIllegal(int x, int y) {
    return (x < 0) || (x >= 10) || (y < 0) || (y >= 20) || (_board[x][y] != null);
  }

  // Get the y coordinate of where the drop shadow needs to be.
  int _getDropShadowYCoord() {
    int y = _currentPiece.y;
    while (!_checkCollision(_currentPiece.x, y)){
      y++;
    }
    return y - 1;
  }

  // rotate the piece by the desired amount of rotations.
  void _rotate(int rotationStateMutation) {
    int oldRotationState = _currentPiece.rotationState;
    _currentPiece.rotationState = (_currentPiece.rotationState + rotationStateMutation) % _currentPiece.rotations.length;

    // check to see if the proposed rotation collides with anything.
    if (_checkCollision(_currentPiece.x, _currentPiece.y)) {
      _currentPiece.rotationState = oldRotationState; // rotation didn't work out...
    }
    else { // rotation did work out!

      // if the piece is a T-piece and the new rotation is:
      // New T-Spin rotationstate:
      //OOOOO
      //O***O
      //OO*OO
      if (_currentPiece.pieceType == PieceType.t && _currentPiece.rotationState == 0) {

        // If the old rotationstate is:
        //OX*OO
        //OO**O
        //OX*XO
        // The X's need to be filled in for it to count as a T-Spin
        if (oldRotationState == 1) {
          _tSpin = 
            _board[_currentPiece.x + 2][_currentPiece.y] != null && 
            _board[_currentPiece.x][_currentPiece.y + 2] != null && 
            _board[_currentPiece.x + 2][_currentPiece.y + 2] != null;
        }
        // If the old rotationstate is:
        //OO*XO
        //O**OO
        //OX*XO
        // The X's need to be filled in for it to count as a T-Spin
        else if (oldRotationState == 3) {
          _tSpin = 
            _board[_currentPiece.x][_currentPiece.y] != null && 
            _board[_currentPiece.x][_currentPiece.y + 2] != null && 
            _board[_currentPiece.x + 2][_currentPiece.y + 2] != null;
        }
      }
    }
  }

  // Take current piece and add its four blocks to the board.
  void _commitPieceToBoard() {
    int iterations = 0;
    
    while (iterations < 16) {
      if ((_currentPiece.getRotationState() & (0x8000 >> iterations)) > 0) {
        _board[_currentPiece.x + (iterations % 4)][_currentPiece.y + (iterations ~/ 4)] = _currentPiece.pieceType;
      }
      iterations++;
    }
  }

  /// remove a specified line, and move all the rest of the blocks from lower y vals down.
  void _removeLine(int y) {
    do {
      for (int x = 0; x < 10; x++) {
        _board[x][y] = (y == 0) ? null : _board[x][y - 1];
      }
      y--;
    } while (y >= 0);
  }

  // Check the entire board for lines to remove.
  void _removeLines() {
    int linesCleared = 0;

    // loop backwards through the board.
    for (int y = 19; y >= 0; y--) {
      // check for complete line.
      bool isLineComplete = true;
      for (int x = 0; x < 10; x++) {
        isLineComplete &= !(_board[x][y] == null);
      }

      // if line is complete remove it then add a cleared line and test the line again.
      if (isLineComplete) {
        _removeLine(y);
        linesCleared++;
        y++;            // increment the y coordinate since we just shifted a row down.
      }
    }

    if (linesCleared > 0) {
      // Set status and update score.
      stats.updateStatsAfterLineClear(linesCleared, _tSpin, _tetrisCleared);
      // Reset the speed to what the level's is.
      _speed = Level.levelsToSpeeds[min(29, stats.level)]!.toInt();
      // if 4 lines are cleared at once or if we have a T-Spin double set the bonus points bool to true;
      _tetrisCleared = linesCleared == 4 || (_tSpin && linesCleared == 2);
    }
  }


  // The piece has tried to move down and can't so we get to lock it in place!
  void _afterDropCollision() {
    // move current piece to the board.
    _commitPieceToBoard();
    // check for lines to remove.
    _removeLines();
    // Move next pieces
    _currentPiece = _nextPiece;
    _nextPiece = _nextPiece1;
    _nextPiece1 = _nextPiece2;
    _nextPiece2 = _nextPiece3;
    _nextPiece3 = Piece.getPiece();

    // reset the held piece flag.
    _hasHeldAPiece = false;

    // We've dropped a new piece and it immediately has a collision. 
    // Game Over!
    if (_checkCollision(_currentPiece.x, _currentPiece.y)) {
      _gameState = GameState.gameOver;
    }
  }

  // try to move the piece down one block.
  void _down(bool isHoldingDown) {

    if (!_moveDown()) {
      _afterDropCollision();
    }
    else {
      if (isHoldingDown) {
        stats.score += 10 * stats.level;
      }
    }
    _tSpin = false;
    _lastPieceDroppedTime = HomePage.globalTimer.elapsedMilliseconds;
  }
}