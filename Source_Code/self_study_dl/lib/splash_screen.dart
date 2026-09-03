import 'package:flutter/material.dart';
import 'prototype_web_sim.dart';
import 'login_screen.dart';
import 'dart:math';
import 'dart:ui' as ui;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  
  late Animation<double> _drawAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 1. Elegant Tracing Animation
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOutSine, // Smooth elegant curve
    );

    // 2. Text Fade & Blur Animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // 3. Final Image Fade Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    _runAnimationSequence();
  }

  Future<void> _runAnimationSequence() async {
    // Start drawing the elegant logo
    await _drawController.forward();
    
    // Reveal text
    await _textController.forward();
    
    // Hold for a moment
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Fade in the actual photo
    await _fadeController.forward();
    
    // Hold briefly before navigating
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _drawController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // Standard Aesthetic Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF), Color(0xFFE0F2FE)],
              ),
            ),
          ),
          
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Elegant Animated Vector Logo
            AnimatedBuilder(
              animation: Listenable.merge([_drawController, _textController, _fadeController]),
              builder: (context, child) {
                return Opacity(
                  opacity: 1.0 - _fadeAnimation.value,
                  child: CustomPaint(
                    size: const Size(280, 280),
                    painter: ElegantLogoPainter(
                      drawProgress: _drawAnimation.value,
                      textProgress: _textScaleAnimation.value,
                    ),
                  ),
                );
              },
            ),
            
            // Final Exact Photo Fade-In
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Image.asset(
                    'assets/logo.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink(); 
                    }
                  ),
                );
              }
            ),
          ],
        ),
      ),
    ],
  ),
);
  }
}

class ElegantLogoPainter extends CustomPainter {
  final double drawProgress;
  final double textProgress;

  ElegantLogoPainter({required this.drawProgress, required this.textProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;
    
    // ----------------------------------------------------------------
    // 1. FORK PATH (Golden Orange)
    // ----------------------------------------------------------------
    final forkPaint = Paint()
      ..color = const Color(0xFFF28C28) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final forkPath = Path();
    forkPath.addArc(Rect.fromCircle(center: center, radius: radius), pi, pi);
    
    final forkEndX = center.dx + radius;
    final forkEndY = center.dy;
    
    forkPath.moveTo(forkEndX, forkEndY);
    forkPath.lineTo(forkEndX + 15, forkEndY);
    forkPath.moveTo(forkEndX + 15, forkEndY - 15);
    forkPath.lineTo(forkEndX + 35, forkEndY - 15);
    forkPath.moveTo(forkEndX + 15, forkEndY);
    forkPath.lineTo(forkEndX + 40, forkEndY);
    forkPath.moveTo(forkEndX + 15, forkEndY + 15);
    forkPath.lineTo(forkEndX + 35, forkEndY + 15);
    forkPath.moveTo(forkEndX + 15, forkEndY - 15);
    forkPath.lineTo(forkEndX + 15, forkEndY + 15);

    _drawElegantTrace(canvas, forkPath, forkPaint, drawProgress, textProgress);

    // ----------------------------------------------------------------
    // 2. LEAF PATH (Emerald Green)
    // ----------------------------------------------------------------
    final leafPaint = Paint()
      ..color = const Color(0xFF2E8B57)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leafPath = Path();
    leafPath.addArc(Rect.fromCircle(center: center, radius: radius), 0, pi);
    
    final leafEndX = center.dx - radius;
    final leafEndY = center.dy;
    
    leafPath.moveTo(leafEndX, leafEndY);
    leafPath.quadraticBezierTo(leafEndX - 20, leafEndY + 30, leafEndX - 40, leafEndY);
    leafPath.quadraticBezierTo(leafEndX - 20, leafEndY - 30, leafEndX, leafEndY);
    leafPath.moveTo(leafEndX - 40, leafEndY);
    leafPath.lineTo(leafEndX - 10, leafEndY);

    // Stagger the leaf slightly
    final leafProgress = (drawProgress - 0.15).clamp(0.0, 0.85) / 0.85;
    _drawElegantTrace(canvas, leafPath, leafPaint, leafProgress, textProgress);

    // ----------------------------------------------------------------
    // 3. TEXT (Fade & Blur in center)
    // ----------------------------------------------------------------
    if (textProgress > 0.01) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      // Soft vertical slide up
      canvas.translate(0, 15 * (1.0 - textProgress));
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: "Healthy Food AI",
          style: TextStyle(
            color: const Color(0xFF2E8B57).withOpacity(textProgress),
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  void _drawElegantTrace(Canvas canvas, Path originalPath, Paint paint, double progress, double fadeOutProgress) {
    if (progress <= 0.0) return;
    
    final metrics = originalPath.computeMetrics();
    final drawPath = Path();
    
    Offset? headPosition;
    
    for (var metric in metrics) {
      final extractLength = metric.length * progress;
      drawPath.addPath(metric.extractPath(0.0, extractLength), Offset.zero);
      
      if (progress < 1.0) {
        final tangent = metric.getTangentForOffset(extractLength);
        if (tangent != null) {
          headPosition = tangent.position;
        }
      }
    }
    
    final opacityMultiplier = (1.0 - fadeOutProgress).clamp(0.0, 1.0);
    
    // Draw thick soft glow
    final glowPaint = Paint()
      ..color = paint.color.withOpacity(0.4 * opacityMultiplier)
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth + 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      
    // Draw inner bright core
    final corePaint = Paint()
      ..color = Colors.white.withOpacity(opacityMultiplier)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(drawPath, glowPaint);
    canvas.drawPath(drawPath, paint);
    if (opacityMultiplier > 0.01) {
      canvas.drawPath(drawPath, corePaint); // Makes it look neon/glowing
    }
    
    // Draw leading flare/sparkle
    if (headPosition != null && progress < 1.0) {
      final flarePaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      
      // A bright white tip at the leading edge of the stroke
      canvas.drawCircle(headPosition, 4.0, flarePaint);
      
      final glowFlare = Paint()
        ..color = paint.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawCircle(headPosition, 12.0, glowFlare);
    }
  }

  @override
  bool shouldRepaint(ElegantLogoPainter oldDelegate) {
    return oldDelegate.drawProgress != drawProgress || oldDelegate.textProgress != textProgress;
  }
}
