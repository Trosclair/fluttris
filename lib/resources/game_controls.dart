import 'dart:math';

import 'package:flutter/services.dart';
import 'package:fluttris/resources/game_state.dart';
import 'package:fluttris/resources/options.dart';
import 'package:fluttris/resources/piece.dart';

class GameControls {
  final Options options;
  final int dasAccelerationTime = 68;

  bool isHoldingLeftRightMovementButton = false;
  int dasLeftRightPollingTime = 0;
  int dasLeftRightChargedTime = 0;
  int dasLeftRightVelocityTime = 250;

  bool isHoldingRotateButton = false;
  int dasRotatePollingTime = 0;
  int dasRotateChargedTime = 0;
  int dasRotateVelocityTime = 250;
  
  bool isHoldingDownButton = false;
  int dasDownPollingTime = 0;
  int dasDownChargedTime = 0;
  int dasDownVelocityTime = 250;

  bool isHardDropPressed = false;
  bool wasHardDropPressedLastTime = false;

  bool isHoldPressed = false;
  bool wasHoldPressedLastTime = false;

  bool isResetPressed = false;
  bool wasResetPressedLastTime = false;

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
    
      if (!wasResetPressedLastTime && isResetPressed) {
        reset();
        wasResetPressedLastTime = isResetPressed;
        return;
      }
      wasResetPressedLastTime = isResetPressed;

    if (gameState == GameState.playing) {
      isHoldingLeftRightMovementButton = keysPressed.where((int x) => x == options.moveLeftBind.key.usbHidUsage || x == options.moveRightBind.key.usbHidUsage).isNotEmpty;
      isHoldingRotateButton = keysPressed.where((int x) => x == options.rotateLeftBind.key.usbHidUsage || x == options.rotateRightBind.key.usbHidUsage || x == options.flipBind.key.usbHidUsage).isNotEmpty;
      isHardDropPressed = keysPressed.where((int x) => x == options.hardDropBind.key.usbHidUsage).isNotEmpty;
      isHoldPressed = keysPressed.where((int x) => x == options.holdBind.key.usbHidUsage).isNotEmpty;
      isHoldingDownButton = keysPressed.where((int x) => x == options.dropBind.key.usbHidUsage).isNotEmpty;
      isResetPressed = keysPressed.where((int x) => x == options.resetBind.key.usbHidUsage).isNotEmpty;

      if (!wasHardDropPressedLastTime && isHardDropPressed) {
        hardDrop();
        wasHardDropPressedLastTime = isHardDropPressed;
        return;
      }
      wasHardDropPressedLastTime = isHardDropPressed;

      if (!wasHoldPressedLastTime && isHoldPressed) {
        hold();
        wasHoldPressedLastTime = isHoldPressed;
        return;
      }
      wasHoldPressedLastTime = isHoldPressed;
      
      for (int keyPress in keysPressed) {
        if (globalTimer.elapsedMilliseconds > dasLeftRightPollingTime + dasLeftRightVelocityTime) {
          if (keyPress == options.moveRightBind.key.usbHidUsage) {
            moveRight();
            dasLeftRightVelocityTime -= dasAccelerationTime;
            dasLeftRightVelocityTime = max(dasLeftRightVelocityTime, 34);
          }
          else if (keyPress == options.moveLeftBind.key.usbHidUsage) {
            moveLeft();
            dasLeftRightVelocityTime -= dasAccelerationTime;
            dasLeftRightVelocityTime = max(dasLeftRightVelocityTime, 34);
          }
          dasLeftRightPollingTime = globalTimer.elapsedMilliseconds; 
        }
        
        if (globalTimer.elapsedMilliseconds > dasDownPollingTime + dasDownVelocityTime) {
          if (keyPress == options.dropBind.key.usbHidUsage) {
            down(true);
            dasDownVelocityTime -= dasAccelerationTime;
            dasDownVelocityTime = max(dasDownVelocityTime, 34);
          }
          dasDownPollingTime = globalTimer.elapsedMilliseconds; 
        }

        if (globalTimer.elapsedMilliseconds > dasRotatePollingTime + dasRotateVelocityTime) {
          if (keyPress == options.rotateRightBind.key.usbHidUsage) {
            rotate(1);
            dasRotateVelocityTime -= dasAccelerationTime;
            dasRotateVelocityTime = max(dasRotateVelocityTime, 34);
          }
          else if (keyPress == options.rotateLeftBind.key.usbHidUsage) {
            rotate(currentPiece.rotations.length - 1);
            dasRotateVelocityTime -= dasAccelerationTime;
            dasRotateVelocityTime = max(dasRotateVelocityTime, 34);
          }
          else if (keyPress == options.flipBind.key.usbHidUsage) {
            rotate(2);
            dasRotateVelocityTime -= dasAccelerationTime;
            dasRotateVelocityTime = max(dasRotateVelocityTime, 34);
          }
          dasRotatePollingTime = globalTimer.elapsedMilliseconds;
        } 
      }
    }
    
    if (isHoldingLeftRightMovementButton) {
      dasLeftRightChargedTime = globalTimer.elapsedMilliseconds;
    } 

    if (isHoldingRotateButton) {
      dasRotateChargedTime = globalTimer.elapsedMilliseconds;
    }

    if (isHoldingDownButton) {
      dasDownChargedTime = globalTimer.elapsedMilliseconds;
    }

    if ((globalTimer.elapsedMilliseconds > dasLeftRightChargedTime + 68)) {
      isHoldingLeftRightMovementButton = false;
      dasLeftRightChargedTime = globalTimer.elapsedMilliseconds;
      dasLeftRightVelocityTime = 250;
    }
    
    if ((globalTimer.elapsedMilliseconds > dasRotateChargedTime + 68)) {
      isHoldingRotateButton = false;
      dasRotateChargedTime = globalTimer.elapsedMilliseconds;
      dasRotateVelocityTime = 250;
    }

    if ((globalTimer.elapsedMilliseconds > dasDownChargedTime + 68)) {
      isHoldingDownButton = false;
      dasDownChargedTime = globalTimer.elapsedMilliseconds;
      dasDownVelocityTime = 250;
    }
  }
}