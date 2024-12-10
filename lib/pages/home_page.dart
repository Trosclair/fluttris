import 'dart:math';
import 'package:fluttris/resources/game_state.dart';
import 'package:hold_down_button/hold_down_button.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fluttris/Game/tetris.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Tetris tetris;
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
                            getIconButtonBox(dpadButtonSideLength, () { if (tetris.gameState == GameState.playing) tetris.hardDrop(); }, Icon(Icons.arrow_upward, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength)
                          ],
                        ),
                        Row(
                          children: [
                            getIconButtonBox(dpadButtonSideLength, () { if (tetris.gameState == GameState.playing) tetris.moveLeft(); }, Icon(Icons.arrow_left, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () { if (tetris.gameState == GameState.playing) tetris.moveRight(); }, Icon(Icons.arrow_right, color: Colors.white, size: 60))
                          ],
                        ),
                        Row(
                          children: [
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () { if (tetris.gameState == GameState.playing) tetris.down(true); }, Icon(Icons.arrow_downward, color: Colors.white, size: 60)),
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
                child: getTetrisFactory(gameWidth, height)
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
                            getIconButtonBox(dpadButtonSideLength, () { if (tetris.gameState == GameState.playing) tetris.hold(); }, Icon(Icons.download, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength)
                          ],
                        ),
                        Row(
                          children: [
                            getIconButtonBox(dpadButtonSideLength, () { if (tetris.gameState == GameState.playing) tetris.rotate(tetris.currentPiece.rotations.length - 1); }, Icon(Icons.rotate_left, color: Colors.white, size: 60)),
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () { if (tetris.gameState == GameState.playing) tetris.rotate(1); }, Icon(Icons.rotate_right, color: Colors.white, size: 60))
                          ],
                        ),
                        Row(
                          children: [
                            getSpaceBox(dpadButtonSideLength),
                            getIconButtonBox(dpadButtonSideLength, () { if (tetris.gameState == GameState.playing) tetris.rotate(2); }, Icon(Icons.flip, color: Colors.white, size: 60)),
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
        child: CircleAvatar(backgroundColor: Color(0xFF1C1C84), child: IconButton(onPressed: onPressed, icon: icon))
      )
    );
  }

  Widget getTetrisFactory(double gameWidth, double height) {
    return GameWidget.controlled(
      gameFactory: Tetris.new,
      overlayBuilderMap: {
        GameState.gameOver.name: (context, game) => Center(
          child: TextButton(onPressed: () { tetris.setGameState(GameState.playing); }, child: Text('Start over')),
        ),
        GameState.start.name: (context, game) => Center(
          child: TextButton(onPressed: () { (game as Tetris).setGameState(GameState.playing); tetris = game; }, child: Text('Start')),
        )
      }
    );
  }
}