import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../widgets/empty_state.dart';

class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonFuture = ref.watch(_lessonProvider(lessonId));
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: lessonFuture.when(
        data: (lesson) => lesson == null
            ? const EmptyState(message: 'Lesson not found')
            : PageView(
                children: [
                  _ConceptCard(lesson.concept, lesson.diagramUrl),
                  _ExampleCard(lesson.example),
                  _QuizIntro(onStart: () => context.push('/quiz/${lesson.id}')),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: const _NavBar(index: 1),
    );
  }
}

final _lessonProvider = FutureProvider.family((ref, String id) {
  return ref.watch(lessonRepositoryProvider).getLesson(id);
});

class _ConceptCard extends StatelessWidget {
  const _ConceptCard(this.concept, this.diagram);
  final String concept;
  final String? diagram;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Concept', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(concept),
              if (diagram != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(diagram!, fit: BoxFit.cover),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard(this.example);
  final String example;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Example', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(example),
              ],
            ),
          ),
        ),
      );
}

class _QuizIntro extends StatelessWidget {
  const _QuizIntro({required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Ready for a quick quiz?'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: onStart, child: const Text('Start Quiz')),
              ],
            ),
          ),
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
