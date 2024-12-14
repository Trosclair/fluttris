import 'dart:math';
import 'package:flutter/services.dart';
import 'package:fluttris/pages/home_page.dart';
import 'package:fluttris/resources/game_state.dart';
import 'package:fluttris/resources/options.dart';
import 'package:fluttris/resources/piece.dart';

class GameControls {
  final Options options;

  int _dasLeftRightPollingTime = 0;
  int _dasLeftRightChargedTime = 0;
  int _dasLeftRightVelocityTime = 0;

  int _dasRotatePollingTime = 0;
  int _dasRotateChargedTime = 0;
  int _dasRotateVelocityTime = 0;
  
  int _dasDownPollingTime = 0;
  int _dasDownChargedTime = 0;
  int _dasDownVelocityTime = 0;

  bool _isHardDropPressed = false;
  bool _isHoldPressed = false;
  bool _isResetPressed = false;
  bool _isLeftPressed = false;
  bool _isRightPressed = false;
  bool _isDownPressed = false;
  bool _isRotateRightPressed = false;
  bool _isRotateLeftPressed = false;
  bool _isFlipPressed = false;
  bool _isPausedPressed = false;
  
  bool _wasLeftPressedLastTime = false;
  bool _wasRightPressedLastTime = false;
  bool _wasDownPressedLastTime = false;
  bool _wasResetPressedLastTime = false;
  bool _wasHoldPressedLastTime = false;
  bool _wasHardDropPressedLastTime = false;
  bool _wasRotateRightPressedLastTime = false;
  bool _wasRotateLeftPressedLastTime = false;
  bool _wasFlipPressedLastTime = false;

  late Function hardDrop;
  late Function(bool) down;
  late Function moveRight;
  late Function moveLeft;
  late Function(int) rotate;
  late Function pause;
  late Function reset;
  late Function hold;

  GameControls({required this.options}) {
    _dasLeftRightVelocityTime = options.initialDASVelocity;
    _dasRotateVelocityTime = options.initialDASVelocity;
    _dasDownVelocityTime = options.initialDASVelocity;
  }
  
