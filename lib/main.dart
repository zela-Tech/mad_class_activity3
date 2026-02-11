import 'package:flutter/material.dart';
import 'dart:math';

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

class _ValentineHomeState extends State<ValentineHome> {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedEmoji,
            items: emojiOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => selectedEmoji = value ?? selectedEmoji),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: HeartEmojiPainter(type: selectedEmoji),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // GLOWING AURA - Only for Party Heart
    if (type == 'Party Heart') {
      final auraPaint = Paint()
        ..color = Colors.pink.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final auraPath = Path()
        ..moveTo(center.dx, center.dy + 70)
        ..cubicTo(center.dx + 120, center.dy - 5, center.dx + 65, center.dy - 130, center.dx, center.dy - 45)
        ..cubicTo(center.dx - 65, center.dy - 130, center.dx - 120, center.dy - 5, center.dx, center.dy + 70)
        ..close();

      canvas.drawPath(auraPath, auraPaint);
    }

    // Heart base
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    final heartGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.bottomCenter,
      colors: type == 'Party Heart' 
        ? [const Color(0xFFF06292), const Color(0xFFFFCDD2)]
        : [const Color(0xFFF8BBD0), const Color(0xFFD50000)],
    );
    paint.shader = heartGradient.createShader(heartPath.getBounds());
    canvas.drawPath(heartPath, paint);

    // Face features
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30), 0, 3.14, false, mouthPaint);

    if (type == 'Party Heart') {
      // Party hat
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
      
      // Add pom-pom on top of hat
      final pomPaint = Paint()..color = const Color(0xFFFF6F00);
      canvas.drawCircle(Offset(center.dx, center.dy - 110), 8, pomPaint);
      
      // CONFETTI - colorful lines and circles SURROUNDING the heart
      final confettiColors = [Colors.yellow, Colors.pink, Colors.blue, Colors.purple, Colors.orange];
      final random = Random(42);
      
      for (int i = 0; i < 30; i++) {
        final confettiPaint = Paint()..color = confettiColors[i % 5];
        
        double angle = random.nextDouble() * 2 * pi;
        double distance = 120 + random.nextDouble() * 30;
        
        double x = center.dx + distance * cos(angle);
        double y = center.dy + distance * sin(angle);

        if(i % 2 == 0){
          canvas.drawCircle(Offset(x, y), 4, confettiPaint);
        } else {
          confettiPaint.strokeWidth = 3;
          confettiPaint.style = PaintingStyle.stroke;
          
          double lineEndX = x + 10 * cos(angle + pi/4);
          double lineEndY = y + 10 * sin(angle + pi/4);
          
          canvas.drawLine(
            Offset(x, y),
            Offset(lineEndX, lineEndY),
            confettiPaint
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => oldDelegate.type != type;
}