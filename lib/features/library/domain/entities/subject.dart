class Subject {
  final String id;
  final String name;
  final String iconKey;
  final String hexColor;
  final String category;
  final int questionCount;
  final bool isFavorite;

  const Subject({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.hexColor,
    required this.category,
    required this.questionCount,
    this.isFavorite = false,
  });

  Subject copyWith({bool? isFavorite}) {
    return Subject(
      id: id,
      name: name,
      iconKey: iconKey,
      hexColor: hexColor,
      category: category,
      questionCount: questionCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
