import 'package:flutter/services.dart';
import 'package:fluttris/resources/control_type.dart';
import 'package:fluttris/resources/preferences.dart';

class KeyBind {
  final ControlType control;
  bool isPollingKeyPress = false;
  PhysicalKeyboardKey key;

  static Map<ControlType, PhysicalKeyboardKey> defaultKeys = {
    ControlType.drop: PhysicalKeyboardKey.keyS,
    ControlType.flip: PhysicalKeyboardKey.comma,
    ControlType.moveLeft: PhysicalKeyboardKey.keyA,
    ControlType.moveRight: PhysicalKeyboardKey.keyD,
    ControlType.pause: PhysicalKeyboardKey.escape,
    ControlType.reset: PhysicalKeyboardKey.f5,
    ControlType.hardDrop: PhysicalKeyboardKey.keyW,
    ControlType.hold: PhysicalKeyboardKey.keyE,
    ControlType.rotateLeft: PhysicalKeyboardKey.period,
    ControlType.rotateRight: PhysicalKeyboardKey.slash
  };

  KeyBind({required this.control, required this.key});

  static Future<KeyBind> getKeyBind(ControlType control) async {
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