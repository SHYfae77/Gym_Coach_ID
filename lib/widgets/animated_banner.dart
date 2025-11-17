// lib/widgets/animated_banner.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBanner extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final double height;

  const AnimatedBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.height = 88,
  });

  @override
  State<AnimatedBanner> createState() => _AnimatedBannerState();
}
  
class _AnimatedBannerState extends State<AnimatedBanner>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl; // one-shot entrance
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fadeIn;

  late final AnimationController _shimmerCtrl; // looping shimmer
  late final AnimationController _iconCtrl; // subtle icon rotation/scale

  @override
  void initState() {
    super.initState();

    // Entrance animation (runs once)
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _fadeIn = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn);

    // Shimmer loop for the bar
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Icon micro animation
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // start entrance
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _shimmerCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Widget _buildShimmerBar() {
    return LayoutBuilder(builder: (context, constraints) {
      final barWidth = constraints.maxWidth * 0.36;
      return SizedBox(
        height: 8,
        child: Stack(
          children: [
            Container(
              width: barWidth,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // moving shimmer
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (context, child) {
                  final pos = _shimmerCtrl.value; // 0..1
                  final shimmerWidth = barWidth * 0.45;
                  final left = (barWidth + shimmerWidth) * pos - shimmerWidth;
                  return Transform.translate(
                    offset: Offset(left.clamp(-shimmerWidth, barWidth), 0),
                    child: Container(
                      width: shimmerWidth,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.16),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFFF7A00);
    final sizeH = widget.height;

    return SlideTransition(
      position: _slideIn,
      child: FadeTransition(
        opacity: _fadeIn,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: sizeH,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(0.12),
                    Colors.white10.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon circle with subtle rotation + glow
                  AnimatedBuilder(
                    animation: _iconCtrl,
                    builder: (context, child) {
                      final t = _iconCtrl.value;
                      final scale = 0.98 + 0.04 * math.sin(2 * math.pi * t);
                      final rotate = math.sin(2 * math.pi * t) * 0.06;
                      return Transform.rotate(
                        angle: rotate,
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: sizeH - 28,
                            height: sizeH - 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [accent.withOpacity(0.95), Colors.deepOrange.shade700],
                                center: const Alignment(-0.3, -0.3),
                                radius: 0.9,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.25),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: const Icon(Icons.fitness_center, color: Colors.black, size: 28),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // animated shimmer bar
                        _buildShimmerBar(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // CHEVRON (visual only; whole card already tappable)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
