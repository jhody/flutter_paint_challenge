import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const radius = 150.0;
const clockRadius = 180.0;
const innerRadius = radius - 25;

const colors = Colors.accents;
const noOfPoints = 60;
const noOfInnerPoints = 25;

const pointAngle = 2 * math.pi / noOfPoints;

/// OR 360/noOfPoints
const innerPointAngle = 2 * math.pi / noOfInnerPoints;

class ColorSelectorPaint extends CustomPainter {
  final Offset currentOffset;
  final Color currentlySelectedColor;

  const ColorSelectorPaint({
    Key? key,
    required this.currentOffset,
    required this.currentlySelectedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerOfCircle = Offset(size.width / 2, size.height / 2);
    canvas.save();

    canvas.rotate(math.pi / 2);

    canvas.scale(1, -1);
    final gradient = SweepGradient(
      colors: colors,
      stops: _colorStops(colors),
    );

    var paint = _mainCircumferencePaint(gradient, centerOfCircle, radius);

    canvas.drawArc(Rect.fromCircle(center: centerOfCircle, radius: radius),
        math.pi * -2, math.pi * 2, false, paint);

    canvas.restore();

    _drawInnerSmallerCircle(canvas, centerOfCircle, radius);

    _drawOutterTicks(canvas);

    _drawInnerTicks(canvas);

    _drawInnerArc(canvas, centerOfCircle);

    _drawSelectorCircle(canvas, currentOffset);
  }

  List<double> _colorStops(List<Color> colors) {
    final sweepAngle = 360 / colors.length;

    final colorStops = <double>[];

    for (int i = 0; i < colors.length; i++) {
      var stop = ((sweepAngle * i + (sweepAngle))) / (360);
      colorStops.add(stop);
    }

    return colorStops;
  }

  Paint _mainCircumferencePaint(
      SweepGradient gradient, Offset centerOfCircle, double radius) {
    return Paint()
      ..strokeWidth = 30
      ..shader = gradient
          .createShader(Rect.fromCircle(center: centerOfCircle, radius: radius))
      ..style = PaintingStyle.stroke;
  }

  void _drawInnerSmallerCircle(
      Canvas canvas, Offset centerOfCircle, double radius) {
    canvas.drawPoints(
      PointMode.points,
      [centerOfCircle],
      _centerCirclePaint(radius),
    );
  }

  void _drawOutterTicks(Canvas canvas) {
    for (int i = 0; i < noOfPoints; i++) {
      var clockTickPaint = _clockTickPaint(clockRadius, i % 5 == 0);
      canvas.drawLine(const Offset(0, -clockRadius),
          const Offset(0.0, -clockRadius + 7), clockTickPaint);

      canvas.rotate(pointAngle);
    }
  }

  void _drawInnerTicks(Canvas canvas) {
    for (int i = 0; i < noOfInnerPoints; i++) {
      var clockTickPaint = _clockTickPaint(innerRadius, false);

      canvas.drawLine(const Offset(0, -innerRadius),
          const Offset(0.0, -innerRadius + 5), clockTickPaint);

      canvas.rotate(innerPointAngle);
    }
  }

  Paint _clockTickPaint(double radius, bool useLarge) {
    return Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = useLarge ? 5 : 2
      ..color = Colors.white60;
  }

  void _drawInnerArc(Canvas canvas, Offset centerOfCircle) {
    final innerArcPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: centerOfCircle, radius: innerRadius + 3),
      -math.pi,
      math.pi / 1.4,
      false,
      innerArcPaint,
    );
  }

  Paint _centerCirclePaint(double radius) {
    return Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius / 1.2
      ..color = currentlySelectedColor;
  }

  void _drawSelectorCircle(Canvas canvas, Offset offset) {
    final selectorCirclePaint = Paint()..color = currentlySelectedColor;

    canvas.drawCircle(offset, 40, selectorCirclePaint);
    canvas.drawCircle(
      offset,
      41,
      selectorCirclePaint
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    return true;
  }
}

class Point {
  final Offset offset;
  final bool useLarge;
  final double angle;

  Point({required this.offset, required this.useLarge, required this.angle});
}

class Helper {
  Helper._();

  static double circumference(double radius) {
    return 2 * math.pi * radius;
  }

  static double area(double radius) {
    return math.pi * (radius * radius);
  }

  static double diameter(double radius) {
    return radius * 2;
  }

  static double getRadians(double value) {
    return (360 * value) * math.pi / 180;
  }

  static Offset selectorOffset(Offset currentOffset) {
    return Offset(
        Helper.calculateDXDifference(currentOffset.dx) + (radius + 60),
        Helper.calculateDYDifference(currentOffset.dy) + (-radius));
  }

  static double calculateDXDifference(double dx) {
    return dx - 360;
  }

  static double calculateDYDifference(double dy) {
    return (dy / 360) * 360;
  }

  /// I used this correcly to get each points of the circle
  /// but was finding it difficult to tilt each points
  static Offset angleOffset(double radius, double angle, {double? pi}) {
    var dx = radius * math.sin(((pi ?? (2 * math.pi)) * angle) / 360);
    var dy = radius * math.cos(((pi ?? (2 * math.pi)) * angle) / 360);

    return Offset(dx, dy);
  }

  static bool canPerformSelectorMotion(double x, double y, h, k) {
    var eqn = (math.pow(x - h, 2) + math.pow(y - k, 2));
    eqn = math.sqrt(eqn);

    return eqn >= radius - 16 && eqn <= radius + 16;
  }

  static Color offsetColor(List<Color> colors, Offset offset) {
    final baseSweepAngle = 360 / colors.length;

    for (int i = 0; i < colors.length; i++) {
      final point1Offset = sweepAngleOffset(baseSweepAngle, i, 0);
      final point2Offset = sweepAngleOffset(baseSweepAngle, i + 1, 0);

      if (offset.direction > (point2Offset.direction) &&
          offset.direction <= point1Offset.direction) {
        return colors[i];
      }
    }
    return Colors.white70;
  }

  static double _sweepAngleByIndex(double baseSweep, int index, int middle) =>
      (baseSweep * (index));

  static Offset sweepAngleOffset(double baseSweepAngle, int index, int middle) {
    final sweepAngle = _sweepAngleByIndex(baseSweepAngle, index, middle);
    var start = (sweepAngle + baseSweepAngle);
    return angleOffset((radius), (start));
  }

  /// Construct a rectangle that bounds the given circle.
  /// The `center` argument is assumed to be an offset from the origin.
  static Rect rectFromCircle(
          {required Offset center, required double radius}) =>
      Rect.fromCenter(
        center: center,
        width: (radius * 1.5),
        height: (radius * 1.5),
      );

  static double archLength(double angle) {
    return angle * (math.pi / 180) * radius;
  }

  static Quadrant getQuadrant(double angle) {
    if (angle >= 0 && angle < math.pi / 2) return Quadrant.BOTTOM_RIGHT;
    if (angle >= math.pi / 2 && angle < math.pi) return Quadrant.BOTTOM_LEFT;
    if (angle <= 0 && angle > -(math.pi / 2)) return Quadrant.TOP_RIGHT;
    if (angle <= math.pi && angle > -math.pi) return Quadrant.TOP_LEFT;
    throw Exception('INVALiD QUADRANT');
  }
}

enum Quadrant {
  BOTTOM_RIGHT,
  BOTTOM_LEFT,
  TOP_RIGHT,
  TOP_LEFT,
}
