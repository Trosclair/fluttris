import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttris/resources/controls.dart';
import 'package:fluttris/resources/key_bind.dart';
import 'package:fluttris/resources/preferences.dart';

class Options extends Game with KeyboardEvents {
  /// Controls
  /// Touch Controls
  bool areTouchControlsInverted = false;

  /// Keyboard Controls
  List<KeyBind> keyboardBinds = [];

  /// Multiplayer Profile
  String displayName = '';
  String userID = '';

  Options();

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    return KeyEventResult.handled;
  }
  
  @override
  void render(Canvas canvas) { }
  
  @override
  void update(double dt) { }

  static Future<Options> getOptions() async {
    Options options = Options();

    options.areTouchControlsInverted = (await Preferences.getPreferences()).getBool('areTouchControlsInverted') ?? false;
    
    for (Controls c in Controls.values) {
      options.keyboardBinds.add(await KeyBind.getKeyBind(c));
    }

    options.displayName = (await Preferences.getPreferences()).getString('displayName') ?? '';
    options.displayName = (await Preferences.getPreferences()).getString('userID') ?? '';

    return options;
  }

  Future<bool> save() async {
    bool saveSuccessful = true;

    saveSuccessful &= await setAreTouchControlsInverted();

    for (KeyBind keyBind in keyboardBinds) {
      saveSuccessful &= await keyBind.setKeyBind();
    }

    saveSuccessful &= await setDisplayName();
    saveSuccessful &= await setUserID();

    return saveSuccessful;
  }

  Future<bool> setAreTouchControlsInverted() async {
    return (await Preferences.getPreferences()).setBool('areTouchControlsInverted', areTouchControlsInverted);
  }

  Future<bool> setDisplayName() async {
    return (await Preferences.getPreferences()).setString('displayName', displayName);
  }
  
  Future<bool> setUserID() async {
    return (await Preferences.getPreferences()).setString('userID', userID);
  }
}