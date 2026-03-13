import 'package:hive/hive.dart';

import '../models/lesson.dart';

class LessonCache {
  Future<Box> _box() async => Hive.openBox('lesson_cache');

  Future<void> saveLessons(List<Lesson> lessons) async {
    final box = await _box();
    for (final l in lessons) {
      box.put(l.id, l.toJson());
    }
  }

  Future<Lesson?> getLesson(String id) async {
    final box = await _box();
    final data = box.get(id);
    if (data == null) return null;
    return Lesson.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<Lesson>> getAll() async {
    final box = await _box();
    return box.values
        .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
