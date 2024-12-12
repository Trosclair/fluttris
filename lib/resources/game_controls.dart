import 'dart:math';

import 'package:flutter/services.dart';
import 'package:fluttris/resources/game_state.dart';
import 'package:fluttris/resources/options.dart';
import 'package:fluttris/resources/piece.dart';

class GameControls {
  final Options options;
  final int dasAccelerationTime = 68;
  final int dasResetTime = 17;

  int dasLeftRightPollingTime = 0;
  int dasLeftRightChargedTime = 0;
  int dasLeftRightVelocityTime = 250;

  int dasRotatePollingTime = 0;
  int dasRotateChargedTime = 0;
  int dasRotateVelocityTime = 250;
  
  int dasDownPollingTime = 0;
  int dasDownChargedTime = 0;
  int dasDownVelocityTime = 250;

  bool isHardDropPressed = false;
  bool isHoldPressed = false;
  bool isResetPressed = false;
  bool isLeftPressed = false;
  bool isRightPressed = false;
  bool isDownPressed = false;
  bool isRotateRightPressed = false;
  bool isRotateLeftPressed = false;
  bool isFlipPressed = false;
  bool isPausedPressed = false;
  
  bool wasLeftPressedLastTime = false;
  bool wasRightPressedLastTime = false;
  bool wasDownPressedLastTime = false;
  bool wasRotateRightPressedLastTime = false;
  bool wasRotateLeftPressedLastTime = false;
  bool wasFlipPressedLastTime = false;
  bool wasResetPressedLastTime = false;
  bool wasHoldPressedLastTime = false;
  bool wasHardDropPressedLastTime = false;

  int lastKeyPressed = 0;
  Stopwatch globalTimer = Stopwatch();

  late Function hardDrop;
  late Function(bool) down;
  late Function moveRight;
  late Function moveLeft;
  late Function(int) rotate;
  late Function pause;
  late Function reset;
  late Function hold;

