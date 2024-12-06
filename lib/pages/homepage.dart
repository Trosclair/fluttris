import 'package:flutter/material.dart';
import 'package:fluttris/pages/tetris.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Tetris())), child: Text('Play'))
          ],
        ),
      ),
    );
  }
}