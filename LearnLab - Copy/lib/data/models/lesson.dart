import 'package:freezed_annotation/freezed_annotation.dart';

import 'quiz_question.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

enum Subject { physics, chemistry, biology, mathematics }

enum Difficulty { beginner, intermediate, advanced }

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required Subject subject,
    required String title,
    @Default(Difficulty.beginner) Difficulty difficulty,
    required String concept,
    required String example,
    required String practice,
    required List<QuizQuestion> quiz,
    @Default(15) int xpReward,
    String? diagramUrl,
    @Default(false) bool generated,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}
