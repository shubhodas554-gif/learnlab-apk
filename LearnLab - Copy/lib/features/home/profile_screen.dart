import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _BadgeCard('Starter', 'Earn 100 XP'),
          const _BadgeCard('Streaker', '7-day streak'),
          const _BadgeCard('Scholar', 'Complete 20 lessons'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
      bottomNavigationBar: const _NavBar(index: 4),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard(this.title, this.desc);
  final String title;
  final String desc;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.emoji_events, color: Colors.amber),
          title: Text(title),
          subtitle: Text(desc),
        ),
      );
}

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
  switch (i) {
    case 0:
      context.go('/');
      break;
    case 1:
      context.go('/subjects');
      break;
    case 2:
      context.go('/tutor');
      break;
    case 3:
      context.go('/leaderboard');
      break;
    case 4:
      context.go('/profile');
      break;
  }
}
