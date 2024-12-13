import 'package:flutter/material.dart';
import 'package:fluttris/game/tetris.dart';
import 'package:fluttris/pages/game_page.dart';
import 'package:fluttris/pages/level_select_page.dart';
import 'package:fluttris/pages/options_page.dart';
import 'package:fluttris/resources/game_controls.dart';
import 'package:fluttris/resources/options.dart';

class HomePage extends StatelessWidget {
  static final String routeName = '/';
  static final Stopwatch globalTimer = Stopwatch();
  final Options options;

  HomePage({super.key, required this.options}) { globalTimer.start(); }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getMainWindowButton('Quick Game', () { Navigator.push(context, MaterialPageRoute(builder: (context) => GamePage(tetris: Tetris(gameControls: GameControls(options: options), seedLevel: 0, isOnline: false)), settings: RouteSettings(name: GamePage.routeName))); }),
            _getSpaceBox(),
            _getMainWindowButton('Level Select', () { Navigator.push(context, MaterialPageRoute(builder: (context) => LevelSelectPage(options: options), settings: RouteSettings(name: LevelSelectPage.routeName))); }),
            _getSpaceBox(),
            _getMainWindowButton('Multiplayer', () {}),
            _getSpaceBox(),
            _getMainWindowButton('Options', () { Navigator.push(context, MaterialPageRoute(builder: (context) => OptionsPage(options: options), settings: RouteSettings(name: OptionsPage.routeName))); }),
          ],
        ),
      ),
    );
  }

  Widget _getSpaceBox() {
    return const SizedBox(
      height: 30,
    );
  }

  Widget _getMainWindowButton(String text, VoidCallback clickEvent) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 70,
        child: TextButton(
          onPressed: clickEvent, 
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.deepPurple)
              )
            )
          ),
          child: Text(text)
        ),
      ),
    );
  }
}