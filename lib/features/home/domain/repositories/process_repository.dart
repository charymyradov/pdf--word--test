import '../entities/process_result.dart';
import '../../../../core/enums/app_enums.dart';

abstract class ProcessRepository {
  Future<ProcessResult> processImage({
    required String imagePath,
    required ImageProcessType processType,
  });
  Future<void> saveExtraction({
    required String deviceId,
    required String extractedText,
    required String resultType,
  });
  Future<List<ProcessResult>> getExtractions(String deviceId);
}
