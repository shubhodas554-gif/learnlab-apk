import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class XpBurst extends StatelessWidget {
  const XpBurst({super.key, required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset('assets/lottie/xp.json', repeat: false),
        Text('+${xp} XP', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
      ],
    );
  }
}
