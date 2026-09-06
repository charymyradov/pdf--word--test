import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/library_repository.dart';
import '../models/subject_model.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  static const String _subjectsKey = 'library_subjects';
  static const String _favoritesKey = 'library_favorites';

  @override
  Future<List<Subject>> getSubjects(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_subjectsKey);
    if (jsonList == null || jsonList.isEmpty) {
      final defaults = _getDefaultSubjects();
      await _saveSubjects(defaults);
      final favorites = await _getFavorites(deviceId);
      return defaults.map((m) => m.toEntity(isFavorite: favorites.contains(m.id))).toList();
    }

    final favorites = await _getFavorites(deviceId);
    return jsonList.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final model = SubjectModel.fromMap(map['id'] as String, map);
      return model.toEntity(isFavorite: favorites.contains(model.id));
    }).toList();
  }

  @override
  Future<int> getTotalFlashcards() async {
    final subjects = await getSubjects('');
    int total = 0;
    for (final s in subjects) {
      total += s.questionCount;
    }
    return total;
  }

  @override
  Future<double> getMasteryLevel() async => 0.68;

  @override
  Future<void> toggleFavorite(String deviceId, String subjectId, bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await _getFavorites(deviceId);
    if (isFavorite) {
      favorites.add(subjectId);
    } else {
      favorites.remove(subjectId);
    }
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  Future<Set<String>> _getFavorites(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? []).toSet();
  }

  Future<void> _saveSubjects(List<SubjectModel> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = subjects.map((m) => jsonEncode(m.toMap())).toList();
    await prefs.setStringList(_subjectsKey, jsonList);
  }

  List<SubjectModel> _getDefaultSubjects() {
    return const [
      SubjectModel(id: 'math', name: 'Matematik', iconKey: 'calculate', hexColor: '#1976D2', category: 'Sayisal', questionCount: 15),
      SubjectModel(id: 'physics', name: 'Fizik', iconKey: 'science', hexColor: '#00BCD4', category: 'Sayisal', questionCount: 12),
      SubjectModel(id: 'biology', name: 'Biyoloji', iconKey: 'eco', hexColor: '#4CAF50', category: 'Sayisal', questionCount: 10),
      SubjectModel(id: 'chemistry', name: 'Kimya', iconKey: 'biotech', hexColor: '#FF9800', category: 'Sayisal', questionCount: 10),
      SubjectModel(id: 'history', name: 'Tarih', iconKey: 'history_edu', hexColor: '#795548', category: 'Sozel', questionCount: 10),
      SubjectModel(id: 'literature', name: 'Edebiyat', iconKey: 'menu_book', hexColor: '#9C27B0', category: 'Sozel', questionCount: 10),
      SubjectModel(id: 'geography', name: 'Cografya', iconKey: 'public', hexColor: '#607D8B', category: 'Sozel', questionCount: 10),
      SubjectModel(id: 'english', name: 'Ingilizce', iconKey: 'translate', hexColor: '#E91E63', category: 'Dil', questionCount: 10),
    ];
  }
}
