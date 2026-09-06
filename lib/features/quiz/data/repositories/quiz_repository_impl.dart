import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_score_model.dart';
import '../../../../core/constants/app_firestore.dart';

class QuizRepositoryImpl implements QuizRepository {
  final FirebaseFirestore _firestore;

  QuizRepositoryImpl({required this._firestore});

  @override
  Future<List<QuizQuestion>> loadQuestions() async {
    final snapshot = await _firestore.collection(AppFirestore.questionsCollection).get();

    if (snapshot.docs.isEmpty) {
      return _getDefaultQuestions();
    }

    return snapshot.docs.map((doc) {
      final model = QuizQuestionModel.fromMap(doc.id, doc.data());
      return model.toEntity();
    }).toList();
  }

  @override
  Future<List<QuizScore>> getPreviousScores(String deviceId) async {
    final snapshot = await _firestore
        .collection(AppFirestore.usersCollection)
        .doc(deviceId)
        .collection(AppFirestore.quizScoresSubcollection)
        .orderBy(AppFirestore.fieldTimestamp, descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => QuizScoreModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> saveScore(String deviceId, QuizScore score) async {
    final model = QuizScoreModel(
      id: '',
      subject: score.subject,
      correct: score.correct,
      total: score.total,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection(AppFirestore.usersCollection)
        .doc(deviceId)
        .collection(AppFirestore.quizScoresSubcollection)
        .add(model.toMap());
  }

  List<QuizQuestion> _getDefaultQuestions() {
    return const [
      QuizQuestion(
        id: 'default_1',
        questionText: 'Hucresel solunumda mitokondrinin temel rolu nedir?',
        category: 'Biology',
        subCategory: 'Cell Theory',
        answers: [
          QuizAnswer(label: 'A', text: 'Protein sentezi', hexColor: '#1976D2'),
          QuizAnswer(label: 'B', text: 'ATP uretimi (Mitokondria)', hexColor: '#00BCD4'),
          QuizAnswer(label: 'C', text: 'DNA replikasyonu', hexColor: '#FF9800'),
          QuizAnswer(label: 'D', text: 'Hucre bolunmesi', hexColor: '#7C4DFF'),
        ],
        correctIndex: 1,
        isDoublePoints: true,
      ),
      QuizQuestion(
        id: 'default_2',
        questionText: 'Fotosentezde klorofilin gorevi nedir?',
        category: 'Biology',
        subCategory: 'Photosynthesis',
        answers: [
          QuizAnswer(label: 'A', text: 'Isik enerjisini emmek', hexColor: '#1976D2'),
          QuizAnswer(label: 'B', text: 'Su molekullerini parcalamak', hexColor: '#00BCD4'),
          QuizAnswer(label: 'C', text: 'CO2 absorbe etmek', hexColor: '#FF9800'),
          QuizAnswer(label: 'D', text: 'O2 uretmek', hexColor: '#7C4DFF'),
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'default_3',
        questionText: 'Newton\'in hareket yasalarina gore, bir cisme etki eden net kuvvet sifirsa ne olur?',
        category: 'Physics',
        subCategory: 'Mechanics',
        answers: [
          QuizAnswer(label: 'A', text: 'Hizlanir', hexColor: '#1976D2'),
          QuizAnswer(label: 'B', text: 'Yavaslar', hexColor: '#00BCD4'),
          QuizAnswer(label: 'C', text: 'Hareket durumunu korur', hexColor: '#FF9800'),
          QuizAnswer(label: 'D', text: 'Donmeye baslar', hexColor: '#7C4DFF'),
        ],
        correctIndex: 2,
      ),
    ];
  }
}