  GameControls({required this.options}) {
    globalTimer.start();
  }

  
  void checkForKeyPresses(GameState gameState, Piece currentPiece) {
    Iterable<int> keysPressed = HardwareKeyboard.instance.physicalKeysPressed.map((x) => x.usbHidUsage);

    isResetPressed = keysPressed.where((int x) => x == options.resetBind.key.usbHidUsage).isNotEmpty;
    isRightPressed = keysPressed.where((int x) => x == options.moveRightBind.key.usbHidUsage).isNotEmpty;
    isLeftPressed = keysPressed.where((int x) => x == options.moveLeftBind.key.usbHidUsage).isNotEmpty;
    isRotateLeftPressed = keysPressed.where((int x) => x == options.rotateLeftBind.key.usbHidUsage).isNotEmpty;
    isRotateRightPressed = keysPressed.where((int x) => x == options.rotateRightBind.key.usbHidUsage).isNotEmpty;
    isFlipPressed = keysPressed.where((int x) => x == options.flipBind.key.usbHidUsage).isNotEmpty;
    isHardDropPressed = keysPressed.where((int x) => x == options.hardDropBind.key.usbHidUsage).isNotEmpty;
    isHoldPressed = keysPressed.where((int x) => x == options.holdBind.key.usbHidUsage).isNotEmpty;
    isDownPressed = keysPressed.where((int x) => x == options.dropBind.key.usbHidUsage).isNotEmpty;
    isPausedPressed = keysPressed.where((int x) => x == options.pauseBind.key.usbHidUsage).isNotEmpty;
    
    if (!wasResetPressedLastTime && isResetPressed) {
      reset();
      wasResetPressedLastTime = isResetPressed;
      return;
    }

    if (gameState == GameState.playing) {

      if (!wasHardDropPressedLastTime && isHardDropPressed) {
        hardDrop();
        wasHardDropPressedLastTime = true;
        return;
      }

      if (!wasHoldPressedLastTime && isHoldPressed) {
        hold();
        wasHoldPressedLastTime = true;
        return;
      }

      if (isPausedPressed) {
        pause();
        return;
      }
      
      if (globalTimer.elapsedMilliseconds > dasLeftRightPollingTime + dasLeftRightVelocityTime || (!wasRightPressedLastTime && isRightPressed) || (!wasLeftPressedLastTime && isLeftPressed)) {
        if (isRightPressed) {
          moveRight();
          dasLeftRightVelocityTime -= dasAccelerationTime;
          dasLeftRightVelocityTime = max(dasLeftRightVelocityTime, 34);
          dasLeftRightPollingTime = globalTimer.elapsedMilliseconds; 
        }
        else if (isLeftPressed) {
          moveLeft();
          dasLeftRightVelocityTime -= dasAccelerationTime;
          dasLeftRightVelocityTime = max(dasLeftRightVelocityTime, 34);
          dasLeftRightPollingTime = globalTimer.elapsedMilliseconds; 
        }
      }
             
      if (globalTimer.elapsedMilliseconds > dasDownPollingTime + dasDownVelocityTime || (!wasDownPressedLastTime && isDownPressed)) {
        if (isDownPressed) {
          down(true);
          dasDownVelocityTime -= dasAccelerationTime;
          dasDownVelocityTime = max(dasDownVelocityTime, 34);
          dasDownPollingTime = globalTimer.elapsedMilliseconds; 
        }
      }

      if (globalTimer.elapsedMilliseconds > dasRotatePollingTime + dasRotateVelocityTime) {
        if (isRotateRightPressed) {
          rotate(1);
          dasRotateVelocityTime -= dasAccelerationTime;
          dasRotateVelocityTime = max(dasRotateVelocityTime, 34);
          dasRotatePollingTime = globalTimer.elapsedMilliseconds;
        }
        else if (isRotateLeftPressed) {
          rotate(currentPiece.rotations.length - 1);
          dasRotateVelocityTime -= dasAccelerationTime;
          dasRotateVelocityTime = max(dasRotateVelocityTime, 34);
          dasRotatePollingTime = globalTimer.elapsedMilliseconds;
        }
        else if (isFlipPressed) {
          rotate(2);
          dasRotateVelocityTime -= dasAccelerationTime;
          dasRotateVelocityTime = max(dasRotateVelocityTime, 34);
          dasRotatePollingTime = globalTimer.elapsedMilliseconds;
        }
      } 
    }
    
    wasRightPressedLastTime = isRightPressed;
    wasLeftPressedLastTime = isLeftPressed;
    wasDownPressedLastTime = isDownPressed;
    wasRotateLeftPressedLastTime = isRotateLeftPressed;
    wasRotateRightPressedLastTime = isRotateRightPressed;
    wasFlipPressedLastTime = isFlipPressed;
    wasHoldPressedLastTime = isHoldPressed;
    wasHardDropPressedLastTime = isHardDropPressed;
    wasResetPressedLastTime = isResetPressed;
    
    if (isLeftPressed || isRightPressed) {
      dasLeftRightChargedTime = globalTimer.elapsedMilliseconds;
    } 

    if (isRotateLeftPressed || isRotateRightPressed || isFlipPressed) {
      dasRotateChargedTime = globalTimer.elapsedMilliseconds;
    }

    if (isDownPressed) {
      dasDownChargedTime = globalTimer.elapsedMilliseconds;
    }

    if ((globalTimer.elapsedMilliseconds > dasLeftRightChargedTime + dasResetTime)) {
      dasLeftRightChargedTime = globalTimer.elapsedMilliseconds;
      dasLeftRightVelocityTime = 250;
    }
    
    if ((globalTimer.elapsedMilliseconds > dasRotateChargedTime + dasResetTime)) {
      dasRotateChargedTime = globalTimer.elapsedMilliseconds;
      dasRotateVelocityTime = 250;
    }

    if ((globalTimer.elapsedMilliseconds > dasDownChargedTime + dasResetTime)) {
      dasDownChargedTime = globalTimer.elapsedMilliseconds;
      dasDownVelocityTime = 250;
    }
  }
}