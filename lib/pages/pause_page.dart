import 'package:flutter/material.dart';
import 'package:fluttris/pages/home_page.dart';
import 'package:fluttris/pages/options_page.dart';
import 'package:fluttris/resources/options.dart';

class PausePage extends StatelessWidget {
  static final String routeName = 'pausePage';
  final Options options;
  final Function resume;

  const PausePage({super.key, required this.options, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getMainWindowButton('Resume', () { resume(); Navigator.pop(context); }),
            getSpaceBox(),
            getMainWindowButton('Options', () { Navigator.push(context, MaterialPageRoute(builder: (context) => OptionsPage(options: options), settings: RouteSettings(name: OptionsPage.routeName))); }),
            getSpaceBox(),
            getMainWindowButton('Quit', () { Navigator.popUntil(context, (Route<dynamic> x) => x.settings.name == HomePage.routeName); }),
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