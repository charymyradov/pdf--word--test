enum ImageProcessType {
  quizCreate('Quiz Oluştur (AI)', 'Fotoğraftan AI ile test oluştur', '🧠'),
  extractText('Sadece Metin Çıkar', 'Fotoğraftaki metni OCR ile oku', '📝'),
  exportWord('Metin Çıkar ve Word\'e Aktar', 'Metni çıkar ve Word dosyasına aktar', '📄'),
  exportExcel('Metin Çıkar ve Excel\'e Aktar', 'Metni çıkar ve Excel dosyasına aktar', '📊');

  final String title;
  final String subtitle;
  final String icon;

  const ImageProcessType(this.title, this.subtitle, this.icon);
}

enum ProcessState {
  idle,
  loading,
  success,
  error,
}

enum QuizDifficulty {
  easy,
  medium,
  hard,
}

enum SubjectCategory {
  all('Tümü'),
  stem('STEM'),
  humanities('Edebiyat'),
  languages('Dil');

  final String label;
  const SubjectCategory(this.label);
}

enum ProcessResultType {
  quiz,
  text,
  word,
  excel,
}
