abstract class LibraryEvent {}

class LoadSubjects extends LibraryEvent {}

class CategoryChanged extends LibraryEvent {
  final String category;
  CategoryChanged(this.category);
}

class SearchQueryChanged extends LibraryEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class ToggleFavorite extends LibraryEvent {
  final int index;
  ToggleFavorite(this.index);
}

class GenerateDeckWithAI extends LibraryEvent {}
