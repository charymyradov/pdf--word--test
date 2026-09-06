import '../../domain/entities/quiz.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizPlaying extends QuizState {
  final QuizSession session;
  final List<QuizScore> previousScores;

  QuizPlaying({required this.session, required this.previousScores});
}

class QuizCompleted extends QuizState {
  final int finalScore;
  final int totalQuestions;

  QuizCompleted({required this.finalScore, required this.totalQuestions});
}

class QuizError extends QuizState {
  final String message;
  QuizError({required this.message});
}
