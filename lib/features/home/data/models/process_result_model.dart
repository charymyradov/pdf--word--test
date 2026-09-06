import 'package:cloud_firestore/cloud_firestore.dart';
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
      'timestamp': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  factory ProcessResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProcessResultModel(
      id: doc.id,
      extractedText: data['extractedText'] as String? ?? '',
      resultType: data['resultType'] as String? ?? 'text',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
