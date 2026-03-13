import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../widgets/animated_subject_card.dart';

class SubjectScreen extends ConsumerWidget {
  const SubjectScreen({super.key});
  static const subjects = Subject.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: subjects.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subjects'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Physics'),
              Tab(text: 'Chemistry'),
              Tab(text: 'Biology'),
              Tab(text: 'Mathematics'),
            ],
          ),
        ),
        body: TabBarView(
          children: subjects.map((s) => _SubjectList(subject: s)).toList(),
        ),
        bottomNavigationBar: const _NavBar(index: 1),
      ),
    );
  }
}

class _SubjectList extends ConsumerWidget {
  const _SubjectList({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsBySubjectProvider(subject));
    return lessons.when(
      data: (list) => _buildList(context, list),
      loading: () => FutureBuilder(
        future: ref.read(lessonRepositoryProvider).cachedLessons(),
        builder: (ctx, snap) {
          if (snap.hasData) {
            final cached = (snap.data as List)
                .where((l) => l.subject == subject)
                .toList();
            return _buildList(ctx, cached);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildList(BuildContext context, List lessons) {
    if (lessons.isEmpty) return const Center(child: Text('No lessons yet'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: lessons
          .map<Widget>(
            (l) => AnimatedSubjectCard(
              title: l.title,
              onTap: () => context.push('/lesson/${l.id}'),
            ),
          )
          .toList(),
    );
  }
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
