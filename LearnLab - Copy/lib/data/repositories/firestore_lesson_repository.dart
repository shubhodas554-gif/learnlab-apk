import 'package:cloud_firestore/cloud_firestore.dart';

import '../cache/hive_cache.dart';
import '../models/lesson.dart';

class LessonRepository {
  LessonRepository(this._db, this._cache);
  final FirebaseFirestore _db;
  final LessonCache _cache;

  Stream<List<Lesson>> streamLessons() {
    return _db.collection('lessons').snapshots().map((snap) {
      final lessons = snap.docs.map(_fromDoc).toList();
      _cache.saveLessons(lessons);
      return lessons;
    });
  }

  Stream<List<Lesson>> streamLessonsForSubject(Subject subject) {
    return _db
        .collection('lessons')
        .where('subject', isEqualTo: subject.name)
        .snapshots()
        .map((snap) {
      final lessons = snap.docs.map(_fromDoc).toList();
      _cache.saveLessons(lessons);
      return lessons;
    });
  }

  Future<List<Lesson>> cachedLessons() => _cache.getAll();

  Future<Lesson?> getLesson(String id) async {
    final cached = await _cache.getLesson(id);
    if (cached != null) return cached;
    final doc = await _db.doc('lessons/$id').get();
    if (!doc.exists) return null;
    final lesson = _fromDoc(doc);
    _cache.saveLessons([lesson]);
    return lesson;
  }

  Future<void> markCompleted(String lessonId) async {
    await _db.doc('lessons/$lessonId').update({'completed': FieldValue.increment(1)});
  }

  Lesson _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    return Lesson.fromJson({
      'id': d.id,
      ...data,
      'subject': data['subject'],
      'difficulty': data['difficulty'] ?? 'beginner',
    });
  }
}
