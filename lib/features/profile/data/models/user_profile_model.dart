import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String badge;
  final int totalQuizzes;
  final double accuracy;
  final int streakDays;
  final bool isDarkMode;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.badge,
    required this.totalQuizzes,
    required this.accuracy,
    required this.streakDays,
    this.isDarkMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'badge': badge,
      'totalQuizzes': totalQuizzes,
      'accuracy': accuracy,
      'streakDays': streakDays,
      'isDarkMode': isDarkMode,
    };
  }

  factory UserProfileModel.fromMap(String id, Map<String, dynamic> map) {
    return UserProfileModel(
      id: id,
      name: map['name'] as String? ?? 'Guest User',
      email: map['email'] as String? ?? '',
      badge: map['badge'] as String? ?? 'Pro Learner',
      totalQuizzes: map['totalQuizzes'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      streakDays: map['streakDays'] as int? ?? 0,
      isDarkMode: map['isDarkMode'] as bool? ?? false,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      badge: badge,
      totalQuizzes: totalQuizzes,
      accuracy: accuracy,
      streakDays: streakDays,
      isDarkMode: isDarkMode,
    );
  }

  factory UserProfileModel.defaultFor(String id) {
    return UserProfileModel(
      id: id,
      name: 'Guest User',
      email: '',
      badge: 'Pro Learner',
      totalQuizzes: 0,
      accuracy: 0.0,
      streakDays: 0,
    );
  }
}
