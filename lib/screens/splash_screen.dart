// lib/screens/splash_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _shineAnim;
  late final Animation<double> _progressAnim;

  // simple particle positions
  final List<_Particle> _particles = List.generate(8, (i) => _Particle.random());

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // logo scale (pop in)
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.45, curve: Curves.elasticOut)),
    );

    // shine sweep for shader mask
    _shineAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 0.85, curve: Curves.easeInOut)),
    );

    // progress from 0 -> 1
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)),
    );

    // start animation and the splash logic
    _ctrl.forward();
    _startLogic();
    // also animate particles continuously
    Timer.periodic(const Duration(milliseconds: 300), (_) {
      for (final p in _particles) {
        p.update();
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _startLogic() async {
    // wait for the animation to finish OR minimum duration
    // while concurrently checking login status
    final loginFuture = AuthService.isLoggedIn();
    await Future.delayed(const Duration(milliseconds: 1600)); // give time for UX
    final logged = await loginFuture;
    // ensure animation completes nicely
    await _ctrl.animateTo(1.0, duration: const Duration(milliseconds: 450), curve: Curves.easeOut);

    if (!mounted) return;

    // short delay so user sees final frame
    await Future.delayed(const Duration(milliseconds: 280));
    if (logged) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // beautiful background from Unsplash (replace if you want local asset)
    const bg =
        'assets/images/bg_splash.jpeg';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // background image
          Image.network(bg, fit: BoxFit.cover),

          // blurred glass overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // animated gradient glow
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              final t = _ctrl.value;
              final colorA = Color.lerp(const Color(0xFF2B2D42), const Color(0xFF4B39EF), (t * 1.2).clamp(0.0, 1.0))!;
              final colorB = Color.lerp(const Color(0xFF0F1724), const Color(0xFFFF7A00), (t * 0.9).clamp(0.0, 1.0))!;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [colorA.withOpacity(0.18), colorB.withOpacity(0.08)],
                    radius: 1.2,
                    center: Alignment(-0.2 + t * 0.4, -0.4 + t * 0.3),
                  ),
                ),
              );
            },
          ),

          // floating particles
          ..._particles.map((p) {
            return Positioned(
              left: MediaQuery.of(context).size.width * p.x,
              top: MediaQuery.of(context).size.height * p.y,
              child: Opacity(
                opacity: p.opacity,
                child: Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 6)],
                  ),
                ),
              ),
            );
          }).toList(),

          // center content: logo + title + subtitle + progress
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                // shine position for shader
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // logo with shine effect
                    Transform.scale(
                      scale: _logoScale.value,
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          final shinePos = _shineAnim.value;
                          return LinearGradient(
                            colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.9)],
                            stops: [ (shinePos - 0.18).clamp(0.0,1.0), shinePos.clamp(0.0,1.0), (shinePos + 0.18).clamp(0.0,1.0) ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(rect);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))
                            ],
                          ),
                          child: const Icon(Icons.fitness_center, size: 72, color: Color(0xFFFF7A00)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'GymCoach ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mulai latihanmu. Latih dengan benar.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 22),

                    // progress bar + percentage
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.06),
                          valueColor: AlwaysStoppedAnimation(const Color(0xFFFF7A00)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: (_progressAnim.value * 1.0).clamp(0.0,1.0),
                      child: Text(
                        '${(_progressAnim.value * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // small footer note
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Made with ❤️ • GymCoach', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple particle helper
class _Particle {
  double x;
  double y;
  double size;
  double opacity;
  double dx;
  double dy;

  _Particle(this.x, this.y, this.size, this.opacity, this.dx, this.dy);

  // random starter
  factory _Particle.random() {
    final rnd = DateTime.now().microsecondsSinceEpoch;
    final seed = (rnd % 1000) / 1000.0;
    final x = (seed * 0.9).clamp(0.05, 0.95);
    final y = ((seed * 1.3) % 1.0).clamp(0.05, 0.85);
    final size = 4.0 + ((seed * 6) % 8);
    final opacity = 0.03 + ((seed * 0.6) % 0.12);
    final dx = (seed - 0.5) * 0.006;
    final dy = ((seed * 2.0) - 0.6) * 0.004;
    return _Particle(x, y, size, opacity, dx, dy);
  }

  void update() {
    x += dx;
    y += dy;
    opacity = (0.02 + (0.03 * (0.5 + (x % 1.0))));
    if (x < 0.02) x = 0.98;
    if (x > 0.98) x = 0.02;
    if (y < 0.02) y = 0.9;
    if (y > 0.95) y = 0.05;
  }
}
