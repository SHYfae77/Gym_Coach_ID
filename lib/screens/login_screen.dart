// lib/screens/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();

  late final AnimationController _mainAnim; // runs once for logo+form entrance
  // ignore: unused_field
  late final Animation<double> _logoScale;
  late final Animation<double> _logoShine;
  late final Animation<double> _formSlide;
  late final Animation<double> _formFade;

  // separate small repeating controller for subtle background motion only
  late final AnimationController _bgLoop;
  late final Animation<double> _bgShift;

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Main entrance animation: run ONCE
    _mainAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    // Logo: pop (0.0 - 0.45)
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnim, curve: const Interval(0.0, 0.45, curve: Curves.elasticOut)),
    );

    // Shine sweep across logo (0.25 - 0.9)
    _logoShine = Tween<double>(begin: -1.2, end: 1.8).animate(
      CurvedAnimation(parent: _mainAnim, curve: const Interval(0.25, 0.9, curve: Curves.easeInOut)),
    );

    // Form: slide up + fade in (0.45 - 1.0)
    _formSlide = Tween<double>(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainAnim, curve: const Interval(0.45, 1.0, curve: Curves.easeOut)),
    );
    _formFade = CurvedAnimation(parent: _mainAnim, curve: const Interval(0.45, 1.0, curve: Curves.easeIn));

    // start the one-shot entrance animation
    _mainAnim.forward();

    // Background loop (subtle) — only affects background translation, not form visibility
    _bgLoop = AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _bgShift = Tween<double>(begin: -10.0, end: 10.0).animate(CurvedAnimation(parent: _bgLoop, curve: Curves.easeInOut));
    _bgLoop.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainAnim.dispose();
    _bgLoop.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() {
    _loading = true;
    _error = null;
  });

  final ok = await AuthService.login(_emailCtl.text.trim(), _passCtl.text.trim());

  if (!mounted) return;
  setState(() {
    _loading = false;
  });

  if (ok) {
    _navigateToHome(); // <-- navigasi hanya jika login berhasil
  } else {
    setState(() => _error = 'Email atau kata sandi salah / tidak boleh kosong');
  }
}

Future<void> _signInWithGoogle() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  final ok = await AuthService.signInWithGoogle();

  if (!mounted) return;
  setState(() {
    _loading = false;
  });

  if (ok) {
    _navigateToHome();
  } else {
    setState(() => _error = 'Gagal masuk dengan Google.');
  }
}

Future<void> _guest() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  final ok = await AuthService.login('tamu@example.com', 'tamu');

  if (!mounted) return;
  setState(() {
    _loading = false;
  });

  if (ok) {
    _navigateToHome();
  } else {
    setState(() => _error = 'Gagal login sebagai tamu.');
  }
}

void _navigateToHome() {
  if (!mounted) return;
  Navigator.of(context).pushReplacement(_createRouteToHome());
}


  PageRouteBuilder _createRouteToHome() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 650),
      pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final scale = Tween<double>(begin: 0.98, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);

        return SlideTransition(
          position: slide,
          child: ScaleTransition(scale: scale, child: FadeTransition(opacity: fade, child: child)),
        );
      },
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Asset background with subtle parallax shift (looping animation)
          AnimatedBuilder(
            animation: _bgShift,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_bgShift.value, 0),
                child: Image.asset('assets/images/bg_login.jpeg', fit: BoxFit.cover),
              );
            },
          ),

          // dark overlay for readability
          Container(color: Colors.black.withOpacity(0.48)),

          // soft radial glow (static-ish; only subtly influenced by bgLoop value)
          AnimatedBuilder(
            animation: _bgShift,
            builder: (context, child) {
              final t = (_bgShift.value + 10) / 20.0; // 0..1
              final colorA = Color.lerp(const Color(0x00000000), const Color(0xFF4B39EF).withOpacity(0.14), t)!;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.6, -0.4),
                    radius: 1.1,
                    colors: [colorA, Colors.transparent],
                  ),
                ),
              );
            },
          ),

          // center content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'app-logo',
                      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                        // scale + glow while flying
                        final scaleAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                        );
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final scale = scaleAnim.value;
                            final opacity = (0.6 + (animation.value * 0.4)).clamp(0.0, 1.0);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.10 * opacity),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF7A00).withOpacity(0.28 * opacity),
                                      blurRadius: 26 * opacity,
                                      spreadRadius: 2 * opacity,
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.fitness_center, size: 64, color: Color(0xFFFF7A00)),
                              ),
                            );
                          },
                        );
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            final shinePos = _logoShine.value; // if inside AnimatedBuilder that has access
                            return LinearGradient(
                              colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.95)],
                              stops: [
                                (shinePos - 0.18).clamp(0.0, 1.0),
                                shinePos.clamp(0.0, 1.0),
                                (shinePos + 0.18).clamp(0.0, 1.0)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(rect);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6))],
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Icon(Icons.fitness_center, size: 64, color: Color(0xFFFF7A00)),
                          ),
                        ),
                      ),
                    ),


                    const SizedBox(height: 18),

                    const Text('Selamat Datang', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Masuk untuk melihat tutorial & latihan', style: TextStyle(color: Colors.white70)),

                    const SizedBox(height: 26),

                    // Form area: glass card that slides/fades in (runs once)
                    AnimatedBuilder(
                      animation: _mainAnim,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _formFade.value,
                          child: Transform.translate(
                            offset: Offset(0, _formSlide.value),
                            child: child,
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailCtl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(hint: 'Email', icon: Icons.email_outlined),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Email diperlukan';
                                      final email = v.trim();
                                      final regex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$");
                                      if (!regex.hasMatch(email)) return 'Format email tidak valid';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  TextFormField(
                                    controller: _passCtl,
                                    obscureText: _obscure,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      hint: 'Kata sandi',
                                      icon: Icons.lock_outline,
                                      suffix: IconButton(
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Kata sandi diperlukan';
                                      if (v.trim().length < 4) return 'Minimal 4 karakter';
                                      return null;
                                    },
                                  ),

                                  if (_error != null) ...[
                                    const SizedBox(height: 12),
                                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                                  ],

                                  const SizedBox(height: 18),

                                  // Login button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF7A00),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: _loading
                                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _loading ? null : _signInWithGoogle,
                                          icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                                          label: const Text('Google', style: TextStyle(color: Colors.white)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.white24),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _loading ? null : _guest,
                                          child: const Text('Tamu', style: TextStyle(color: Colors.white70)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.white12),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),
                                  const Text('Dengan masuk, kamu menyetujui Syarat & Ketentuan kami', style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
