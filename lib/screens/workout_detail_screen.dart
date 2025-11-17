import 'package:flutter/material.dart';
import '../models/workout.dart';
import 'workout_timer_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        Image.asset(workout.imageAsset, fit: BoxFit.cover, width: double.infinity, height: 320),
        Container(height: 320, color: Colors.black.withOpacity(0.4)),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 220),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F1113),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(workout.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('${workout.subtitle} • ${workout.minutes} mnt', style: const TextStyle(color: Colors.white70)),
                    ])),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutTimerScreen(workout: workout))),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00)),
                      child: const Text('Mulai Latihan'),
                    )
                  ]),
                  const SizedBox(height: 14),
                  const Text('Cara Melakukan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...workout.steps.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.fitness_center, color: Color(0xFFFF7A00))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s)),
                    ]),
                  )),
                  const SizedBox(height: 20),
                  const Text('Tips', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Jaga posisi tubuh, tarik napas dengan teratur, dan utamakan teknik daripada kecepatan.'),
                  const SizedBox(height: 24),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
