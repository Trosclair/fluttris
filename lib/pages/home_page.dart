import 'package:flutter/material.dart';
import 'package:fluttris/game/tetris.dart';
import 'package:fluttris/pages/game_page.dart';
import 'package:fluttris/pages/options_page.dart';
import 'package:fluttris/resources/game_controls.dart';
import 'package:fluttris/resources/options.dart';

class HomePage extends StatefulWidget {
  final Options options;
  const HomePage({super.key, required this.options});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getMainWindowButton('Quick Game', () { Navigator.push(context, MaterialPageRoute(builder: (context) => GamePage(tetris: Tetris(gameControls: GameControls(options: widget.options)),))); }),
            getSpaceBox(),
            getMainWindowButton('Level Select', () {}),
            getSpaceBox(),
            getMainWindowButton('Multiplayer', () {}),
            getSpaceBox(),
            getMainWindowButton('Options', () { Navigator.push(context, MaterialPageRoute(builder: (context) => OptionsPage(options: widget.options))); }),
          ],
        ),
      ),
    );
  }

  Widget getSpaceBox() {
    return const SizedBox(
      height: 30,
    );
  }

  Widget getMainWindowButton(String text, VoidCallback clickEvent) {
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