import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bubble.dart';
import 'wave.dart';

class WaterContainer {
  /// Holds all wave object instances
  List<WaveLayer> waves = List<WaveLayer>.empty(growable: true);

  /// Holds all bubble object instances
  List<Bubble> bubbles = List<Bubble>.empty(growable: true);

  /// How many wave layer do we need, default 3
  int waveCount = 3;

  /// How many bubbles can exist at the same time? The more the expensive, default 10
  int bubbleCount = 10;

  /// You can set water level with [waterLevel]. 0 = no water, 1 = full water
  double waterLevel = 0.5;

  /// Kill wave and bubble objects
  void disposeWater() {
    waves.forEach((e) => e.dispose());
    bubbles.forEach((e) => e.dispose());
  }

  /// Instantiate wave and bubble objects
  void initWater(Color themeColor, TickerProvider ticker) {
    var f = math.Random().nextInt(5000) + 15000;
    var d = math.Random().nextInt(500) + 1500;
    var color = HSLColor.fromColor(themeColor);
    for (var i = 1; i <= waveCount; i++) {
      final wave = WaveLayer();
      wave.init(ticker, frequency: f);
      final sat = color.saturation * math.pow(0.6, (waveCount - i));
      final light = color.lightness * math.pow(0.8, (waveCount - i));
      wave.color = color.withSaturation(sat).withLightness(light).toColor();
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
