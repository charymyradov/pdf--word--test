import '../../domain/entities/quiz.dart';

class QuizQuestionModel {
  final String id;
  final String questionText;
  final String category;
  final String subCategory;
  final List<Map<String, dynamic>> answers;
  final int correctIndex;
  final bool isDoublePoints;

  const QuizQuestionModel({
    required this.id,
    required this.questionText,
    required this.category,
    required this.subCategory,
    required this.answers,
    required this.correctIndex,
    this.isDoublePoints = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'category': category,
      'subCategory': subCategory,
      'answers': answers,
      'correctIndex': correctIndex,
      'isDoublePoints': isDoublePoints,
    };
  }

  factory QuizQuestionModel.fromMap(String id, Map<String, dynamic> map) {
    final answersList = (map['answers'] as List<dynamic>?)
            ?.map((a) => Map<String, dynamic>.from(a as Map))
            .toList() ??
        [];

    return QuizQuestionModel(
      id: id,
      questionText: map['questionText'] as String? ?? '',
      category: map['category'] as String? ?? '',
      subCategory: map['subCategory'] as String? ?? '',
      answers: answersList,
      correctIndex: map['correctIndex'] as int? ?? 0,
      isDoublePoints: map['isDoublePoints'] as bool? ?? false,
    );
  }

  QuizQuestion toEntity() {
    return QuizQuestion(
      id: id,
      questionText: questionText,
      category: category,
      subCategory: subCategory,
      answers: answers
          .map((a) => QuizAnswer(
                label: a['label'] as String? ?? '',
                text: a['text'] as String? ?? '',
                hexColor: a['hexColor'] as String? ?? '#9E9E9E',
              ))
          .toList(),
      correctIndex: correctIndex,
      isDoublePoints: isDoublePoints,
    );
  }
}
