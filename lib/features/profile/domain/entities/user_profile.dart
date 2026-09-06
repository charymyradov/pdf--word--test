class UserProfile {
  final String id;
  final String name;
  final String email;
  final String badge;
  final int totalQuizzes;
  final double accuracy;
  final int streakDays;
  final bool isDarkMode;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.badge,
    required this.totalQuizzes,
    required this.accuracy,
    required this.streakDays,
    this.isDarkMode = false,
  });

  UserProfile copyWith({bool? isDarkMode, int? totalQuizzes, double? accuracy, int? streakDays}) {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      badge: badge,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      accuracy: accuracy ?? this.accuracy,
      streakDays: streakDays ?? this.streakDays,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
