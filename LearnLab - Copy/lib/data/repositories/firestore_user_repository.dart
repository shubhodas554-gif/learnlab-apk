import 'package:cloud_firestore/cloud_firestore.dart';

import '../cache/hive_cache.dart';
import '../cache/progress_cache.dart';
import '../models/user_progress.dart';

class UserRepository {
  UserRepository(this._db, this._uid, this._progressCache);
  final FirebaseFirestore _db;
  final String _uid;
  final ProgressCache _progressCache;

  Stream<int> xpStream() =>
      _db.doc('users/$_uid').snapshots().map((d) => (d.data()?['xp'] ?? 0) as int);
  Stream<int> streakStream() =>
      _db.doc('users/$_uid').snapshots().map((d) => (d.data()?['streak'] ?? 0) as int);

  Future<void> addXp(int xp) =>
      _db.doc('users/$_uid').set({'xp': FieldValue.increment(xp)}, SetOptions(merge: true));

  Future<(int previous, int current)> updateStreak(DateTime today) async {
    return _db.runTransaction<(int, int)>((tx) async {
      final doc = await tx.get(_db.doc('users/$_uid'));
      final data = doc.data() ?? {};
      final last = (data['lastActive'] as Timestamp?)?.toDate();
      var streak = (data['streak'] ?? 0) as int;
      final previous = streak;
      if (last == null || today.difference(last).inDays > 1) {
        streak = 1;
      } else if (today.difference(last).inDays == 1) {
        streak += 1;
      }
      tx.set(doc.reference, {
        'streak': streak,
        'lastActive': Timestamp.fromDate(today),
      }, SetOptions(merge: true));
      return (previous, streak);
    });
  }

  Future<(int previous, int current)> completeLesson(
    String lessonId,
    String subject,
    int xpReward,
  ) async {
    final progressRef = _db.collection('progress').doc(_uid).collection('subjects').doc(subject);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(progressRef);
      final data = snap.data() ?? {};
      final completed = List<String>.from(data['completedLessons'] ?? []);
      if (!completed.contains(lessonId)) completed.add(lessonId);
      tx.set(progressRef, {
        'completedLessons': completed,
        'mastery': ((data['mastery'] ?? 0.5) as num).toDouble(),
      }, SetOptions(merge: true));
    });
    await addXp(xpReward);
    final streak = await updateStreak(DateTime.now());
    await _updateLeaderboard(xpReward);
    final progress = await fetchProgress();
    await _progressCache.save(progress);
    return streak;
  }

  Future<void> _updateLeaderboard(int xpGain) async {
    final ref = _db.collection('leaderboard').doc(_uid);
    await ref.set({
      'uid': _uid,
      'xp': FieldValue.increment(xpGain),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<List<String>> recommendWeakSubjects() async {
    final snap = await _db.collection('progress').doc(_uid).collection('subjects').get();
    return snap.docs
        .where((d) => (d.data()['mastery'] ?? 0.5) < 0.6)
        .map((d) => d.id)
        .toList();
  }

  Future<UserProgress> fetchProgress() async {
    try {
      final doc = await _db.doc('users/$_uid').get();
      final progress = UserProgress.fromJson({'uid': _uid, ...?doc.data()});
      await _progressCache.save(progress);
      return progress;
    } catch (_) {
      final cached = await _progressCache.load();
      if (cached != null) return cached;
      rethrow;
    }
  }
}
