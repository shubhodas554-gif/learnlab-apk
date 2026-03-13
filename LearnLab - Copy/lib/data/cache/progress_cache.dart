import 'package:hive/hive.dart';

import '../models/user_progress.dart';

class ProgressCache {
  Future<Box> _box() async => Hive.openBox('progress_cache');

  Future<void> save(UserProgress progress) async {
    final box = await _box();
    box.put('progress', progress.toJson());
  }

  Future<UserProgress?> load() async {
    final box = await _box();
    final data = box.get('progress');
    if (data == null) return null;
    return UserProgress.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
