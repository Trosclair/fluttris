import 'package:flutter/material.dart';
import 'package:fluttris/resources/options.dart';

class OptionsPage extends StatefulWidget {
  final Options options;

  const OptionsPage({super.key, required this.options});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(onPressed: onBackPressed, icon: Icon(Icons.arrow_back, color: Colors.white,)),
          bottom: TabBar(
            tabs: [
              Tab(text: "Controls",),
              Tab(text: "Mulitplayer Profile",)
            ]
          ),
        ),
        body: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TabBarView(
              children: [
                getControlsTab(context),
                Column()
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget getControlsTab(BuildContext context) {
    return Column(

      children: [
        Text("Touch Controls:", style: TextStyle(color: Colors.white)),
        SizedBox(height: 20),
        Row(
          children: [
            Text("Invert Controls", style: TextStyle(color: Colors.white)),
            SizedBox(width: 20),
            Checkbox(value: widget.options.areTouchControlsInverted, onChanged: onTouchControlsInversionChanged)
          ],
        ),
        SizedBox(height: 20),
        const Divider(height: 1, color: Colors.white, ),
        SizedBox(height: 20),
        Text("Keyboard Controls:", style: TextStyle(color: Colors.white)),
      ],
    );
  }


  void onTouchControlsInversionChanged(bool? value) {
    if (value is bool) {
      setState(() {
        widget.options.areTouchControlsInverted = value;
      });
    }
  }

  void onBackPressed() async {
    widget.options.save().then((_) {
      goBack();
    });
  }

  void goBack() {
    Navigator.pop(context);
  }
}