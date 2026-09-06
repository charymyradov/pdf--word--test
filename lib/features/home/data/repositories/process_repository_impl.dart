import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/process_result.dart';
import '../../domain/repositories/process_repository.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/image_cache_service.dart';

// ignore_for_file: prefer_initializing_formals

class ProcessRepositoryImpl implements ProcessRepository {
  final GeminiService _geminiService;
  final ImageCacheService _imageCacheService;

  ProcessRepositoryImpl({
    required GeminiService geminiService,
    required ImageCacheService imageCacheService,
  })  : _geminiService = geminiService,
        _imageCacheService = imageCacheService;

  static const String _extractionsKey = 'extractions';

  @override
  Future<ProcessResult> processImage({
    required String imagePath,
    required ImageProcessType processType,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return const ProcessResult(
        success: false,
        message: 'Gorsel dosyasi bulunamadi.',
      );
    }

    await _imageCacheService.saveImage(imagePath);

    final extractedText = await _geminiService.extractText(file);

    if (extractedText.trim().isEmpty) {
      return const ProcessResult(
        success: false,
        message: 'Gorselde okunabilir metin bulunamadi.',
      );
    }

    switch (processType) {
      case ImageProcessType.quizCreate:
        final quizData = await _geminiService.generateQuiz(extractedText);
        final questions = quizData.map((q) {
          final options = (q['options'] as List<dynamic>).cast<String>();
          final correctIndex = q['correctIndex'] as int;
          return 'Q: ${q['question']}\nA: ${options[0]}\nB: ${options[1]}\nC: ${options[2]}\nD: ${options[3]}\nDogru: ${['A','B','C','D'][correctIndex]}';
        }).toList();
        return ProcessResult(
          success: true,
          message: '${questions.length} soru olusturuldu!',
          extractedText: extractedText,
          resultType: ProcessResultType.quiz,
          quizQuestions: questions,
          timestamp: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );

      case ImageProcessType.extractText:
        return ProcessResult(
          success: true,
          message: 'Metin basariyla cikarildi!',
          extractedText: extractedText,
          resultType: ProcessResultType.text,
          timestamp: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );

      case ImageProcessType.exportWord:
        return ProcessResult(
          success: true,
          message: 'Metin cikarildi!',
          extractedText: extractedText,
          resultType: ProcessResultType.word,
          fileName: 'quizai_export.txt',
          fileSize: '${(extractedText.length / 1024).toStringAsFixed(1)} KB',
          timestamp: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );

      case ImageProcessType.exportExcel:
        return ProcessResult(
          success: true,
          message: 'Metin cikarildi!',
          extractedText: extractedText,
          resultType: ProcessResultType.excel,
          fileName: 'quizai_export.csv',
          fileSize: '${(extractedText.length / 1024).toStringAsFixed(1)} KB',
          timestamp: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        );
    }
  }

  @override
  Future<void> saveExtraction({
    required String deviceId,
    required String extractedText,
    required String resultType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_extractionsKey) ?? [];
    jsonList.add(jsonEncode({
      'extractedText': extractedText,
      'resultType': resultType,
      'timestamp': DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList(_extractionsKey, jsonList);
  }

  @override
  Future<List<ProcessResult>> getExtractions(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_extractionsKey) ?? [];
    return jsonList.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return ProcessResult(
        success: true,
        message: '',
        extractedText: map['extractedText'] as String? ?? '',
        resultType: ProcessResultType.text,
        timestamp: DateTime.tryParse(map['timestamp'] as String? ?? ''),
      );
    }).toList();
  }
}
