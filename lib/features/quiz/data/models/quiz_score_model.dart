import 'package:cloud_firestore/cloud_firestore.dart';
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
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory QuizScoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizScoreModel(
      id: doc.id,
      subject: data['subject'] as String? ?? '',
      correct: data['correct'] as int? ?? 0,
      total: data['total'] as int? ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
