class Workout {
  final String id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final int minutes;
  final List<String> steps;

  Workout({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.minutes,
    required this.steps,
  });
}

final List<Workout> sampleWorkouts = [
  Workout(
    id: 'w1',
    title: 'Push Up Dasar',
    subtitle: 'Latihan upper body',
    imageAsset: 'assets/images/pushup.jpg',
    minutes: 10,
    steps: [
      'Mulai dalam posisi plank.',
      'Turunkan badan hingga dada hampir menyentuh lantai.',
      'Dorong badan kembali ke posisi awal.',
      'Ulangi 3 set x 10 repetisi.',
    ],
  ),
  Workout(
    id: 'w2',
    title: 'Squat Sederhana',
    subtitle: 'Latihan kaki & glute',
    imageAsset: 'assets/images/squat.jpeg',
    minutes: 12,
    steps: [
      'Berdiri selebar bahu.',
      'Turunkan pinggul seperti duduk.',
      'Dorong tumit untuk kembali berdiri.',
      '3 set x 12 repetisi.',
    ],
  ),
  Workout(
    id: 'w3',
    title: 'Plank Inti',
    subtitle: 'Latihan core',
    imageAsset: 'assets/images/plank.jpeg',
    minutes: 5,
    steps: [
      'Posisikan lengan bawah di lantai.',
      'Jaga tubuh tetap lurus.',
      'Tahan 30-60 detik, ulang 3 kali.',
    ],
  ),
  Workout(
    id: 'w4',
    title: 'Jumping Jack',
    subtitle: 'Latihan full-body cardio',
    imageAsset: 'assets/images/jumping_jack.jpeg',
    minutes: 8,
    steps: [
      'Mulai dengan berdiri tegak.',
      'Loncat sambil membuka kaki dan mengangkat tangan.',
      'Kembali ke posisi awal.',
      'Lakukan selama 45 detik, istirahat 15 detik, ulangi 4 kali.',
    ],
  ),
  Workout(
    id: 'w5',
    title: 'Mountain Climber',
    subtitle: 'Core & Cardio',
    imageAsset: 'assets/images/mountain_climber.jpeg',
    minutes: 6,
    steps: [
      'Mulai posisi push-up.',
      'Angkat lutut kanan ke arah dada.',
      'Ganti lutut kiri dengan cepat.',
      'Lakukan 3 ronde x 30 detik.',
    ],
  ),
  Workout(
    id: 'w6',
    title: 'Sit Up',
    subtitle: 'Latihan perut dasar',
    imageAsset: 'assets/images/situp.jpeg',
    minutes: 7,
    steps: [
      'Berbaring dengan lutut ditekuk.',
      'Angkat tubuh ke arah lutut.',
      'Kembali turun perlahan.',
      '3 set x 15 repetisi.',
    ],
  ),
  Workout(
    id: 'w7',
    title: 'Burpee',
    subtitle: 'Latihan eksplosif full-body',
    imageAsset: 'assets/images/burpee.jpeg',
    minutes: 9,
    steps: [
      'Mulai berdiri tegak.',
      'Turun ke squat lalu posisi plank.',
      'Lakukan push-up opsional.',
      'Loncat ke atas dengan ledakan.',
      'Ulangi 10 repetisi x 3 set.',
    ],
  ),
  Workout(
    id: 'w8',
    title: 'Wall Sit',
    subtitle: 'Latihan kaki statis',
    imageAsset: 'assets/images/wallsit.jpeg',
    minutes: 4,
    steps: [
      'Bersandar pada dinding.',
      'Turun hingga lutut 90°.',
      'Tahan 30-45 detik.',
      'Ulangi 4-5 ronde.',
    ],
  ),
  Workout(
    id: 'w9',
    title: 'High Knees',
    subtitle: 'Cardio intensitas tinggi',
    imageAsset: 'assets/images/high_knees.jpg',
    minutes: 6,
    steps: [
      'Berdiri tegak.',
      'Angkat lutut setinggi mungkin secara cepat bergantian.',
      'Lakukan 30 detik, istirahat 15 detik.',
      'Ulangi 4 ronde.',
    ],
  ),
];
