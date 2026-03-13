import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 72, this.label});
  final double progress; // 0..1
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade200,
          ),
          Text(label ?? '${(progress * 100).round()}%'),
        ],
      ),
    );
  }
}
