import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cache/hive_cache.dart';
import '../data/cache/progress_cache.dart';
import '../data/models/lesson.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/firestore_lesson_repository.dart';
import '../data/repositories/firestore_user_repository.dart';
import '../data/repositories/leaderboard_repository.dart';

final firebaseProvider = Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
final hiveCacheProvider = Provider<LessonCache>((_) => LessonCache());
final progressCacheProvider = Provider<ProgressCache>((_) => ProgressCache());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthRepository(auth);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authState();
});

final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).maybeWhen(data: (u) => u?.uid, orElse: () => null);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(firebaseProvider);
  final uid = ref.watch(currentUidProvider);
  final progressCache = ref.watch(progressCacheProvider);
  if (uid == null) {
    throw StateError('Unauthenticated user');
  }
  return UserRepository(db, uid, progressCache);
});

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final db = ref.watch(firebaseProvider);
  final cache = ref.watch(hiveCacheProvider);
  return LessonRepository(db, cache);
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final db = ref.watch(firebaseProvider);
  return LeaderboardRepository(db);
});

final lessonsProvider = StreamProvider<List<Lesson>>((ref) {
  return ref.watch(lessonRepositoryProvider).streamLessons();
});

final lessonsBySubjectProvider = StreamProvider.family<List<Lesson>, Subject>((ref, subject) {
  return ref.watch(lessonRepositoryProvider).streamLessonsForSubject(subject);
});

final streakProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.streakStream();
});

final xpProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.xpStream();
});

final recommendationsProvider = FutureProvider<List<String>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.recommendWeakSubjects();
});