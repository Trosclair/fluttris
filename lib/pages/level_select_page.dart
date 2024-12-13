import 'package:flutter/material.dart';
import 'package:fluttris/game/tetris.dart';
import 'package:fluttris/pages/game_page.dart';
import 'package:fluttris/resources/game_controls.dart';
import 'package:fluttris/resources/options.dart';

class LevelSelectPage extends StatelessWidget {
  static final String routeName = 'levelSelectPage';
  final Options options;

  const LevelSelectPage({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Center(child: Text('Level Select', style: TextStyle(color: Colors.white))),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 540,
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              runSpacing: 10,
              children: getLevels(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getLevels(BuildContext context) {
    List<Widget> levels = [];

    for (int i = 0; i < 30; i++) {
      levels.add(
        getMainWindowButton(i.toString(), () { Navigator.push(context, MaterialPageRoute(builder: (context) => GamePage(tetris: Tetris(gameControls: GameControls(options: options), seedLevel: i, isOnline: false)), settings: RouteSettings(name: GamePage.routeName))); })
      );
    }

    return levels;
  }

  Widget getSpaceBox() {
    return const SizedBox(
      height: 30,
    );
  }

  Widget getMainWindowButton(String text, VoidCallback clickEvent) {
    return SizedBox(
      width: 100,
      height: 100,
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
    );
  }
}