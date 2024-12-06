import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fluttris/pages/Homepage.dart';

void main() {
  runApp(GameWidget(game: MyApp()));
}

class MyApp extends FlameGame with HasPerformanceTracker {
  MyApp() {
    pauseWhenBackgrounded = true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
  }
  
  @override
  void update(double dt) {
    super.update(dt);

  }
}