import '../entities/subject.dart';

abstract class LibraryRepository {
  Future<List<Subject>> getSubjects(String deviceId);
  Future<int> getTotalFlashcards();
  Future<double> getMasteryLevel();
  Future<void> toggleFavorite(String deviceId, String subjectId, bool isFavorite);
}
