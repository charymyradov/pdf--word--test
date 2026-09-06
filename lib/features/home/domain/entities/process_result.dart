import '../../../../core/enums/app_enums.dart';

class ProcessResult {
  final bool success;
  final String message;
  final String extractedText;
  final ProcessResultType resultType;
  final List<String> quizQuestions;
  final String? fileName;
  final String? fileSize;
  final DateTime? timestamp;
  final DateTime? expiresAt;

  const ProcessResult({
    required this.success,
    required this.message,
    this.extractedText = '',
    this.resultType = ProcessResultType.text,
    this.quizQuestions = const [],
    this.fileName,
    this.fileSize,
    this.timestamp,
    this.expiresAt,
  });

  factory ProcessResult.empty() => const ProcessResult(
        success: false,
        message: '',
      );
}
