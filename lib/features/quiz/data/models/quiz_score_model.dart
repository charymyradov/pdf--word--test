import '../../domain/entities/quiz.dart';

class QuizScoreModel {
  final String id;
  final String subject;
  final int correct;
  final int total;
  final DateTime timestamp;

  const QuizScoreModel({
    required this.id,
    required this.subject,
    required this.correct,
    required this.total,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'correct': correct,
      'total': total,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QuizScoreModel.fromMap(String id, Map<String, dynamic> map) {
    return QuizScoreModel(
      id: id,
      subject: map['subject'] as String? ?? '',
      correct: map['correct'] as int? ?? 0,
      total: map['total'] as int? ?? 0,
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  QuizScore toEntity() {
    return QuizScore(
      id: id,
      subject: subject,
      correct: correct,
      total: total,
      timestamp: timestamp,
    );
  }
}
