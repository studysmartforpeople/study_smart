enum LearningLanguage {
  english('English'),
  khmer('Khmer');

  final String preferenceValue;

  const LearningLanguage(this.preferenceValue);

  bool get isKhmer => this == LearningLanguage.khmer;

  static LearningLanguage fromPreference(Object? value) {
    if (value == null || value == 'English') return LearningLanguage.english;
    if (value == 'Khmer') return LearningLanguage.khmer;
    throw FormatException('Unsupported learning language: $value');
  }
}
