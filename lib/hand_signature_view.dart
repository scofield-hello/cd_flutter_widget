import 'dart:ui' as DartUI;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HandSignatureView extends StatefulWidget {
  HandSignatureView(
      {Key key,
      this.penSize = 5.0,
      this.size = Size.infinite,
      this.penColor = Colors.black,
      this.background = Colors.white})
      : assert(penSize > 0.0),
        super(key: key);
  final Size size;
  final Color penColor;
  final double penSize;
  final Color background;

  @override
  HandSignatureViewState createState() => HandSignatureViewState();
}

class HandSignatureViewState extends State<HandSignatureView> {
  List<Offset> _points = <Offset>[];

  @override
  Widget build(BuildContext context) {
    var customPaint = CustomPaint(
        size: widget.size,
        painter: _PenSignerPainter(_points,
            paintSize: widget.penSize,
            paintColor: widget.penColor,
            backgroundColor: widget.background));
    var gestureDetector = GestureDetector(
      onPanUpdate: (DragUpdateDetails details) {
        RenderBox referenceBox = context.findRenderObject();
        Offset point = referenceBox.globalToLocal(details.globalPosition);
        setState(() {
          _points = List.from(_points)..add(point);
        });
      },
      onPanEnd: (DragEndDetails details) => _points.add(null),
      child: customPaint,
    );
    return Container(child: gestureDetector, color: widget.background);
  }

  void wipe() {
    setState(() {
      _points.clear();
    });
  }

  bool canCapture() {
    return _points.isNotEmpty;
  }

  Future<DartUI.Image> capture() async {
    var recorder = DartUI.PictureRecorder();
    var canvas = Canvas(recorder);
    var painter = _PenSignerPainter(_points,
        paintSize: widget.penSize, paintColor: widget.penColor, backgroundColor: widget.background);
    var size = context.size;
    painter.paint(canvas, size);
    var picture = recorder.endRecording();
    return picture.toImage(size.width.floor(), size.height.floor());
  }
}

class _PenSignerPainter extends CustomPainter {
  _PenSignerPainter(this.points,
      {this.paintSize = 2.0, this.paintColor = Colors.black, this.backgroundColor = Colors.white}) {
    _paint = Paint()
      ..color = paintColor
      ..isAntiAlias = true
      ..strokeWidth = paintSize
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;
  }

  final List<Offset> points;
  final double paintSize;
  final Color paintColor;
  final Color backgroundColor;
  Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(backgroundColor, BlendMode.color);
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null &&
          points[i + 1] != null &&
          points[i + 1].dx >= 0 &&
          points[i + 1].dy >= 0 &&
          points[i + 1].dx <= size.width &&
          points[i + 1].dy <= size.height) {
        canvas.drawLine(points[i], points[i + 1], _paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PenSignerPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
