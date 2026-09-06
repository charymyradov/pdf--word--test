import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/library_repository.dart';
import '../models/subject_model.dart';
import '../../../../core/constants/app_firestore.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final FirebaseFirestore _firestore;

  LibraryRepositoryImpl({required this._firestore});

  @override
  Future<List<Subject>> getSubjects(String deviceId) async {
    final snapshot = await _firestore.collection(AppFirestore.subjectsCollection).get();
    final favorites = await _getFavorites(deviceId);

    return snapshot.docs.map((doc) {
      final model = SubjectModel.fromMap(doc.id, doc.data());
      final isFavorite = favorites.contains(doc.id);
      return toEntity(model, isFavorite);
    }).toList();
  }

  @override
  Future<int> getTotalFlashcards() async {
    final snapshot = await _firestore.collection(AppFirestore.subjectsCollection).get();
    int total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['questionCount'] as int?) ?? 0;
    }
    return total;
  }

  @override
  Future<double> getMasteryLevel() async {
    return 0.68;
  }

  @override
  Future<void> toggleFavorite(String deviceId, String subjectId, bool isFavorite) async {
    final docRef = _firestore
        .collection(AppFirestore.usersCollection)
        .doc(deviceId)
        .collection(AppFirestore.favoritesSubcollection)
        .doc(subjectId);

    if (isFavorite) {
      await docRef.set({AppFirestore.fieldIsFavorite: true});
    } else {
      await docRef.delete();
    }
  }

  Future<Set<String>> _getFavorites(String deviceId) async {
    final snapshot = await _firestore
        .collection(AppFirestore.usersCollection)
        .doc(deviceId)
        .collection(AppFirestore.favoritesSubcollection)
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Subject toEntity(SubjectModel model, bool isFavorite) {
    return model.toEntity(isFavorite: isFavorite);
  }
}
