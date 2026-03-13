import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../widgets/xp_burst.dart';
import '../../widgets/streak_flare.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int idx = 0;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    final lessonFuture = ref.watch(_lessonProvider(widget.lessonId));
    return lessonFuture.when(
      data: (lesson) {
        if (lesson == null) {
          return const Scaffold(body: Center(child: Text('Lesson not found')));
        }
        final quiz = lesson.quiz;
        final done = idx >= quiz.length;
        return Scaffold(
          appBar: AppBar(title: const Text('Quiz')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: done
                ? _Result(
                    score: score,
                    total: quiz.length,
                    xp: lesson.xpReward,
                    onDone: () async {
                      final userRepo = ref.read(userRepositoryProvider);
                      final (prev, current) = await userRepo.completeLesson(
                        lesson.id,
                        lesson.subject.name,
                        lesson.xpReward,
                      );
                      await ref.read(lessonRepositoryProvider).markCompleted(lesson.id);
                      if (!mounted) return;
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(content: XpBurst(xp: lesson.xpReward)),
                      );
                      if (current > prev) {
                        await showDialog(
                          context: context,
                          builder: (_) => const AlertDialog(content: StreakFlare()),
                        );
                      }
                      if (mounted) Navigator.of(context).pop();
                    },
                  )
                : _QuestionCard(
                    question: quiz[idx].question,
                    options: quiz[idx].options,
                    onAnswer: (correct) {
                      setState(() {
                        if (correct) score++;
                        idx++;
                      });
                    },
                    answerIndex: quiz[idx].answerIndex,
                  ),
          ),
          bottomNavigationBar: const _NavBar(index: 1),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

final _lessonProvider = FutureProvider.family((ref, String id) {
  return ref.watch(lessonRepositoryProvider).getLesson(id);
});
