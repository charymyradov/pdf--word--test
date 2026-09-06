import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../models/quiz_score_model.dart';

class QuizRepositoryImpl implements QuizRepository {
  static const String _scoresKey = 'quiz_scores';

  @override
  Future<List<QuizQuestion>> loadQuestions() async => _getDefaultQuestions();

  @override
  Future<List<QuizScore>> getPreviousScores(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_scoresKey) ?? [];
    final scores = jsonList.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return QuizScoreModel.fromMap(map['id'] as String, map).toEntity();
    }).toList();
    scores.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return scores.take(10).toList();
  }

  @override
  Future<void> saveScore(String deviceId, QuizScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final model = QuizScoreModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: score.subject,
      correct: score.correct,
      total: score.total,
      timestamp: DateTime.now(),
    );
    final jsonList = prefs.getStringList(_scoresKey) ?? [];
    jsonList.add(jsonEncode(model.toMap()));
    await prefs.setStringList(_scoresKey, jsonList);
  }

  List<QuizQuestion> _getDefaultQuestions() {
    return const [
      QuizQuestion(
        id: 'default_1',
        questionText: 'Öýjükli dem alyşda mitohondriniň esasy roly nämedir?',
        category: 'Biology',
        subCategory: 'Cell Theory',
        answers: [
          QuizAnswer(label: 'A', text: 'Belgi (protein) sintezi', hexColor: '#1976D2'),
          QuizAnswer(label: 'B', text: 'ATF öndürmek (Mitohondriýa)', hexColor: '#00BCD4'),
          QuizAnswer(label: 'C', text: 'DNK replikasiýasy', hexColor: '#FF9800'),
          QuizAnswer(label: 'D', text: 'Öýjügiň bölünmegi', hexColor: '#7C4DFF'),
        ],
        correctIndex: 1,
        isDoublePoints: true,
      ),
      QuizQuestion(
        id: 'default_2',
        questionText: 'Fotosintezde hlorofiliň wezipesi nämedir?',
        category: 'Biology',
        subCategory: 'Photosynthesis',
        answers: [
          QuizAnswer(label: 'A', text: 'Ýagtylyk energiýasyny siňdirmek', hexColor: '#1976D2'),
          QuizAnswer(label: 'B', text: 'Suw molekulalaryny dargatmak', hexColor: '#00BCD4'),
          QuizAnswer(label: 'C', text: 'CO2-ni siňdirmek', hexColor: '#FF9800'),
          QuizAnswer(label: 'D', text: 'O2 öndürmek', hexColor: '#7C4DFF'),
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        id: 'default_3',
        questionText: 'Nýutonyň hereket kanunlaryna görä, bir jisme täsir edýän netijeli güýç nola deň bolsa näme bolar?',
        category: 'Physics',
        subCategory: 'Mechanics',
        answers: [
          QuizAnswer(label: 'A', text: 'Tizlener', hexColor: '#1976D2'),
          QuizAnswer(label: 'B', text: 'Haýallar', hexColor: '#00BCD4'),
          QuizAnswer(label: 'C', text: 'Hereket ýagdaýyny saklar', hexColor: '#FF9800'),
          QuizAnswer(label: 'D', text: 'Aýlanyp başlar', hexColor: '#7C4DFF'),
        ],
        correctIndex: 2,
      ),
    ];
  }
}
