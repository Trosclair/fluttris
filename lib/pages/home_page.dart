import 'package:flutter/material.dart';
import 'package:fluttris/game/tetris.dart';
import 'package:fluttris/pages/game_page.dart';
import 'package:fluttris/pages/level_select_page.dart';
import 'package:fluttris/pages/multiplayer_menu_page.dart';
import 'package:fluttris/pages/options_page.dart';
import 'package:fluttris/resources/game_controls.dart';

class HomePage extends StatelessWidget {
  static final String routeName = '/';
  static final Stopwatch globalTimer = Stopwatch();

  HomePage({super.key}) { globalTimer.start(); }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getMainWindowButton('Quick Game', () { Navigator.push(context, MaterialPageRoute(builder: (context) => GamePage(tetris: Tetris(gameControls: GameControls(), seedLevel: 0, isOnline: false)), settings: RouteSettings(name: GamePage.routeName))); }),
            _getSpaceBox(),
            _getMainWindowButton('Level Select', () { Navigator.push(context, MaterialPageRoute(builder: (context) => LevelSelectPage(), settings: RouteSettings(name: LevelSelectPage.routeName))); }),
            _getSpaceBox(),
            _getMainWindowButton('Multiplayer', () { Navigator.push(context, MaterialPageRoute(builder: (context) => MultiplayerMenuPage(), settings: RouteSettings(name: MultiplayerMenuPage.routeName))); }),
            _getSpaceBox(),
            _getMainWindowButton('Options', () { Navigator.push(context, MaterialPageRoute(builder: (context) => OptionsPage(), settings: RouteSettings(name: OptionsPage.routeName))); }),
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