import '../../domain/entities/subject.dart';

class SubjectModel {
  final String id;
  final String name;
  final String iconKey;
  final String hexColor;
  final String category;
  final int questionCount;
  final bool isFavorite;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.hexColor,
    required this.category,
    required this.questionCount,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': iconKey,
      'color': hexColor,
      'category': category,
      'questionCount': questionCount,
    };
  }

  factory SubjectModel.fromMap(String id, Map<String, dynamic> map) {
    return SubjectModel(
      id: id,
      name: map['name'] as String? ?? '',
      iconKey: map['icon'] as String? ?? 'help_outline',
      hexColor: map['color'] as String? ?? '#9E9E9E',
      category: map['category'] as String? ?? 'General',
      questionCount: map['questionCount'] as int? ?? 0,
    );
  }

  Subject toEntity({bool isFavorite = false}) {
    return Subject(
      id: id,
      name: name,
      iconKey: iconKey,
      hexColor: hexColor,
      category: category,
      questionCount: questionCount,
      isFavorite: isFavorite,
    );
  }
}
