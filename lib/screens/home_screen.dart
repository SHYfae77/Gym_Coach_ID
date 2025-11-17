import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../widgets/workout_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/animated_banner.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'workout_detail_screen.dart';
import 'profile_screen.dart';
import '../widgets/challenge_bottom_sheet.dart';    


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _email = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final e = await AuthService.getUserEmail();
    if (e != null) setState(() => _email = e);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    const bg = 'assets/images/bg_home.jpeg';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())), icon: const Icon(Icons.account_circle_outlined)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Stack(children: [
        Image.network(bg, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        Container(color: Colors.black.withOpacity(0.56)),
        const GradientBackground(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Hero(
                  tag: 'app-logo',
                  flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                    // shrink + glow on arrival
                    final scaleAnim = Tween<double>(begin: 1.18, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                    );
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final scale = scaleAnim.value;
                        final opacity = (0.6 + ((1 - animation.value) * 0.4)).clamp(0.0, 1.0);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 44, // keep same visual size as CircleAvatar radius:22
                            height: 44,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04 * opacity),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF7A00).withOpacity(0.18 * opacity),
                                  blurRadius: 18 * opacity,
                                )
                              ],
                            ),
                            child: const Icon(Icons.fitness_center, color: Color(0xFFFF7A00)),
                          ),
                        );
                      },
                    );
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: const AssetImage('assets/images/avatar.jpeg'),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${_email.split('@')[0]}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tingkatkan kebugaranmu • Pemula',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    )
                  ])),
                Container(
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(children: const [
                    Icon(Icons.local_fire_department, color: Color(0xFFFF7A00), size: 18),
                    SizedBox(width: 6),
                    Text('200', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
              const SizedBox(height: 18),

              // animated hero banner
                AnimatedBanner(
                  title: 'Tantangan Harian',
                  subtitle: '150+ Push Up Challenge',
                  onTap: () {
                  final workout = sampleWorkouts[0]; // ganti index sesuai kebutuhan

                  showChallengeBottomSheet(
                    context,
                    title: 'Tantangan Harian',
                    subtitle: '150+ Push Up Challenge',
                    duration: '${workout.minutes} mnt',
                    calories: '120 kcal',
                    difficulty: 'Pemula',
                    onStart: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)),
                      );
                    },
                  );
                },
                ),
                            
              const SizedBox(height: 18),
              const Text('Rekomendasi Latihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),

              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sampleWorkouts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final w = sampleWorkouts[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
                      child: WorkoutCard(workout: w),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              const Text('Semua Latihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.separated(
                  itemCount: sampleWorkouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final w = sampleWorkouts[i];
                    return ListTile(
                      tileColor: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(w.imageAsset, width: 64, height: 64, fit: BoxFit.cover)),
                      title: Text(w.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${w.subtitle} • ${w.minutes} mnt'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00)),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
                        child: const Text('Mulai'),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
