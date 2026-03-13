import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = ref.watch(_leaderboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: top.when(
        data: (entries) => ListView.builder(
          itemCount: entries.length,
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(child: Text('#${i + 1}')),
            title: Text(entries[i].uid),
            trailing: Text('${entries[i].xp} XP'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: const _NavBar(index: 3),
    );
  }
}

final _leaderboardProvider = StreamProvider((ref) {
  return ref.watch(leaderboardRepositoryProvider).topUsers(limit: 20);
});

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Subjects'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'AI Tutor'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Leaderboard'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (i) => _go(context, i),
      );
}

void _go(BuildContext context, int i) {
  final routes = ['/', '/subjects', '/tutor', '/leaderboard', '/profile'];
  Navigator.pushNamed(context, routes[i]);
}
