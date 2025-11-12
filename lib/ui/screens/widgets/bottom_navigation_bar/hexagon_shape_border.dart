import 'dart:math';

import 'package:flutter/material.dart';

class HexagonBorderShape extends OutlinedBorder {
  final double cornerRadius;

  const HexagonBorderShape(
      {this.cornerRadius = 5.0, BorderSide side = BorderSide.none})
      : super(side: side);

  @override
  OutlinedBorder copyWith({BorderSide? side}) => HexagonBorderShape();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final center = rect.center;
    final radius = rect.shortestSide / 2;
    final angleStep = pi / 3; // 60 degrees in radians

    List<Offset> points = List.generate(6, (i) {
      final angle = -pi / 2 + i * angleStep; // start from top point
      return Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    });

    final path = Path();

    for (int i = 0; i < 6; i++) {
      final prev = points[(i - 1 + 6) % 6];
      final curr = points[i];
      final next = points[(i + 1) % 6];

      final from = curr + (prev - curr).normalize() * cornerRadius;
      final to = curr + (next - curr).normalize() * cornerRadius;

      if (i == 0) {
        path.moveTo(from.dx, from.dy);
      } else {
        path.lineTo(from.dx, from.dy);
      }

      path.quadraticBezierTo(curr.dx, curr.dy, to.dx, to.dy);
    }

    path.close();
    return path;
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return HexagonBorderShape(
      cornerRadius: cornerRadius * t,
      side: side.scale(t),
    );
  }

  @override
  bool get preferPaintInterior => false;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect.deflate(20));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    canvas.drawPath(getOuterPath(rect), paint);
  }
}

extension _OffsetExtensions on Offset {
  Offset normalize() {
    final length = distance;
    return length == 0 ? this : this / length;
  }
}
