import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bubble.dart';
import 'water_bottle.dart';
import 'water_container.dart';
import 'wave.dart';

typedef EnrlenmeyerBottle = TriangularBottle;
typedef EnrlenmeyerFlask = TriangularBottle;

class TriangularBottle extends StatefulWidget {
  /// Color of the water
  final Color waterColor;

  /// Color of the bottle
  final Color bottleColor;

  /// Color of the bottle cap
  final Color capColor;

  final int bubbleCount;

  final int waveCount;

  final double level;

  TriangularBottle({
    Key? key,
    this.waterColor = Colors.blue,
    this.bottleColor = Colors.cyan,
    this.capColor = Colors.blueGrey,
    this.bubbleCount = 10,
    this.waveCount = 3,
    this.level = .5,
  }) : super(key: key);
  @override
  TriangularBottleState createState() => TriangularBottleState();
}

class TriangularBottleState extends State<TriangularBottle> with TickerProviderStateMixin, WaterContainer {
  @override
  Widget build(BuildContext context) {
    bubbleCount = widget.bubbleCount;
    waveCount = widget.waveCount;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: CustomPaint(
            painter: TriangularBottleStatePainter(
              waves: waves,
              bubbles: bubbles,
              waterLevel: widget.level,
              bottleColor: widget.bottleColor,
              capColor: widget.capColor,
              waterColor: widget.waterColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    disposeWater();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initWater(this);
    waves.first.animation.addListener(() {
      setState(() {});
    });
  }
}

class TriangularBottleStatePainter extends WaterBottlePainter {
  static const BREAK_POINT = 1.2;
  TriangularBottleStatePainter({
    Listenable? repaint,
    required List<WaveLayer> waves,
    required List<Bubble> bubbles,
    required double waterLevel,
    required Color bottleColor,
    required Color capColor,
    required Color waterColor,
  }) : super(
          repaint: repaint,
          waves: waves,
          bubbles: bubbles,
          level: waterLevel,
          bottleColor: bottleColor,
          capColor: capColor,
          waterColor: waterColor,
        );

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    final neckTop = size.width * 0.1;
    final neckBottom = size.height - r + 3;
    final neckRingInner = size.width * 0.35 + 5;
    final neckRingInnerR = size.width - neckRingInner;
    final bodyBottom = size.height - 5;
    final bodyL = 5.0;
    final bodyR = size.width - 5;
    final path = Path();
    path.moveTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);

    final bodyLAX = (neckRingInner - bodyL) * 0.1 + bodyL;
    final bodyLAY = (bodyBottom - neckBottom) * 0.9 + neckBottom;
    final bodyLBX = (bodyR - bodyL) * 0.1 + bodyL;
    final bodyLBY = bodyBottom;
    final bodyRAX = size.width - bodyLAX;
    final bodyRAY = bodyLAY;
    final bodyRBX = size.width - bodyLBX;
    final bodyRBY = bodyLBY;
    path.lineTo(bodyLAX, bodyLAY);
    path.conicTo(bodyL, bodyBottom, bodyLBX, bodyLBY, 1);
    path.lineTo(bodyRBX, bodyRBY);
    path.conicTo(bodyR, bodyBottom, bodyRAX, bodyRAY, 1);

    path.lineTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paintCap(Canvas canvas, Size size, Paint paint) {
    if (size.height / size.width < BREAK_POINT) {
      return;
    }
    final capTop = 0.0;
    final capBottom = size.width * 0.2;
    final capMid = (capBottom - capTop) / 2;
    final capL = size.width * 0.33 + 5;
    final capR = size.width - capL;
    final neckRingInner = size.width * 0.35 + 5;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(capL, capTop);
    path.lineTo(neckRingInner, capMid);
    path.lineTo(neckRingInner, capBottom);
    path.lineTo(neckRingInnerR, capBottom);
    path.lineTo(neckRingInnerR, capMid);
    path.lineTo(capR, capTop);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    final neckTop = size.width * 0.1;
    final neckBottom = size.height - r + 3;
    final neckRingOuter = size.width * 0.28;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    final bodyBottom = size.height;
    final bodyL = 0.0;
    final bodyR = size.width;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);

    final bodyLAX = (neckRingInner - bodyL) * 0.1 + bodyL;
    final bodyLAY = (bodyBottom - neckBottom) * 0.9 + neckBottom;
    final bodyLBX = (bodyR - bodyL) * 0.1 + bodyL;
    final bodyLBY = bodyBottom;
    final bodyRAX = size.width - bodyLAX;
    final bodyRAY = bodyLAY;
    final bodyRBX = size.width - bodyLBX;
    final bodyRBY = bodyLBY;
    path.lineTo(bodyLAX, bodyLAY);
    path.conicTo(bodyL, bodyBottom, bodyLBX, bodyLBY, 1);
    path.lineTo(bodyRBX, bodyRBY);
    path.conicTo(bodyR, bodyBottom, bodyRAX, bodyRAY, 1);

    path.lineTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    canvas.drawPath(path, paint);
  }

  @override
  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    final rect = Offset(0, size.height - r) & size;
    final gradient = RadialGradient(
      center: Alignment.center, // near the top right
      colors: [
        Colors.white.withAlpha(120),
        Colors.white.withAlpha(0),
      ],
    ).createShader(rect);
    paint.color = Colors.white;
    paint.shader = gradient;
    // gradient
    canvas.drawRect(Rect.fromLTRB(5, size.height - r + 3, size.width - 5, size.height - 5), paint);
  }
}
