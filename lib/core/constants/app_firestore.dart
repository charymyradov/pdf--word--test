class AppFirestore {
  AppFirestore._();

  static const String usersCollection = 'users';
  static const String subjectsCollection = 'subjects';
  static const String questionsCollection = 'questions';
  static const String profileSubcollection = 'profile';
  static const String quizScoresSubcollection = 'quizScores';
  static const String extractionsSubcollection = 'extractions';
  static const String favoritesSubcollection = 'favorites';

  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldBadge = 'badge';
  static const String fieldTotalQuizzes = 'totalQuizzes';
  static const String fieldAccuracy = 'accuracy';
  static const String fieldStreakDays = 'streakDays';
  static const String fieldIsDarkMode = 'isDarkMode';

  static const String fieldIcon = 'icon';
  static const String fieldColor = 'color';
  static const String fieldCategory = 'category';
  static const String fieldQuestionCount = 'questionCount';

  static const String fieldQuestionText = 'questionText';
  static const String fieldSubCategory = 'subCategory';
  static const String fieldAnswers = 'answers';
  static const String fieldCorrectIndex = 'correctIndex';
  static const String fieldIsDoublePoints = 'isDoublePoints';

  static const String fieldSubject = 'subject';
  static const String fieldCorrect = 'correct';
  static const String fieldTotal = 'total';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldExpiresAt = 'expiresAt';

  static const String fieldExtractedText = 'extractedText';
  static const String fieldResultType = 'resultType';

  static const String fieldIsFavorite = 'isFavorite';
}
