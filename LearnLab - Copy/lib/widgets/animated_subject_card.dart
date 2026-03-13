import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedSubjectCard extends StatelessWidget {
  const AnimatedSubjectCard({super.key, required this.title, required this.onTap, this.asset});
  final String title;
  final VoidCallback onTap;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Tap to start', style: TextStyle(color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ),
            if (asset != null)
              SizedBox(height: 72, width: 72, child: Lottie.asset(asset!, repeat: true)),
          ],
        ),
      ),
    );
  }
}
