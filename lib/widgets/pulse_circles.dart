import 'package:flutter/material.dart';

class PulseCircles extends StatefulWidget {
  const PulseCircles({
    required this.isActive,
    required this.diameter,
    required this.color,
    super.key,
  });

  final bool isActive;
  final double diameter;
  final Color color;

  @override
  State<PulseCircles> createState() => _PulseCirclesState();
}

class _PulseCirclesState extends State<PulseCircles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant PulseCircles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    if (widget.isActive) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = widget.diameter * 2.4;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: widget.isActive ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: RepaintBoundary(
          child: SizedBox.square(
            dimension: canvasSize,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _PulsePainter(
                  progress: _controller.value,
                  diameter: widget.diameter,
                  color: widget.color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  const _PulsePainter({
    required this.progress,
    required this.diameter,
    required this.color,
  });

  final double progress;
  final double diameter;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = diameter / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var index = 0; index < 3; index++) {
      final phase = (progress + index / 3) % 1;
      paint.color = color.withValues(alpha: 0.4 * (1 - phase));
      canvas.drawCircle(center, baseRadius * (1 + phase * 1.2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      diameter != oldDelegate.diameter ||
      color != oldDelegate.color;
}
