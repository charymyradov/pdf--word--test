import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/process_result.dart';
import '../../domain/repositories/process_repository.dart';
import '../models/process_result_model.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/constants/app_firestore.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/image_cache_service.dart';

class ProcessRepositoryImpl implements ProcessRepository {
  final FirebaseFirestore _firestore;
  final GeminiService _geminiService;
  final ImageCacheService _imageCacheService;

  ProcessRepositoryImpl({
    required FirebaseFirestore firestore,
    required GeminiService geminiService,
    required ImageCacheService imageCacheService,
  })  : _firestore = firestore,
        _geminiService = geminiService,
        _imageCacheService = imageCacheService;

  @override
  Future<ProcessResult> processImage({
    required String imagePath,
    required ImageProcessType processType,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return ProcessResult(
        success: false,
        message: 'Gorsel dosyasi bulunamadi.',
      );
    }

    await _imageCacheService.saveImage(imagePath);

    final extractedText = await _geminiService.extractText(file);

    if (extractedText.trim().isEmpty) {
      return ProcessResult(
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
    final now = DateTime.now();
    final model = ProcessResultModel(
      id: '',
      extractedText: extractedText,
      resultType: resultType,
      timestamp: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );

    await _firestore
        .collection(AppFirestore.usersCollection)
        .doc(deviceId)
        .collection(AppFirestore.extractionsSubcollection)
        .add(model.toMap());
  }

  @override
  Future<List<ProcessResult>> getExtractions(String deviceId) async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection(AppFirestore.usersCollection)
        .doc(deviceId)
        .collection(AppFirestore.extractionsSubcollection)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProcessResultModel.fromFirestore(doc).toEntity())
        .toList();
  }
}