  void checkForKeyPresses(GameState gameState, Piece currentPiece) {
    Iterable<int> keysPressed = HardwareKeyboard.instance.physicalKeysPressed.map((x) => x.usbHidUsage);

    _isResetPressed = keysPressed.where((int x) => x == options.resetBind.key.usbHidUsage).isNotEmpty;
    _isRightPressed = keysPressed.where((int x) => x == options.moveRightBind.key.usbHidUsage).isNotEmpty;
    _isLeftPressed = keysPressed.where((int x) => x == options.moveLeftBind.key.usbHidUsage).isNotEmpty;
    _isRotateLeftPressed = keysPressed.where((int x) => x == options.rotateLeftBind.key.usbHidUsage).isNotEmpty;
    _isRotateRightPressed = keysPressed.where((int x) => x == options.rotateRightBind.key.usbHidUsage).isNotEmpty;
    _isFlipPressed = keysPressed.where((int x) => x == options.flipBind.key.usbHidUsage).isNotEmpty;
    _isHardDropPressed = keysPressed.where((int x) => x == options.hardDropBind.key.usbHidUsage).isNotEmpty;
    _isHoldPressed = keysPressed.where((int x) => x == options.holdBind.key.usbHidUsage).isNotEmpty;
    _isDownPressed = keysPressed.where((int x) => x == options.dropBind.key.usbHidUsage).isNotEmpty;
    _isPausedPressed = keysPressed.where((int x) => x == options.pauseBind.key.usbHidUsage).isNotEmpty;
    
    if (!_wasResetPressedLastTime && _isResetPressed) {
      reset();
      _wasResetPressedLastTime = _isResetPressed;
      return;
    }

    if (!_wasHardDropPressedLastTime && _isHardDropPressed) {
      hardDrop();
      _wasHardDropPressedLastTime = true;
      return;
    }

    if (!_wasHoldPressedLastTime && _isHoldPressed) {
      hold();
      _wasHoldPressedLastTime = true;
      return;
    }

    if (_isPausedPressed) {
      pause();
      return;
    }
    
    if (HomePage.globalTimer.elapsedMilliseconds > _dasLeftRightPollingTime + _dasLeftRightVelocityTime || (!_wasRightPressedLastTime && _isRightPressed) || (!_wasLeftPressedLastTime && _isLeftPressed)) {
      if (_isRightPressed) {
        moveRight();
        _dasLeftRightVelocityTime -= options.dasAccelerationTime;
        _dasLeftRightVelocityTime = max(_dasLeftRightVelocityTime, options.maxVelocity);
        _dasLeftRightPollingTime = HomePage.globalTimer.elapsedMilliseconds; 
      }
      else if (_isLeftPressed) {
        moveLeft();
        _dasLeftRightVelocityTime -= options.dasAccelerationTime;
        _dasLeftRightVelocityTime = max(_dasLeftRightVelocityTime, options.maxVelocity);
        _dasLeftRightPollingTime = HomePage.globalTimer.elapsedMilliseconds; 
      }
    }
            
    if (HomePage.globalTimer.elapsedMilliseconds > _dasDownPollingTime + _dasDownVelocityTime || (!_wasDownPressedLastTime && _isDownPressed)) {
      if (_isDownPressed) {
        down(true);
        _dasDownVelocityTime -= options.dasAccelerationTime;
        _dasDownVelocityTime = max(_dasDownVelocityTime, options.maxVelocity);
        _dasDownPollingTime = HomePage.globalTimer.elapsedMilliseconds; 
      }
    }

    if (HomePage.globalTimer.elapsedMilliseconds > _dasRotatePollingTime + _dasRotateVelocityTime || (!_wasFlipPressedLastTime && _isFlipPressed) || (!_wasRotateLeftPressedLastTime && _isRotateLeftPressed) || (!_wasRotateRightPressedLastTime && _isRotateRightPressed)) {
      if (_isRotateRightPressed) {
        rotate(1);
        _dasRotateVelocityTime -= options.dasAccelerationTime;
        _dasRotateVelocityTime = max(_dasRotateVelocityTime, options.maxVelocity);
        _dasRotatePollingTime = HomePage.globalTimer.elapsedMilliseconds;
      }
      else if (_isRotateLeftPressed) {
        rotate(currentPiece.rotations.length - 1);
        _dasRotateVelocityTime -= options.dasAccelerationTime;
        _dasRotateVelocityTime = max(_dasRotateVelocityTime, options.maxVelocity);
        _dasRotatePollingTime = HomePage.globalTimer.elapsedMilliseconds;
      }
      else if (_isFlipPressed) {
        rotate(2);
        _dasRotateVelocityTime -= options.dasAccelerationTime;
        _dasRotateVelocityTime = max(_dasRotateVelocityTime, options.maxVelocity);
        _dasRotatePollingTime = HomePage.globalTimer.elapsedMilliseconds;
      }
    } 
    
    _wasRightPressedLastTime = _isRightPressed;
    _wasLeftPressedLastTime = _isLeftPressed;
    _wasDownPressedLastTime = _isDownPressed;
    _wasHoldPressedLastTime = _isHoldPressed;
    _wasHardDropPressedLastTime = _isHardDropPressed;
    _wasResetPressedLastTime = _isResetPressed;
    _wasFlipPressedLastTime = _isFlipPressed;
    _wasRotateLeftPressedLastTime = _isRotateLeftPressed;
    _wasRotateRightPressedLastTime = _isRotateRightPressed;
    
    if (_isLeftPressed || _isRightPressed) {
      _dasLeftRightChargedTime = HomePage.globalTimer.elapsedMilliseconds;
    } 

    if (_isRotateLeftPressed || _isRotateRightPressed || _isFlipPressed) {
      _dasRotateChargedTime = HomePage.globalTimer.elapsedMilliseconds;
    }

    if (_isDownPressed) {
      _dasDownChargedTime = HomePage.globalTimer.elapsedMilliseconds;
    }

    if ((HomePage.globalTimer.elapsedMilliseconds > _dasLeftRightChargedTime + options.dasResetTime)) {
      _dasLeftRightChargedTime = HomePage.globalTimer.elapsedMilliseconds;
      _dasLeftRightVelocityTime = options.initialDASVelocity;
    }
    
    if ((HomePage.globalTimer.elapsedMilliseconds > _dasRotateChargedTime + options.dasResetTime)) {
      _dasRotateChargedTime = HomePage.globalTimer.elapsedMilliseconds;
      _dasRotateVelocityTime = options.initialDASVelocity;
    }

    if ((HomePage.globalTimer.elapsedMilliseconds > _dasDownChargedTime + options.dasResetTime)) {
      _dasDownChargedTime = HomePage.globalTimer.elapsedMilliseconds;
      _dasDownVelocityTime = options.initialDASVelocity;
    }
  }

  void resetDownDASVelocity() {
    _dasDownVelocityTime = options.initialDASVelocity;
  }
}