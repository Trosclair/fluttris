import 'dart:math';
import 'package:hold_down_button/hold_down_button.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fluttris/Game/tetris.dart';
import 'package:fluttris/resources/game_input.dart';

class HomePage extends StatelessWidget {
  final Tetris tetris = Tetris();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    double blockSideLength = height / 20;
    double secondaryBlockSideLength = blockSideLength * .7;

    // For some reason the media.sizeof query will return a negative or a really small number, so we need to clamp it at 0 to avoid
    // hilarity in division.
    double gameWidth = max(0, (blockSideLength * 10) + 40 + (secondaryBlockSideLength * 8));
    double sideWidth = max(0, (width - gameWidth) / 2);

    double dpadButtonSideLength = (sideWidth / 3);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          height: height,
          width: width,
          color: Colors.black,
          child: Row(
            children: [
              Container(
                width: sideWidth,
                height: height,
                color: Colors.black,
                child: Container(
                  height: sideWidth,
                  alignment: Alignment.bottomCenter,
                  child: 
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () => tetris.hardDrop(), Icon(Icons.arrow_upward, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength)
                          ],
                        ),
                        Row(
                          children: [
                            getIconButtonBox(dpadButtonSideLength, () => tetris.moveDirection(GameInput.left), Icon(Icons.arrow_left, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () => tetris.moveDirection(GameInput.right), Icon(Icons.arrow_right, color: Colors.white, size: 60))
                          ],
                        ),
                        Row(
                          children: [
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () => tetris.down(true), Icon(Icons.arrow_downward, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength)
                          ],
                        )
                      ],
                    )
                  ,
                ),
              ),
              SizedBox(
                width: gameWidth,
                height: height,
                child: GameWidget(
                  game: tetris,
                ),
              ),
              Container(
                width: sideWidth,
                height: height,
                color: Colors.black,
                child: Container(
                  height: sideWidth,
                  alignment: Alignment.bottomCenter,
                  child: 
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () => tetris.hold(), Icon(Icons.download, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength)
                          ],
                        ),
                        Row(
                          children: [
                            getIconButtonBox(dpadButtonSideLength, () => tetris.rotate(tetris.currentPiece.rotations.length - 1), Icon(Icons.rotate_left, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () => tetris.rotate(1), Icon(Icons.rotate_right, color: Colors.white, size: 60))
                          ],
                        ),
                        Row(
                          children: [
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () => tetris.rotate(2), Icon(Icons.flip, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength)
                          ],
                        )
                      ],
                    )
                  ,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getSpaceBox(double sideLength) {
    return SizedBox(
      height: sideLength,
      width: sideLength,
    );
  }

  Widget getIconButtonBox(double sideLength, VoidCallback onPressed, Icon icon) {
    return SizedBox(
      height: sideLength,
      width: sideLength,
      child: HoldDownButton(
        onHoldDown: onPressed,
        child: IconButton(onPressed: onPressed, icon: icon)
      )
    );
  }
}