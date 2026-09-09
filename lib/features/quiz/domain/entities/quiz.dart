class QuizQuestion {
  final String id;
  final String questionText;
  final String category;
  final String subCategory;
  final List<QuizAnswer> answers;
  final int correctIndex;
  final bool isDoublePoints;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.category,
    required this.subCategory,
    required this.answers,
    required this.correctIndex,
    this.isDoublePoints = false,
  });
}

class QuizAnswer {
  final String label;
  final String text;
  final String hexColor;

  const QuizAnswer({
    required this.label,
    required this.text,
    required this.hexColor,
  });
}

class QuizSession {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final int streak;
  final int correctCount;
  final int timeRemaining;
  final int? selectedAnswer;
  final bool answered;

  const QuizSession({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.streak = 0,
    this.correctCount = 0,
    this.timeRemaining = 45,
    this.selectedAnswer,
    this.answered = false,
  });

  QuizQuestion get currentQuestion => questions[currentQuestionIndex];
  int get totalQuestions => questions.length;
  bool get isCompleted => currentQuestionIndex >= questions.length;

  QuizSession copyWith({
    int? currentQuestionIndex,
    int? score,
    int? streak,
    int? correctCount,
    int? timeRemaining,
    int? Function()? selectedAnswer,
    bool? answered,
  }) {
    return QuizSession(
      questions: questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      correctCount: correctCount ?? this.correctCount,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      selectedAnswer: selectedAnswer != null ? selectedAnswer() : this.selectedAnswer,
      answered: answered ?? this.answered,
    );
  }
}

class QuizScore {
  final String id;
  final String subject;
  final int correct;
  final int total;
  final DateTime timestamp;

  const QuizScore({
    required this.id,
    required this.subject,
    required this.correct,
    required this.total,
    required this.timestamp,
  });

  String get scoreText => '$correct/$total';
}
