import 'package:flutter/material.dart';
import 'package:fluttris/pages/home_page.dart';
import 'package:fluttris/resources/game_stats.dart';

class ResultsPage extends StatelessWidget {
  static final String routeName = 'resultsPage';
  final GameStats stats;
  final Function reset;

  const ResultsPage({super.key, required this.stats, required this.reset});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(child: Text('Post game', style: TextStyle(color: Colors.white))),
          leading: SizedBox(),
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            _getStatsRow('Score:', stats.score.toString()),
            _getStatsRow('Lines Cleared:', stats.totalLinesCleared.toString()),
            _getStatsRow('Level:', stats.level.toString()),
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.white),
            SizedBox(height: 20),
            _getStatsRow('Singles:', stats.singles.toString()),
            _getStatsRow('Doubles:', stats.doubles.toString()),
            _getStatsRow('Triples:', stats.triples.toString()),
            _getStatsRow('Tetris:', stats.tetris.toString()),
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.white),
            SizedBox(height: 20),
            _getStatsRow('T-Spin Singles:', stats.tSpinSingle.toString()),
            _getStatsRow('T-Spin Doubles:', stats.tSpinDouble.toString()),
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.white,),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getMainWindowButton('Restart', () { reset(); Navigator.pop(context); }),
                SizedBox(width: 20),
                _getMainWindowButton('Home', () { Navigator.popUntil(context, (Route<dynamic> x) => x.settings.name == HomePage.routeName); }),
              ],
            )
          ],
        ),
      )
    );
  }

  Widget _getStatsRow(String text, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 200, child: Text(text, textAlign: TextAlign.left, style: TextStyle(color: Colors.white))),
        SizedBox(width: 20),
        SizedBox(width: 200, child: Text(value, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))
      ],
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