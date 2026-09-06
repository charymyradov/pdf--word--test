import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String deviceId);
  Future<void> toggleDarkMode(String deviceId, bool isDark);
  Future<void> updateStats(String deviceId, {int? totalQuizzes, double? accuracy, int? streakDays});
}
