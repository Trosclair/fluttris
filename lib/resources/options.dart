import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttris/resources/control_type.dart';
import 'package:fluttris/resources/key_bind.dart';
import 'package:fluttris/resources/preferences.dart';

class Options extends Game with KeyboardEvents {
  static Options? _options;

  bool areOptionsInitialized = false;

  /// Controls
  /// Touch Controls
  bool areTouchControlsInverted = false;

  /// Keyboard Controls
  List<KeyBind> keyboardBinds = [];

  /// Multiplayer Profile
  String displayName = '';
  String userID = '';

  /// DAS Configuration
  int maxVelocity = 34;
  int initialDASVelocity = 250;
  int dasResetTime = 17;
  int dasAccelerationTime = 68;

  BuildContext? context;
  Function(PhysicalKeyboardKey)? onKeyPress;
  final TextPaint _reg = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.white.color));
  
  late KeyBind rotateRightBind;
  late KeyBind rotateLeftBind;
  late KeyBind flipBind;
  late KeyBind moveRightBind;
  late KeyBind moveLeftBind;
  late KeyBind dropBind;
  late KeyBind hardDropBind;
  late KeyBind holdBind;
  late KeyBind pauseBind;
  late KeyBind resetBind;

  static Options getOptions() {
    return _options!;
  }

  static Future initializeOptions() async {
    _options ??= await _getOptions();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    if (onKeyPress != null && context != null) {
      onKeyPress?.call(event.physicalKey);
      Navigator.pop(context!);
    }

    return KeyEventResult.handled;
  }
  
  @override
  void render(Canvas canvas) {
    if (context != null) {
      _reg.render(canvas, 'Press a Key...', Vector2(MediaQuery.sizeOf(context!).width / 2, MediaQuery.sizeOf(context!).height / 2));
    }
  }
  
  @override
  void update(double dt) { }

  static Future<Options> _getOptions() async {
    Options options = Options();

    options.areTouchControlsInverted = (await Preferences.getPreferences()).getBool('areTouchControlsInverted') ?? false;
    
    for (ControlType c in ControlType.values) {
      KeyBind kb = await KeyBind.getKeyBind(c);
      options.keyboardBinds.add(kb);
      switch (kb.control) {
        case ControlType.drop:
          options.dropBind = kb;
          break;
        case ControlType.hardDrop:
          options.hardDropBind = kb;
          break;
        case ControlType.reset:
          options.resetBind = kb;
          break;
        case ControlType.pause:
          options.pauseBind = kb;
          break;
        case ControlType.rotateLeft:
          options.rotateLeftBind = kb;
          break;
        case ControlType.rotateRight:
          options.rotateRightBind = kb;
          break;
        case ControlType.moveLeft:
          options.moveLeftBind = kb;
          break;
        case ControlType.moveRight:
          options.moveRightBind = kb;
          break;
        case ControlType.flip:
          options.flipBind = kb;
          break;
        case ControlType.hold:
          options.holdBind = kb;
      }
    }

    options.displayName = (await Preferences.getPreferences()).getString('displayName') ?? '';
    options.displayName = (await Preferences.getPreferences()).getString('userID') ?? '';

    options.dasAccelerationTime = (await Preferences.getPreferences()).getInt('dasAccelerationTime') ?? 68;
    options.dasResetTime = (await Preferences.getPreferences()).getInt('dasResetTime') ?? 17;
    options.initialDASVelocity = (await Preferences.getPreferences()).getInt('initialDASVelocity') ?? 250;
    options.maxVelocity = (await Preferences.getPreferences()).getInt('maxVelocity') ?? 34;

    return options;
  }

  Future<bool> save() async {
    bool saveSuccessful = true;

    saveSuccessful &= await _setAreTouchControlsInverted();

    for (KeyBind keyBind in keyboardBinds) {
      saveSuccessful &= await keyBind.setKeyBind();
    }

    saveSuccessful &= await _setDisplayName();
    saveSuccessful &= await _setUserID();
    saveSuccessful &= await _setDASAccelerationTime();
    saveSuccessful &= await _setDASResetTime();
    saveSuccessful &= await _setInitialDASVelocity();
    saveSuccessful &= await _setMaxVelocity();

    return saveSuccessful;
  }

  Future<bool> _setAreTouchControlsInverted() async {
    return (await Preferences.getPreferences()).setBool('areTouchControlsInverted', areTouchControlsInverted);
  }

  Future<bool> _setDisplayName() async {
    return (await Preferences.getPreferences()).setString('displayName', displayName);
  }
  
  Future<bool> _setUserID() async {
    return (await Preferences.getPreferences()).setString('userID', userID);
  }
  
  Future<bool> _setDASAccelerationTime() async {
    return (await Preferences.getPreferences()).setInt('dasAccelerationTime', dasAccelerationTime);
  }
  
  Future<bool> _setDASResetTime() async {
    return (await Preferences.getPreferences()).setInt('dasResetTime', dasResetTime);
  }
  
  Future<bool> _setInitialDASVelocity() async {
    return (await Preferences.getPreferences()).setInt('initialDASVelocity', initialDASVelocity);
  }
  
  Future<bool> _setMaxVelocity() async {
    return (await Preferences.getPreferences()).setInt('maxVelocity', maxVelocity);
  }
}