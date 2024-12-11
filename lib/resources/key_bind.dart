import 'package:flutter/services.dart';
import 'package:fluttris/resources/controls.dart';
import 'package:fluttris/resources/preferences.dart';

class KeyBind {
  final Controls control;
  bool isPollingKeyPress = false;
  PhysicalKeyboardKey key;

  static Map<Controls, PhysicalKeyboardKey> defaultKeys = {
    Controls.drop: PhysicalKeyboardKey.keyS,
    Controls.flip: PhysicalKeyboardKey.comma,
    Controls.moveLeft: PhysicalKeyboardKey.keyA,
    Controls.moveRight: PhysicalKeyboardKey.keyD,
    Controls.pause: PhysicalKeyboardKey.escape,
    Controls.reset: PhysicalKeyboardKey.f5,
    Controls.hardDrop: PhysicalKeyboardKey.keyW,
    Controls.hold: PhysicalKeyboardKey.keyE,
    Controls.rotateLeft: PhysicalKeyboardKey.period,
    Controls.rotateRight: PhysicalKeyboardKey.slash
  };

  KeyBind({required this.control, required this.key});

  static Future<KeyBind> getKeyBind(Controls control) async {
    int? keyCode = (await Preferences.getPreferences()).getInt(control.name);
    
    if (keyCode != null) {
      PhysicalKeyboardKey? key = PhysicalKeyboardKey.findKeyByCode(keyCode);
      if (key != null) {
        return KeyBind(control: control, key: key);
      }
    }
    return KeyBind(control: control, key: defaultKeys[control]!);
  }
  
  Future<bool> setKeyBind() async {
    return (await Preferences.getPreferences()).setInt(control.name, key.usbHidUsage);
  }
}