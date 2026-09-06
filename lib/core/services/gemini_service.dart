import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> extractText(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final mimeType = _getMimeType(imageFile.path);

    final response = await _model.generateContent([
      Content.multi([
        TextPart(
          'Bu fotoğraftaki tüm metni çıkart. Sadece fotoğrafta görünen metni döndür, '
          'başka bir yorum, açıklama veya ekleme yapma. Metni olduğu gibi, '
          'paragraf ve satır düzenine sadık kalarak yaz.',
        ),
        DataPart(mimeType, imageBytes),
      ]),
    ]);

    return response.text ?? '';
  }

  Future<List<Map<String, dynamic>>> generateQuiz(String extractedText) async {
    final response = await _model.generateContent([
      Content.multi([
        TextPart(
          'Aşağıdaki metne dayanarak 10 adet çoktan seçmeli quiz sorası oluştur. '
          'Her sorunun 4 seçeneği olsun (A, B, C, D) ve bir doğru cevap belirt. '
          'Sorular metindeki farklı konuları kapsasın. '
          'Cevapları JSON formatında döndür. '
          'JSON formatı: [{"question": "Soru metni", "options": ["A seçeneği", "B seçeneği", "C seçeneği", "D seçeneği"], "correctIndex": 0}]'
          '\n\nMetin:\n$extractedText',
        ),
      ]),
    ]);

    final text = response.text ?? '[]';
    try {
      final cleaned = _extractJsonArray(text);
      final List<dynamic> parsed = jsonDecode(cleaned);
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  String _extractJsonArray(String text) {
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text;
  }
}
