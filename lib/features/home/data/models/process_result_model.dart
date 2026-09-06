import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/process_result.dart';

class ProcessResultModel {
  final String id;
  final String extractedText;
  final String resultType;
  final DateTime timestamp;
  final DateTime expiresAt;

  const ProcessResultModel({
    required this.id,
    required this.extractedText,
    required this.resultType,
    required this.timestamp,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'extractedText': extractedText,
      'resultType': resultType,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory ProcessResultModel.fromMap(String id, Map<String, dynamic> map) {
    return ProcessResultModel(
      id: id,
      extractedText: map['extractedText'] as String? ?? '',
      resultType: map['resultType'] as String? ?? 'text',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(map['expiresAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  ProcessResult toEntity() {
    return ProcessResult(
      success: true,
      message: 'Islem basariyla tamamlandi',
      extractedText: extractedText,
      resultType: _parseResultType(resultType),
      timestamp: timestamp,
      expiresAt: expiresAt,
    );
  }

  ProcessResultType _parseResultType(String type) {
    switch (type) {
      case 'quiz':
        return ProcessResultType.quiz;
      case 'text':
        return ProcessResultType.text;
      case 'word':
        return ProcessResultType.word;
      case 'excel':
        return ProcessResultType.excel;
      default:
        return ProcessResultType.text;
    }
  }
}
