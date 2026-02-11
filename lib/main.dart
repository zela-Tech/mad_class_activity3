import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Lovestruck Heart', 'Party Heart'];
  String selectedEmoji = 'Lovestruck Heart';
  AnimationController? _controller;
  AnimationController? _pulseController;
  bool isPulsing = false;

  @override
void initState() {
  super.initState();
  _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  _controller!.addListener(() => setState(() {}));

  _pulseController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 600),
  lowerBound: 0.9,
  upperBound: 1.1,
);
_pulseController!.addListener(() => setState(() {}));
}

 @override
  void dispose() {
  _controller?.dispose();
  _pulseController?.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Container(
        decoration: BoxDecoration(
          gradient: selectedEmoji == 'Lovestruck Heart'
            ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0), Color(0xFFF48FB1)],
            )
          : null,
      ),
      
      child: Column(
        children: [
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedEmoji,
            items: emojiOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) =>
                setState(() => selectedEmoji = value ?? selectedEmoji),
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
              image: AssetImage('assets/images/sparkly-heart.jpg'),
              fit: BoxFit.cover,
              ),
            ),
        ),
        Expanded(
  child: Center(
    child: CustomPaint(
      size: const Size(300, 300),
      painter: HeartEmojiPainter(
        type: selectedEmoji,
        tick: _controller?.value ?? 0,
        pulseScale: _pulseController?.value ?? 1.0,
      ),
    ),
  ),
),
ElevatedButton(
  onPressed: () {
    setState(() => isPulsing = !isPulsing);
    if (isPulsing) {
      _pulseController?.repeat(reverse: true);
    } else {
      _pulseController?.stop();
      _pulseController?.value = 1.0;
    }
  },
  child: Text(isPulsing ? 'Pulse' : 'Stop Pulse'),
),
const SizedBox(height: 16),
        ],
      ),
    )
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type, required this.tick, this.pulseScale = 1.0});
  final String type;
  final double tick;
  final double pulseScale;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(pulseScale);
    canvas.translate(-center.dx, -center.dy);
    // Heart shape
    final heartPath = Path()
  ..moveTo(center.dx, center.dy + 60)
  ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
  ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
  ..close();

final heartPaint = Paint()
  ..shader = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromARGB(255, 221, 154, 176), Color(0xFFAD1457)],
  ).createShader(Rect.fromCenter(center: center, width: 220, height: 200));

canvas.drawPath(heartPath, heartPaint);

    // Sparkles — dots and short lines in a circle around the heart
    final sparklePaint = Paint()
      ..color = const Color(0xFFFF80AB)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi;
      final radius = 120.0;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius - 20;

      // Twinkle: alternate which sparkles are visible
      final opacity = ((sin((tick * 2 * pi) + (i * pi / 6)) + 1) / 2);
      sparklePaint.color = const Color.fromARGB(255, 182, 3, 63).withOpacity(opacity);

      // Dot
      canvas.drawCircle(Offset(x, y), 2.5, sparklePaint);

      // Short cross lines
      canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), sparklePaint);
      canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), sparklePaint);
    }

    // Heart eyes
    _drawMiniHeart(canvas, Offset(center.dx - 30, center.dy - 15), 12, Colors.white);
    _drawMiniHeart(canvas, Offset(center.dx + 30, center.dy - 15), 12, Colors.white);

    // Smile
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 15), radius: 25),
      0.2, 2.7, false,
      Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round,
    );

    // Party hat
    if (type == 'Lovestruck Heart') {
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, Paint()..color = const Color(0xFFFFD54F));
    }
    canvas.restore();
  }
  

  void _drawMiniHeart(Canvas canvas, Offset pos, double s, Color color) {
    final path = Path()
      ..moveTo(pos.dx, pos.dy + s * 0.4)
      ..cubicTo(pos.dx + s, pos.dy - s * 0.2, pos.dx + s * 0.5, pos.dy - s, pos.dx, pos.dy - s * 0.3)
      ..cubicTo(pos.dx - s * 0.5, pos.dy - s, pos.dx - s, pos.dy - s * 0.2, pos.dx, pos.dy + s * 0.4)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => true;
}