import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  static const String _profileKey = 'user_profile';

  @override
  Future<UserProfile> getProfile(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_profileKey);
    if (json == null) return _defaultProfile(deviceId);
    final map = jsonDecode(json) as Map<String, dynamic>;
    return UserProfile(
      id: deviceId,
      name: map['name'] as String? ?? 'Guest User',
      email: map['email'] as String? ?? '',
      badge: map['badge'] as String? ?? 'Pro Learner',
      totalQuizzes: map['totalQuizzes'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      streakDays: map['streakDays'] as int? ?? 0,
      isDarkMode: map['isDarkMode'] as bool? ?? false,
    );
  }

  @override
  Future<void> toggleDarkMode(String deviceId, bool isDark) async {
    final profile = await getProfile(deviceId);
    final updated = profile.copyWith(isDarkMode: isDark);
    await _save(updated);
  }

  @override
  Future<void> updateStats(String deviceId, {int? totalQuizzes, double? accuracy, int? streakDays}) async {
    final profile = await getProfile(deviceId);
    final updated = profile.copyWith(
      totalQuizzes: totalQuizzes,
      accuracy: accuracy,
      streakDays: streakDays,
    );
    await _save(updated);
  }

  Future<void> _save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode({
      'name': profile.name,
      'email': profile.email,
      'badge': profile.badge,
      'totalQuizzes': profile.totalQuizzes,
      'accuracy': profile.accuracy,
      'streakDays': profile.streakDays,
      'isDarkMode': profile.isDarkMode,
    }));
  }

  UserProfile _defaultProfile(String deviceId) {
    return UserProfile(
      id: deviceId,
      name: 'Guest User',
      email: '',
      badge: 'Pro Learner',
      totalQuizzes: 0,
      accuracy: 0.0,
      streakDays: 0,
    );
  }
}
