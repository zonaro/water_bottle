import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bubble.dart';
import 'water_container.dart';
import 'wave.dart';

typedef TestTube = CilindricBottle;
typedef WaterBottle = CilindricBottle;

class CilindricBottle extends StatefulWidget {
  /// Color of the water
  final Color waterColor;

  /// Color of the bottle
  final Color bottleColor;

  /// Color of the bottle cap
  final Color? capColor;

  final int bubbleCount;

  final int waveCount;

  final double level;

  /// Create a regular bottle, you can customize it's part with
  /// [waterColor], [bottleColor], [capColor].
  CilindricBottle({
    Key? key,
    this.waterColor = Colors.blue,
    this.bottleColor = const Color(0xFF8DCBFF),
    this.capColor = null,
    this.bubbleCount = 10,
    this.waveCount = 3,
    this.level = 0.5,
  }) : super(key: key);

  factory CilindricBottle.withQuantity({
    required double quantity,
    required double maxQuantity,
    Color waterColor = Colors.blue,
    Color bottleColor = const Color(0xFF8DCBFF),
    Color? capColor,
    int bubbleCount = 10,
    int waveCount = 3,
  }) {
    if (maxQuantity == 0) maxQuantity = 1;
    quantity = quantity.clamp(0, maxQuantity);

    return CilindricBottle(
      waterColor: waterColor,
      bottleColor: bottleColor,
      capColor: capColor,
      bubbleCount: bubbleCount,
      waveCount: waveCount,
      level: quantity / maxQuantity,
    );
  }

  @override
  CilindricBottleState createState() => CilindricBottleState();
}

class CilindricBottleState extends State<CilindricBottle> with TickerProviderStateMixin, WaterContainer {
  @override
  Widget build(BuildContext context) {
    bubbleCount = widget.bubbleCount;
    waveCount = widget.waveCount;
    if (widget.waterColor != waveColor) {
      waveColor = widget.waterColor;
      for (var wave in waves) {
        wave.color = waveColor;
      }
    }
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: CustomPaint(
            painter: WaterBottlePainter(
              waves: waves,
              bubbles: bubbles,
              level: widget.level,
              bottleColor: widget.bottleColor,
              capColor: widget.capColor,
              bubbleCount: widget.bubbleCount,
              waveCount: widget.waveCount,
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

class WaterBottlePainter extends CustomPainter {
  /// Holds all wave object instances
  final List<WaveLayer> waves;

  /// Holds all bubble object instances
  final List<Bubble> bubbles;

  /// Water level, 0 = no water, 1 = full water
  final double level;

  /// Bottle color
  final Color bottleColor;

  /// Bottle cap color
  final Color? capColor;

  final int waveCount;
  final int bubbleCount;

  WaterBottlePainter({
    Listenable? repaint,
    required this.waves,
    required this.bubbles,
    required this.level,
    required this.bottleColor,
    required this.capColor,
    this.waveCount = 3,
    this.bubbleCount = 10,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    {
      final paint = Paint();
      paint.color = bottleColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      paintEmptyBottle(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.color = bottleColor;
      paint.style = PaintingStyle.fill;
      final rect = Rect.fromLTRB(0, 0, size.width, size.height);
      canvas.saveLayer(rect, paint);
      paintBottleMask(canvas, size, paint);
    }
    if (level > 0) {
      {
        final paint = Paint();
        paint.blendMode = BlendMode.srcIn;
        paint.style = PaintingStyle.fill;
        paintWaves(canvas, size, paint);
      }
      {
        final paint = Paint();
        paint.blendMode = BlendMode.srcATop;
        paint.style = PaintingStyle.fill;
        paintBubbles(canvas, size, paint);
      }
    }
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paintGlossyOverlay(canvas, size, paint);
    }
    canvas.restore();
    if (capColor != null) {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paint.color = capColor!;
      paintCap(canvas, size, paint);
    }
  }

  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(Rect.fromLTRB(neckRingInner + 5, 0, neckRingInnerR - 5, size.height - 5), paint);
  }

  void paintBubbles(Canvas canvas, Size size, Paint paint) {
    for (var bubble in bubbles) {
      paint.color = bubble.color;
      final offset = Offset(bubble.x * size.width, (bubble.y + 1.0 - level) * size.height);
      final radius = bubble.size * math.min(size.width, size.height);
      canvas.drawCircle(offset, radius, paint);
    }
  }

  void paintCap(Canvas canvas, Size size, Paint paint) {
    final capTop = 0.0;
    final capBottom = size.width * 0.2;
    final capMid = (capBottom - capTop) / 2;
    final capL = size.width * 0.08 + 5;
    final capR = size.width - capL;
    final neckRingInner = size.width * 0.1 + 5;
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

  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final neckTop = size.width * 0.1;
    final neckBottom = size.height;
    final neckRingOuter = 0.0;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    path.lineTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    canvas.drawPath(path, paint);
  }

  void paintGlossyOverlay(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withAlpha(20);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width * 0.5, size.height), paint);
    paint.color = Colors.white.withAlpha(80);
    canvas.drawRect(Rect.fromLTRB(size.width * 0.9, 0, size.width * 0.95, size.height), paint);
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
      colors: [
        Colors.white.withAlpha(180),
        Colors.white.withAlpha(0),
      ],
    ).createShader(rect);
    paint.color = Colors.white;
    paint.shader = gradient;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  void paintWaves(Canvas canvas, Size size, Paint paint) {
    for (var wave in waves) {
      paint.color = wave.color;
      final transform = Matrix4.identity();
      final desiredW = 15 * size.width;
      final desiredH = 0.1 * size.height;
      final translateRange = desiredW - size.width;
      final scaleX = desiredW / wave.svgData.getBounds().width;
      final scaleY = desiredH / wave.svgData.getBounds().height;
      final translateX = -wave.offset * translateRange;
      final waterRange = size.height + desiredH; // 0 = no water = size.height; 1 = full water = -size.width
      final translateY = (1.0 - level) * waterRange - desiredH;
      transform.translate(translateX, translateY);
      transform.scale(scaleX, scaleY);
      canvas.drawPath(wave.svgData.transform(transform.storage), paint);
      if (waves.indexOf(wave) != waves.length - 1) {
        continue;
      }
      final gap = size.height - desiredH - translateY;
      if (gap > 0) {
        canvas.drawRect(Rect.fromLTRB(0, desiredH + translateY, size.width, size.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) => true;
}
