import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/workout.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutTimerScreen({super.key, required this.workout});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  late Duration _awal;
  late Duration _sisa;
  Timer? _timer;
  bool _berjalan = false;
  int _langkahSekarang = 0;

  late final AudioPlayer _audioPlayer;
  final String _suaraSelesai = 'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg';

  @override
  void initState() {
    super.initState();
    _awal = Duration(minutes: widget.workout.minutes);
    if (_awal.inSeconds == 0) _awal = const Duration(minutes: 1);
    _sisa = _awal;

    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void _mulaiJeda() {
    if (_berjalan) {
      _timer?.cancel();
      setState(() => _berjalan = false);
      return;
    }
    setState(() => _berjalan = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sisa.inSeconds <= 1) {
        t.cancel();
        setState(() {
          _berjalan = false;
          _sisa = const Duration(seconds: 0);
        });
        _selesai();
      } else {
        setState(() => _sisa = _sisa - const Duration(seconds: 1));
      }
    });
  }

  Future<void> _selesai() async {
    try {
      await _audioPlayer.play(UrlSource(_suaraSelesai));
    } catch (e) {
      // ignore
    }
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Sesi Selesai'),
      content: const Text('Kerja bagus! Kamu telah menyelesaikan sesi latihan ini.'),
      actions: [
        TextButton(onPressed: () { Navigator.pop(context); _ulang(); }, child: const Text('Oke')),
      ],
    ));
  }

  void _ulang() {
    _timer?.cancel();
    setState(() {
      _sisa = _awal;
      _berjalan = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatWaktu(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  double get _progres {
    if (_awal.inSeconds == 0) return 0.0;
    return 1.0 - (_sisa.inSeconds / _awal.inSeconds);
  }

  void _langkahBerikut() {
    setState(() {
      if (_langkahSekarang < widget.workout.steps.length - 1) _langkahSekarang++;
    });
  }

  void _langkahSebelum() {
    setState(() {
      if (_langkahSekarang > 0) _langkahSekarang--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final teksLangkah = widget.workout.steps.isNotEmpty ? widget.workout.steps[_langkahSekarang] : 'Ikuti petunjuk';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: Text(widget.workout.title)),
      body: Stack(children: [
        Image.network(widget.workout.imageAsset, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        Container(color: Colors.black.withOpacity(0.6)),
        SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          Expanded(child: Column(children: [
            const SizedBox(height: 12),
            CircleAvatar(radius: 72, backgroundColor: Colors.white12, child: Text(_formatWaktu(_sisa), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: _progres, minHeight: 8, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(const Color(0xFFFF7A00))),
            const SizedBox(height: 18),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Langkah ${_langkahSekarang + 1}/${widget.workout.steps.length}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(teksLangkah, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ])),
              Column(children: [ IconButton(onPressed: _langkahSebelum, icon: const Icon(Icons.chevron_left)), IconButton(onPressed: _langkahBerikut, icon: const Icon(Icons.chevron_right)) ])
            ])),
          ])),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: _mulaiJeda, icon: Icon(_berjalan ? Icons.pause : Icons.play_arrow), label: Text(_berjalan ? 'Jeda' : 'Mulai'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.symmetric(vertical: 14)))),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _ulang, style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)), child: const Icon(Icons.restore)),
          ]),
          const SizedBox(height: 12),
        ]))),
      ]),
    );
  }
}
