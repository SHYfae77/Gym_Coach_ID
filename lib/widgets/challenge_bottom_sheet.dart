// lib/widgets/challenge_bottom_sheet.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

Future<void> showChallengeBottomSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  String duration = '15 mnt',
  String calories = '120 kcal',
  String difficulty = 'Pemula',
  required VoidCallback onStart, // dipanggil setelah countdown selesai
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return _ChallengeSheet(
        title: title,
        subtitle: subtitle,
        duration: duration,
        calories: calories,
        difficulty: difficulty,
        onStart: onStart,
      );
    },
  );
}

class _ChallengeSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String calories;
  final String difficulty;
  final VoidCallback onStart;

  const _ChallengeSheet({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.calories,
    required this.difficulty,
    required this.onStart,
    Key? key,
  }) : super(key: key);

  @override
  State<_ChallengeSheet> createState() => _ChallengeSheetState();
}

class _ChallengeSheetState extends State<_ChallengeSheet> with TickerProviderStateMixin {
  int _countdown = 0;
  Timer? _timer;
  late final AnimationController _popCtrl;

  @override
  void initState() {
    super.initState();
    _popCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _popCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_countdown > 0) return;
    setState(() => _countdown = 3);
    _popCtrl.forward(from: 0);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = _countdown - 1;
      if (next <= 0) {
        t.cancel();
        setState(() => _countdown = 0);
        // small delay for UX
        Future.delayed(const Duration(milliseconds: 250), () {
          // close sheet first, then call onStart (so navigating pushes a new route)
          Navigator.of(context).pop();
          widget.onStart();
        });
      } else {
        setState(() => _countdown = next);
        _popCtrl.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFFF7A00);
    // Use MediaQuery to allow full-screen height on big devices
    final maxH = MediaQuery.of(context).size.height * 0.86;

    return GestureDetector(
      // dismiss when tapping outside the sheet content area (on the transparent part)
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: DraggableScrollableSheet(
        initialChildSize: 0.56,
        minChildSize: 0.36,
        maxChildSize: 0.92,
        builder: (context, scrollCtrl) {
          return Container(
            constraints: BoxConstraints(maxHeight: maxH),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border.all(color: Colors.white12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 12)],
              // backdrop filter effect using clip + BackdropFilter
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Stack(
                  children: [
                    // Content scrollable
                    SingleChildScrollView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle + close button
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: 48,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close, color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Header: icon + title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // preview circle
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [accent.withOpacity(0.98), Colors.deepOrange.shade700],
                                    center: const Alignment(-0.3, -0.3),
                                  ),
                                  boxShadow: [BoxShadow(color: accent.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8))],
                                ),
                                child: const Icon(Icons.fitness_center, color: Colors.black, size: 36),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(widget.subtitle, style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                              // share button
                              IconButton(
                                onPressed: () {
                                  // simple share placeholder
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share feature belum diimplementasikan')));
                                },
                                icon: const Icon(Icons.ios_share, color: Colors.white70),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statItem(Icons.timer, widget.duration),
                              _statItem(Icons.local_fire_department, widget.calories),
                              _statItem(Icons.bar_chart, widget.difficulty),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // chips/features
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              _FeatureChip(icon: Icons.calendar_today, label: 'Daily'),
                              _FeatureChip(icon: Icons.timer, label: 'Timed'),
                              _FeatureChip(icon: Icons.fitness_center, label: 'No equipment'),
                              _FeatureChip(icon: Icons.star, label: 'Popular'),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // description
                          const Text('Deskripsi', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text(
                            'Tingkatkan kekuatan tubuh bagian atas dengan rangkaian push-up dan variasinya. Cocok untuk pemula hingga tingkat menengah. Lakukan setiap hari untuk hasil maksimal.',
                            style: TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(height: 16),

                          // benefits
                          const Text('Manfaat', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _BenefitRow(text: 'Meningkatkan kekuatan otot dada & trisep'),
                              _BenefitRow(text: 'Meningkatkan daya tahan kardio'),
                              _BenefitRow(text: 'Tidak perlu alat khusus'),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // start button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _startCountdown,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 6,
                              ),
                              child: const Text('Mulai Tantangan', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // secondary action
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white12),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Tutup', style: TextStyle(color: Colors.white70)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simpan ke favorit')));
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white12),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Simpan'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // countdown overlay (center) when _countdown > 0
                    if (_countdown > 0)
                      Positioned.fill(
                        child: Center(
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.elasticOut)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                _countdown == 0 ? 'Go!' : '$_countdown',
                                style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statItem(IconData icon, String txt) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          Text(txt, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white10,
      avatar: Icon(icon, size: 16, color: Colors.white70),
      label: Text(label, style: const TextStyle(color: Colors.white70)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        const Icon(Icons.check_circle, size: 16, color: Color(0xFFFF7A00)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
      ]),
    );
  }
}
