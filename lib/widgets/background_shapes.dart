import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BackgroundShapes extends StatelessWidget {
  const BackgroundShapes({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: CustomPaint(
        painter: ShapesPainter(isDark),
        size: Size.infinite,
      ),
    );
  }
}

class ShapesPainter extends CustomPainter {
  final bool isDark;

  ShapesPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLight = Paint()
      ..color = AppTheme.primary.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    final paintDark = Paint()
      ..color = AppTheme.secondary.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Top left circle
    canvas.drawCircle(const Offset(50, 50), 80, paintLight);

    // Bottom right circle
    canvas.drawCircle(
        Offset(size.width - 50, size.height - 50), 100, paintDark);

    // Top right small
    canvas.drawCircle(Offset(size.width - 60, 80), 40, paintLight);

    // Wave like curve bottom left
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.65,
        size.width * 0.6, size.height * 0.75);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paintDark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShapedScaffold extends StatelessWidget {
  final Widget body;

  const ShapedScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundShapes(),
        Scaffold(
          body: body,
        ),
      ],
    );
  }
}
