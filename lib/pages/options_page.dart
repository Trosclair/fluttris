import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttris/pages/bind_key_page.dart';
import 'package:fluttris/resources/key_bind.dart';
import 'package:fluttris/resources/options.dart';

class OptionsPage extends StatefulWidget {
  static final String routeName = 'optionsPage';
  final Options options;

  const OptionsPage({super.key, required this.options});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  Widget buttonSelectOverlay = Container();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(onPressed: onBackPressed, icon: Icon(Icons.arrow_back, color: Colors.white,)),
          bottom: TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(text: "Controls"),
              Tab(text: "Mulitplayer Profile")
            ]
          ),
        ),
        body: Container(
          color: Colors.black,
          child: TabBarView(
            children: [
              getControlsTab(context),
              Column()
            ]
          ),
        ),
      ),
    );
  }

  Widget getControlsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("Touch Controls:", style: TextStyle(color: Colors.white)),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Invert Controls", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 20),
                    Checkbox(value: widget.options.areTouchControlsInverted, onChanged: onTouchControlsInversionChanged)
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          const Divider(height: 1, color: Colors.white),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("Keyboard Controls:", style: TextStyle(color: Colors.white)),
                SizedBox(height: 20),
                getKeyboardBinds(context)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getKeyboardBinds(BuildContext context) {
    List<Widget> keyBinds = [];

    for (KeyBind kb in widget.options.keyboardBinds) {
      keyBinds.add(SizedBox(height: 30));
      keyBinds.add(
        Row(
          children: [
            SizedBox(width: 150, child: Text(kb.control.toString(), style: TextStyle(color: Colors.white))),
            SizedBox(
              width: 100,
              height: 35,
              child: TextButton(
                onPressed: () => onChangeKeyBindPressed(kb), 
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.deepPurple)
                    )
                  )
                ),
                child: getColoredText(kb.key.debugName ?? '')
              ),
            )
          ],
        )
      );
    }

    return Column(children: keyBinds);
  }

  void onChangeKeyBindPressed(KeyBind kb) {
    widget.options.onKeyPress = (PhysicalKeyboardKey key) 
    { 
      setState(() {
        kb.key = key; 
      }); 
      widget.options.onKeyPress = null; 
    };
    Navigator.push(context, MaterialPageRoute(builder: (context) => BindKeyPage(options: widget.options), settings: RouteSettings(name: BindKeyPage.routeName)));
  }

  Widget getColoredText(String text) {
    return Text(text, style: TextStyle(color: Colors.white));
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