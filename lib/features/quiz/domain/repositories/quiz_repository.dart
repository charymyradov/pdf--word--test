import '../entities/quiz.dart';

abstract class QuizRepository {
  Future<List<QuizQuestion>> loadQuestions();
  Future<List<QuizScore>> getPreviousScores(String deviceId);
  Future<void> saveScore(String deviceId, QuizScore score);
}
