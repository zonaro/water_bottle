import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bubble.dart';
import 'wave.dart';

class WaterContainer {
   

  /// Holds all wave object instances
  List<WaveLayer> waves = [];

  /// Holds all bubble object instances
  List<Bubble> bubbles = [];

  /// How many wave layer do we need, default 3
  int waveCount = 3;

  /// How many bubbles can exist at the same time? The more the expensive, default 10
  int bubbleCount = 10;

  final random = math.Random();

  /// Kill wave and bubble objects
  void disposeWater() {
    waves.forEach((e) => e.dispose());
    bubbles.forEach((e) => e.dispose());
  }

  /// Instantiate wave and bubble objects
  void initWater(TickerProvider ticker) {
    waves.clear();
    bubbles.clear();
    var f = random.nextInt(5000) + 15000;
    var d = random.nextInt(500) + 1500;

    for (var i = 0; i < waveCount; i++) {
      final wave = WaveLayer();
      wave.init(ticker, frequency: f);
      waves.add(wave);
      f -= d;
      f = math.max(f, 0);
    }

    for (var i = 0; i < bubbleCount; i++) {
      final bubble = Bubble();
      bubble.init(ticker);
      bubble.randomize();
      bubbles.add(bubble);
    }
  }
}
