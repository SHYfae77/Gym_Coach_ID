import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String _email = 'Pengguna';
  int _workouts = 24;
  int _xp = 420;
  int _streakDays = 5;

  // Theme handling: follow system by default, allow user override
  bool _useSystemTheme = true;
  bool _isDark = false;

  // Animation controller for page entrance
  late final AnimationController _enterController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Entrance animation
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);

    // Start entrance animation slightly delayed to feel smooth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterController.forward();
      // read initial system brightness
      final brightness = MediaQuery.platformBrightnessOf(context);
      setState(() {
        _isDark = brightness == Brightness.dark;
      });
    });

    _load();
  }

  Future<void> _load() async {
    // try to load email / xp from AuthService if available, otherwise fallback
    try {
      final e = await AuthService.getUserEmail();
      if (e != null) _email = e;
    } catch (_) {}

    try {
  _xp = await AuthService.getUserXP();
} catch (_) {}

try {
  _workouts = await AuthService.getUserWorkouts();
} catch (_) {}

try {
  _streakDays = await AuthService.getUserStreak();
} catch (_) {}


    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  // Determine badge level from XP
  String get _badgeLabel {
    if (_xp >= 1500) return 'Gold';
    if (_xp >= 500) return 'Silver';
    return 'Bronze';
  }

  // Color for badge
  Color badgeColor(bool dark) {
    switch (_badgeLabel) {
      case 'Gold':
        return dark ? const Color(0xFFCF9F3A) : const Color(0xFFFFD166);
      case 'Silver':
        return dark ? const Color(0xFFB0BDC8) : const Color(0xFFDDE6F0);
      default:
        return dark ? const Color(0xFFB06B2E) : const Color(0xFFFFB27A);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Choose theme based on system or override
    final systemDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final dark = _useSystemTheme ? systemDark : _isDark;

    // Dynamic background gradients for light/dark
    final bgGradient = dark
        ? const LinearGradient(
            colors: [Color(0xFF232536), Color.fromARGB(255, 156, 94, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF4B39EF), Color.fromARGB(255, 31, 31, 59)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final textColor = dark ? Colors.white : Colors.white;

    return Scaffold(
      // remove default appBar to use custom header with animation
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header + edit button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Profil',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        // small edit/profile settings icon (animated)
                        ScaleTransition(
                          scale: CurvedAnimation(parent: _enterController, curve: const Interval(0.5, 1.0, curve: Curves.elasticOut)),
                          child: InkWell(
                            onTap: () {
                              // placeholder - add edit profile later
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit profil (belum diimplementasikan)')),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.edit, color: Colors.white.withOpacity(0.9)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Avatar + Info Card with subtle animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundImage: const AssetImage('assets/images/avatar.jpeg'),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _email,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Pemula • Bergabung sejak 2025',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                // Badge row: level + xp
                                Row(
                                  children: [
                                    // animated badge: switcher
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 500),
                                      transitionBuilder: (child, anim) {
                                        return ScaleTransition(scale: anim, child: child);
                                      },
                                      child: _buildBadge(badgeColor(dark), _badgeLabel, key: ValueKey(_badgeLabel)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('$_xp XP', style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Statistik glass card with small number animations
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _animatedStatItem('Latihan', _workouts.toString()),
                          _animatedStatItem('XP', _xp.toString()),
                          _animatedStatItem('Streak', '${_streakDays}d'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Preferensi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        Text(
                          _useSystemTheme ? 'Ikuti Sistem' : (_isDark ? 'Gelap' : 'Terang'),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Mode Gelap (auto + override)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ListTile(
                        title: const Text('Mode Gelap', style: TextStyle(color: Colors.white)),
                        subtitle: Text(_useSystemTheme ? 'Mengikuti tema sistem' : (_isDark ? 'Diaktifkan' : 'Dinonaktifkan'),
                            style: const TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // toggle auto/system switch
                            Tooltip(
                              message: 'Ikuti tema sistem',
                              child: Checkbox(
                                value: _useSystemTheme,
                                onChanged: (v) {
                                  setState(() {
                                    _useSystemTheme = v ?? true;
                                    if (_useSystemTheme) {
                                      _isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
                                    }
                                  });
                                },
                                checkColor: Colors.black,
                                activeColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Switch(
                              value: _useSystemTheme ? (MediaQuery.platformBrightnessOf(context) == Brightness.dark) : _isDark,
                              onChanged: (val) {
                                if (_useSystemTheme) {
                                  // switching while in system mode will disable system follow
                                  setState(() {
                                    _useSystemTheme = false;
                                    _isDark = val;
                                  });
                                } else {
                                  setState(() {
                                    _isDark = val;
                                  });
                                }
                              },
                              activeColor: const Color(0xFFFF7A00),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Pengingat
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ListTile(
                        title: const Text('Pengingat', style: TextStyle(color: Colors.white)),
                        trailing: Switch(
                          value: false,
                          onChanged: (_) {
                            // add real logic later
                          },
                          activeColor: const Color(0xFFFF7A00),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Logout button (premium style) with entrance stagger
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Small reusable widget for animated stat items
  Widget _animatedStatItem(String label, String val) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          builder: (context, v, child) {
            return Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, (1 - v) * 6),
                child: Text(
                  val,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  // Badge builder
  Widget _buildBadge(Color color, String label, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _badgeLabel == 'Gold' ? Icons.emoji_events_outlined : (_badgeLabel == 'Silver' ? Icons.shield_outlined : Icons.star_border),
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
