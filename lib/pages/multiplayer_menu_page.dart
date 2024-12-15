import 'package:flutter/material.dart';

class MultiplayerMenuPage extends StatelessWidget {
  static final String routeName = 'multiplayerMenuPage';

  const MultiplayerMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Multiplayer', style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getMainWindowButton('Server Browser', () {}),
            _getSpaceBox(),
            _getMainWindowButton('Direct Connect', () {}),
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