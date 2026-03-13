import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/lesson.dart';
import '../data/repositories/firestore_lesson_repository.dart';
import 'providers.dart';

final lessonsProvider = StreamProvider<List<Lesson>>((ref) {
  return ref.watch(lessonRepositoryProvider).streamLessons();
});

final lessonsBySubjectProvider = StreamProvider.family<List<Lesson>, Subject>((ref, subject) {
  return ref.watch(lessonRepositoryProvider).streamLessonsForSubject(subject);
});
