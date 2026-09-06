import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';
import '../../../../core/constants/app_firestore.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl({required this._firestore});

  @override
  Future<UserProfile> getProfile(String deviceId) async {
    final doc = await _firestore
        .collection(AppFirestore.usersCollection)
        .doc(deviceId)
        .collection(AppFirestore.profileSubcollection)
        .doc('info')
        .get();

    if (!doc.exists) {
      final defaultProfile = UserProfileModel.defaultFor(deviceId);
      await _firestore
          .collection(AppFirestore.usersCollection)
          .doc(deviceId)
          .collection(AppFirestore.profileSubcollection)
          .doc('info')
          .set(defaultProfile.toMap());
      return defaultProfile.toEntity();
    }

    return UserProfileModel.fromMap(deviceId, doc.data()!).toEntity();
  }

  @override
  Future<void> toggleDarkMode(String deviceId, bool isDark) async {
    await _firestore
        .collection(AppFirestore.usersCollection)
        .doc(deviceId)
        .collection(AppFirestore.profileSubcollection)
        .doc('info')
        .update({AppFirestore.fieldIsDarkMode: isDark});
  }

  @override
  Future<void> updateStats(String deviceId, {int? totalQuizzes, double? accuracy, int? streakDays}) async {
    final updates = <String, dynamic>{};
    if (totalQuizzes != null) updates[AppFirestore.fieldTotalQuizzes] = totalQuizzes;
    if (accuracy != null) updates[AppFirestore.fieldAccuracy] = accuracy;
    if (streakDays != null) updates[AppFirestore.fieldStreakDays] = streakDays;

    if (updates.isNotEmpty) {
      await _firestore
          .collection(AppFirestore.usersCollection)
          .doc(deviceId)
          .collection(AppFirestore.profileSubcollection)
          .doc('info')
          .update(updates);
    }
  }
}
