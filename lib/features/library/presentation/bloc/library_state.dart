import '../../domain/entities/subject.dart';

abstract class LibraryState {}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Subject> subjects;
  final List<Subject> filteredSubjects;
  final String selectedCategory;
  final String searchQuery;
  final int totalFlashcards;
  final double masteryLevel;

  LibraryLoaded({
    required this.subjects,
    required this.filteredSubjects,
    this.selectedCategory = 'Tümü',
    this.searchQuery = '',
    this.totalFlashcards = 0,
    this.masteryLevel = 0.0,
  });
}

class LibraryError extends LibraryState {
  final String message;
  LibraryError({required this.message});
}
