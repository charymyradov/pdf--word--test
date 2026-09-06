abstract class QuizEvent {}

class StartQuiz extends QuizEvent {}

class AnswerQuestion extends QuizEvent {
  final int answerIndex;
  AnswerQuestion(this.answerIndex);
}

class NextQuestion extends QuizEvent {}

class TimeTicked extends QuizEvent {}
