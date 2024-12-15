import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttris/pages/bind_key_page.dart';
import 'package:fluttris/resources/key_bind.dart';
import 'package:fluttris/resources/options.dart';

class OptionsPage extends StatefulWidget {
  static final String routeName = 'optionsPage';

  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  Widget buttonSelectOverlay = Container();
  late Options options;

  _OptionsPageState() {
    options = Options.getOptions();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(child: Text('Options', style: TextStyle(color: Colors.white))),
          leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.arrow_back, color: Colors.white,)),
          actions: [
            IconButton(onPressed: options.save, icon: Icon(Icons.save, color: Colors.white,))
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(text: 'Gameplay'),
              Tab(text: "Controls"),
              Tab(text: "Mulitplayer Profile")
            ]
          ),
        ),
        body: Container(
          color: Colors.black,
          child: TabBarView(
            children: [
              _getGameplayTab(),
              _getControlsTab(context),
              Column()
            ]
          ),
        ),
      ),
    );
  }

  Widget _getGameplayTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("Keyboard DAS Controls:", style: TextStyle(color: Colors.white)),
                SizedBox(height: 20),
                _getDASControl('Initial DAS Velocity (ms):', options.initialDASVelocity.toString(), (String s) { if (s.isNotEmpty) options.initialDASVelocity = int.parse(s); }),
                _getDASControl('DAS Acceleration (ms):', options.dasAccelerationTime.toString(), (String s) { if (s.isNotEmpty) options.dasAccelerationTime = int.parse(s); }),
                _getDASControl('Max DAS Velocity (ms):', options.maxVelocity.toString(), (String s) { if (s.isNotEmpty) options.maxVelocity = int.parse(s); }),
                _getDASControl('DAS Reset Time (ms):', options.dasResetTime.toString(), (String s) { if (s.isNotEmpty) options.dasResetTime = int.parse(s); }),
              ],
            ),
          )
        ],
      )
    );
  }

  Widget _getDASControl(String title, String value, Function(String) onValueChanged) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(title, style: TextStyle(color: Colors.white))
        ),
        SizedBox(width: 20),
        SizedBox(
          width: 120,
          child: TextField(
            style: TextStyle(color: Colors.white),
            onChanged: onValueChanged,         
            decoration: InputDecoration(labelText: value),            
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter> [
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
        ),
      ],
    );
  }

  Widget _getControlsTab(BuildContext context) {
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
                    Checkbox(value: options.areTouchControlsInverted, onChanged: _onTouchControlsInversionChanged)
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
                _getKeyboardBinds(context)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getKeyboardBinds(BuildContext context) {
    List<Widget> keyBinds = [];

    for (KeyBind kb in options.keyboardBinds) {
      keyBinds.add(SizedBox(height: 30));
      keyBinds.add(
        Row(
          children: [
            SizedBox(width: 150, child: Text(kb.control.toString(), style: TextStyle(color: Colors.white))),
            SizedBox(
              width: 100,
              height: 35,
              child: TextButton(
                onPressed: () => _onChangeKeyBindPressed(kb), 
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.deepPurple)
                    )
                  )
                ),
                child: _getColoredText(kb.key.debugName ?? '')
              ),
            )
          ],
        )
      );
    }

    return Column(children: keyBinds);
  }

  void _onChangeKeyBindPressed(KeyBind kb) {
    options.onKeyPress = (PhysicalKeyboardKey key) 
    { 
      setState(() {
        kb.key = key; 
      }); 
      options.onKeyPress = null; 
    };
    Navigator.push(context, MaterialPageRoute(builder: (context) => BindKeyPage(options: options), settings: RouteSettings(name: BindKeyPage.routeName)));
  }

  Widget _getColoredText(String text) {
    return Text(text, style: TextStyle(color: Colors.white));
  }

  void _onTouchControlsInversionChanged(bool? value) {
    if (value is bool) {
      setState(() {
        options.areTouchControlsInverted = value;
      });
    }
  }
}