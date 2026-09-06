import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/library_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository _repository;
  final String deviceId;

  LibraryBloc({required LibraryRepository repository, required this.deviceId})
      : _repository = repository,
        super(LibraryInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<CategoryChanged>(_onCategoryChanged);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadSubjects(LoadSubjects event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      final subjects = await _repository.getSubjects(deviceId);
      final total = await _repository.getTotalFlashcards();
      final mastery = await _repository.getMasteryLevel();
      emit(LibraryLoaded(
        subjects: subjects,
        filteredSubjects: subjects,
        totalFlashcards: total,
        masteryLevel: mastery,
      ));
    } catch (e) {
      emit(LibraryError(message: e.toString()));
    }
  }

  void _onCategoryChanged(CategoryChanged event, Emitter<LibraryState> emit) {
    final currentState = state;
    if (currentState is! LibraryLoaded) return;

    final filtered = _filterSubjects(
      currentState.subjects,
      event.category,
      currentState.searchQuery,
    );
    emit(LibraryLoaded(
      subjects: currentState.subjects,
      filteredSubjects: filtered,
      selectedCategory: event.category,
      searchQuery: currentState.searchQuery,
      totalFlashcards: currentState.totalFlashcards,
      masteryLevel: currentState.masteryLevel,
    ));
  }

  void _onSearchQueryChanged(SearchQueryChanged event, Emitter<LibraryState> emit) {
    final currentState = state;
    if (currentState is! LibraryLoaded) return;

    final filtered = _filterSubjects(
      currentState.subjects,
      currentState.selectedCategory,
      event.query,
    );
    emit(LibraryLoaded(
      subjects: currentState.subjects,
      filteredSubjects: filtered,
      selectedCategory: currentState.selectedCategory,
      searchQuery: event.query,
      totalFlashcards: currentState.totalFlashcards,
      masteryLevel: currentState.masteryLevel,
    ));
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<LibraryState> emit) async {
    final currentState = state;
    if (currentState is! LibraryLoaded) return;

    if (event.index < currentState.subjects.length) {
      final subject = currentState.subjects[event.index];
      final newFavorite = !subject.isFavorite;
      await _repository.toggleFavorite(deviceId, subject.id, newFavorite);
    }

    final updated = List<Subject>.from(currentState.subjects);
    if (event.index < updated.length) {
      updated[event.index] = updated[event.index].copyWith(isFavorite: !updated[event.index].isFavorite);
    }

    final filtered = _filterSubjects(updated, currentState.selectedCategory, currentState.searchQuery);
    emit(LibraryLoaded(
      subjects: updated,
      filteredSubjects: filtered,
      selectedCategory: currentState.selectedCategory,
      searchQuery: currentState.searchQuery,
      totalFlashcards: currentState.totalFlashcards,
      masteryLevel: currentState.masteryLevel,
    ));
  }

  List<Subject> _filterSubjects(List<Subject> subjects, String category, String query) {
    return subjects.where((s) {
      final matchesCategory = category == 'Tumu' || s.category == category;
      final matchesQuery = query.isEmpty || s.name.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
