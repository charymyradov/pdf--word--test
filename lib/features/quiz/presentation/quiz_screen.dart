import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/device_id_service.dart';
import 'bloc/quiz_bloc.dart';
import 'bloc/quiz_event.dart';
import 'bloc/quiz_state.dart';
import '../domain/entities/quiz.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: context.read<DeviceIdService>().getDeviceId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return BlocProvider(
          create: (context) => QuizBloc(
            repository: context.read(),
            deviceId: snapshot.data!,
          )..add(StartQuiz()),
          child: const QuizView(),
        );
      },
    );
  }
}

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (state is QuizCompleted) {
              return _buildCompletedView(context, state);
            }
            if (state is QuizPlaying) {
              return _buildPlayingView(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCompletedView(BuildContext context, QuizCompleted state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: AppColors.orange, size: 80),
          const SizedBox(height: 24),
          const Text('Quiz Tamamlandı!',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            '${state.finalScore} Puan',
            style: const TextStyle(color: AppColors.turquoise, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.totalQuestions} soruda',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.read<QuizBloc>().add(StartQuiz()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.turquoise,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Yeniden Başla',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingView(BuildContext context, QuizPlaying state) {
    final session = state.session;
    return Column(
      children: [
        _buildTopBar(context, session),
        _buildProgressSection(session),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildQuestionCard(session),
                const SizedBox(height: 20),
                _buildAnswerChoices(context, session),
                const SizedBox(height: 24),
                _buildNextButton(context, session),
                const SizedBox(height: 20),
                _buildPreviousScores(state.previousScores),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, QuizSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  _formatTimer(session.timeRemaining),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.turquoise.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.turquoise, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${session.score} PTS',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      'X${session.streak}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(QuizSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
              ),
              Text(
                '${(((session.currentQuestionIndex + 1) / session.totalQuestions) * 100).toInt()}%',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (session.currentQuestionIndex + 1) / session.totalQuestions,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.turquoise),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizSession session) {
    final question = session.currentQuestion;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${question.category} • ${question.subCategory}',
                  style: const TextStyle(
                      color: AppColors.teal, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              if (question.isDoublePoints) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🎯 İkili Puan',
                    style: TextStyle(
                        color: AppColors.orange, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerChoices(BuildContext context, QuizSession session) {
    final question = session.currentQuestion;
    return Column(
      children: List.generate(question.answers.length, (index) {
        final answer = question.answers[index];
        final answerColor = _hexToColor(answer.hexColor);
        final isSelected = session.selectedAnswer == index;
        final isCorrect = index == question.correctIndex;
        final showResult = session.answered;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: session.answered
                ? null
                : () => context.read<QuizBloc>().add(AnswerQuestion(index)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: showResult
                    ? (isCorrect
                        ? AppColors.success.withValues(alpha: 0.15)
                        : isSelected
                            ? AppColors.error.withValues(alpha: 0.15)
                            : answerColor.withValues(alpha: 0.08))
                    : (isSelected ? AppColors.turquoise.withValues(alpha: 0.15) : answerColor.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: showResult
                      ? (isCorrect
                          ? AppColors.success
                          : isSelected
                              ? AppColors.error
                              : Colors.transparent)
                      : (isSelected ? AppColors.turquoise : Colors.transparent),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: showResult
                          ? (isCorrect
                              ? AppColors.success
                              : isSelected
                                  ? AppColors.error
                                  : AppColors.primaryBlue.withValues(alpha: 0.1))
                          : (isSelected ? AppColors.turquoise : AppColors.primaryBlue.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: showResult && isCorrect
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : showResult && isSelected
                              ? const Icon(Icons.close, color: Colors.white, size: 20)
                              : Text(
                                  answer.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppColors.primaryBlue,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      answer.text,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                  if (showResult && isCorrect)
                    const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton(BuildContext context, QuizSession session) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: session.answered
            ? () => context.read<QuizBloc>().add(NextQuestion())
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turquoise,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: Text(
          session.currentQuestionIndex + 1 < session.totalQuestions
              ? 'Next Question →'
              : 'Quiz\'i Tamamla',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPreviousScores(List<QuizScore> scores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Önceki Quiz Skorları',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: scores.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final score = scores[index];
              final scoreColor = _getScoreColor(index);
              return Container(
                width: 120,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(score.subject,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                    Text(score.scoreText,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Color _getScoreColor(int index) {
    const colors = [
      AppColors.turquoise,
      AppColors.primaryBlue,
      AppColors.orange,
      AppColors.teal,
      AppColors.primaryNavy,
    ];
    return colors[index % colors.length];
  }
}
