import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String uid,
    @Default(0) int xp,
    @Default(0) int streak,
    @Default([]) List<String> completedLessons,
    @Default({}) Map<String, double> masteryBySubject,
    DateTime? lastActive,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);
}
