import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository _repository;
  final String deviceId;
  Timer? _timer;

  QuizBloc({required this._repository, required this.deviceId})
      : super(QuizInitial()) {
    on<StartQuiz>(_onStartQuiz);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<TimeTicked>(_onTimeTicked);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onStartQuiz(StartQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final questions = await _repository.loadQuestions();
      final previousScores = await _repository.getPreviousScores(deviceId);
      final session = QuizSession(questions: questions);
      emit(QuizPlaying(session: session, previousScores: previousScores));
      _startTimer();
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  void _onAnswerQuestion(AnswerQuestion event, Emitter<QuizState> emit) {
    final currentState = state;
    if (currentState is! QuizPlaying || currentState.session.answered) return;

    final session = currentState.session;
    final isCorrect = event.answerIndex == session.currentQuestion.correctIndex;
    final newScore = isCorrect
        ? session.score + (session.currentQuestion.isDoublePoints ? 400 : 200)
        : session.score;
    final newStreak = isCorrect ? session.streak + 1 : 0;

    emit(QuizPlaying(
      session: session.copyWith(
        selectedAnswer: () => event.answerIndex,
        answered: true,
        score: newScore,
        streak: newStreak,
      ),
      previousScores: currentState.previousScores,
    ));
  }

  Future<void> _onNextQuestion(NextQuestion event, Emitter<QuizState> emit) async {
    final currentState = state;
    if (currentState is! QuizPlaying) return;

    final session = currentState.session;
    if (session.currentQuestionIndex + 1 >= session.totalQuestions) {
      _timer?.cancel();

      await _repository.saveScore(
        deviceId,
        QuizScore(
          id: '',
          subject: session.currentQuestion.category,
          correct: session.score ~/ 200,
          total: session.totalQuestions,
          timestamp: DateTime.now(),
        ),
      );

      emit(QuizCompleted(finalScore: session.score, totalQuestions: session.totalQuestions));
      return;
    }

    emit(QuizPlaying(
      session: session.copyWith(
        currentQuestionIndex: session.currentQuestionIndex + 1,
        selectedAnswer: () => null,
        answered: false,
        timeRemaining: 45,
      ),
      previousScores: currentState.previousScores,
    ));
    _startTimer();
  }

  void _onTimeTicked(TimeTicked event, Emitter<QuizState> emit) {
    final currentState = state;
    if (currentState is! QuizPlaying) return;

    final session = currentState.session;
    if (session.timeRemaining <= 0) {
      _timer?.cancel();
      return;
    }

    emit(QuizPlaying(
      session: session.copyWith(timeRemaining: session.timeRemaining - 1),
      previousScores: currentState.previousScores,
    ));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimeTicked());
    });
  }
}
