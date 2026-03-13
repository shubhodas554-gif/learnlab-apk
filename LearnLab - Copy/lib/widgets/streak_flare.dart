import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StreakFlare extends StatelessWidget {
  const StreakFlare({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset('assets/lottie/streak.json', repeat: false),
        const Icon(Icons.local_fire_department, color: Colors.orange, size: 48),
      ],
    );
  }
}
