import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).value ?? 0;
    final xp = ref.watch(xpProvider).value ?? 0;
    final recs = ref.watch(recommendationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('LearnLab')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Welcome back', style: Theme.of(context).textTheme.titleLarge),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(children: [const Icon(Icons.flash_on, color: Colors.amber), Text('$xp XP')]),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.local_fire_department, color: Colors.orange), Text('$streak day streak')]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _streakCard(streak),
          const SizedBox(height: 12),
          Text('Recommended for you', style: Theme.of(context).textTheme.titleMedium),
          recs.when(
            data: (subjects) => subjects.isEmpty
                ? const Center(child: Text('All caught up! Pick a subject to keep going.'))
                : Column(
                    children: subjects
                        .map((s) => ListTile(
                              leading: const Icon(Icons.bolt, color: Colors.indigo),
                              title: Text(s),
                            ))
                        .toList(),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
      bottomNavigationBar: const _NavBar(index: 0),
    );
  }

  Widget _streakCard(int streak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            const SizedBox(width: 12),
            Text('Streak: $streak days'),
            const Spacer(),
            Text('Keep it up!'),
          ],
        ),
      ),
    );
  }
}
