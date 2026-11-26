import 'learning_content_translations.dart';
import 'learning_language.dart';

class LearningSubjectIds {
  static const englishBasic = 'english_basic';
  static const computerBasic = 'computer_basic';
  static const mathematicsBasic = 'mathematics_basic';
  static const programmingBasic = 'programming_basic';
}

class LearningSubject {
  final String id;
  final String name;
  final String description;

  const LearningSubject({
    required this.id,
    required this.name,
    required this.description,
  });
}

class LessonConcept {
  final String term;
  final String meaning;

  const LessonConcept({required this.term, required this.meaning});
}

class LessonSection {
  final String title;
  final String body;
  final List<String> keyPoints;

  const LessonSection({
    required this.title,
    required this.body,
    this.keyPoints = const [],
  });
}

class LessonDefinition {
  final String id;
  final String title;
  final String subjectId;
  final String subject;
  final String level;
  final String duration;
  final String summary;
  final List<LessonSection> sections;
  final List<LessonConcept> concepts;

  const LessonDefinition({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subject,
    required this.level,
    required this.duration,
    required this.summary,
    required this.sections,
    required this.concepts,
  });

  String titleFor(LearningLanguage language) =>
      LearningContentTranslations.lessonTitle(
        lessonId: id,
        englishTitle: title,
        language: language,
      );

  String subjectFor(LearningLanguage language) => language.isKhmer
      ? _khmerSubjectNames[subjectId] ??
            (throw StateError('Missing Khmer subject name for "$subjectId".'))
      : subject;

  String summaryFor(LearningLanguage language) =>
      LearningContentTranslations.lessonSummary(
        summary: summary,
        language: language,
      );

  String levelFor(LearningLanguage language) =>
      language.isKhmer ? _khmerLevels[level] ?? level : level;

  String durationFor(LearningLanguage language) => language.isKhmer
      ? duration.replaceFirst('mins', 'នាទី').replaceFirst('min', 'នាទី')
      : duration;

  String conceptMeaningFor(LessonConcept concept, LearningLanguage language) =>
      LearningContentTranslations.conceptMeaning(
        lessonId: id,
        term: concept.term,
        khmerMeaning: concept.meaning,
        language: language,
      );
}

class QuizQuestion {
  final String prompt;
  final List<String> options;
  final int correctOption;

  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctOption,
  });
}

class QuizDefinition {
  final String id;
  final String title;
  final String lessonId;
  final String? nextLessonId;
  final List<QuizQuestion> questions;

  const QuizDefinition({
    required this.id,
    required this.title,
    required this.lessonId,
    required this.nextLessonId,
    required this.questions,
  });
}

class LearningCurriculum {
  static const passScore = 80;
  static const questionsPerQuiz = 10;

  static const subjects = [
    LearningSubject(
      id: LearningSubjectIds.englishBasic,
      name: 'English Basic',
      description: 'Build vocabulary, grammar, and reading confidence.',
    ),
    LearningSubject(
      id: LearningSubjectIds.computerBasic,
      name: 'Computer Basic',
      description: 'Learn hardware, software, and digital safety basics.',
    ),
    LearningSubject(
      id: LearningSubjectIds.mathematicsBasic,
      name: 'Mathematics Basic',
      description: 'Practice arithmetic, fractions, and problem solving.',
    ),
    LearningSubject(
      id: LearningSubjectIds.programmingBasic,
      name: 'Programming Basic',
      description: 'Start coding with logic, variables, and loops.',
    ),
  ];

  static final List<LessonDefinition> lessons = List.unmodifiable(
    _lessonPlans.map(_createLesson),
  );

  static final List<QuizDefinition> quizzes = List.unmodifiable([
    for (final lesson in lessons) _createQuiz(lesson),
  ]);

  static List<LessonDefinition> lessonsForSubject(String subjectId) =>
      lessons.where((lesson) => lesson.subjectId == subjectId).toList();

  static LessonDefinition? firstLessonForSubject(String subjectId) {
    for (final lesson in lessons) {
      if (lesson.subjectId == subjectId) return lesson;
    }
    return null;
  }

  static LessonDefinition lessonById(String id) =>
      lessons.firstWhere((lesson) => lesson.id == id);

  static QuizDefinition? quizForLesson(String lessonId) {
    for (final quiz in quizzes) {
      if (quiz.lessonId == lessonId) return quiz;
    }
    return null;
  }

  static QuizDefinition quizById(String id) =>
      quizzes.firstWhere((quiz) => quiz.id == id);

  static QuizDefinition? quizUnlockingLesson(String lessonId) {
    for (final quiz in quizzes) {
      if (quiz.nextLessonId == lessonId) return quiz;
    }
    return null;
  }

  static bool containsSubject(String subjectId) =>
      subjects.any((subject) => subject.id == subjectId);

  static QuizDefinition quizForLanguage(
    QuizDefinition quiz,
    LearningLanguage language,
  ) {
    final lesson = lessonById(quiz.lessonId);
    final concepts = lesson.concepts;
    final meanings = [
      for (final concept in concepts)
        lesson.conceptMeaningFor(concept, language),
    ];
    final questions = <QuizQuestion>[];

    for (var index = 0; index < concepts.length; index++) {
      final concept = concepts[index];
      final firstDistractor = concepts[(index + 1) % concepts.length];
      final secondDistractor = concepts[(index + 3) % concepts.length];
      final answerMeaning = meanings[index];
      final firstDistractorMeaning = meanings[(index + 1) % meanings.length];
      final secondDistractorMeaning = meanings[(index + 3) % meanings.length];
      final khmer = language.isKhmer;

      questions
        ..add(
          _multipleChoiceQuestion(
            prompt: khmer
                ? 'តើពាក្យ "${concept.term}" មានន័យដូចម្តេច?'
                : 'What does "${concept.term}" mean?',
            answer: answerMeaning,
            distractors: [firstDistractorMeaning, secondDistractorMeaning],
            correctIndex: index % 3,
          ),
        )
        ..add(
          _multipleChoiceQuestion(
            prompt: khmer
                ? 'តើពាក្យណាមានន័យថា៖ $answerMeaning?'
                : 'Which term means: $answerMeaning?',
            answer: concept.term,
            distractors: [firstDistractor.term, secondDistractor.term],
            correctIndex: (index + 1) % 3,
          ),
        );
    }

    return QuizDefinition(
      id: quiz.id,
      title: language.isKhmer
          ? '${lesson.titleFor(language)} - តេស្ត'
          : quiz.title,
      lessonId: quiz.lessonId,
      nextLessonId: quiz.nextLessonId,
      questions: questions,
    );
  }
}

class _LessonPlan {
  final String id;
  final String title;
  final String subjectId;
  final String level;
  final String duration;
  final String summary;
  final List<LessonConcept> concepts;

  const _LessonPlan({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.level,
    required this.duration,
    required this.summary,
    required this.concepts,
  });
}

LessonDefinition _createLesson(_LessonPlan plan) {
  final subject = LearningCurriculum.subjects.firstWhere(
    (item) => item.id == plan.subjectId,
  );

  return LessonDefinition(
    id: plan.id,
    title: plan.title,
    subjectId: plan.subjectId,
    subject: subject.name,
    level: plan.level,
    duration: plan.duration,
    summary: plan.summary,
    concepts: plan.concepts,
    sections: [
      LessonSection(
        title: 'គោលគំនិតសំខាន់ៗ (Key concepts)',
        body: plan.summary,
        keyPoints: [
          for (final concept in plan.concepts)
            '${concept.term}: ${concept.meaning}',
        ],
      ),
    ],
  );
}

QuizDefinition _createQuiz(LessonDefinition lesson) {
  final sameSubjectLessons = LearningCurriculum.lessonsForSubject(
    lesson.subjectId,
  );
  final lessonIndex = sameSubjectLessons.indexWhere(
    (item) => item.id == lesson.id,
  );
  final nextLesson = lessonIndex + 1 < sameSubjectLessons.length
      ? sameSubjectLessons[lessonIndex + 1]
      : null;

  return QuizDefinition(
    id: _quizId(lesson.id),
    title: _quizTitle(lesson),
    lessonId: lesson.id,
    nextLessonId: nextLesson?.id,
    questions: _createQuestions(lesson),
  );
}

List<QuizQuestion> _createQuestions(LessonDefinition lesson) {
  final concepts = lesson.concepts;
  if (concepts.length != LearningCurriculum.questionsPerQuiz ~/ 2) {
    throw StateError(
      '${lesson.id} must define five concepts to create a 10-question quiz.',
    );
  }

  final questions = <QuizQuestion>[];
  for (var index = 0; index < concepts.length; index++) {
    final concept = concepts[index];
    final firstDistractor = concepts[(index + 1) % concepts.length];
    final secondDistractor = concepts[(index + 3) % concepts.length];

    questions
      ..add(
        _multipleChoiceQuestion(
          prompt:
              'តើ "${concept.term}" មានន័យដូចម្តេច? '
              '(What does this term mean?)',
          answer: concept.meaning,
          distractors: [firstDistractor.meaning, secondDistractor.meaning],
          correctIndex: index % 3,
        ),
      )
      ..add(
        _multipleChoiceQuestion(
          prompt:
              'តើពាក្យណាសំដៅលើ៖ ${concept.meaning}? '
              '(Which term matches this meaning?)',
          answer: concept.term,
          distractors: [firstDistractor.term, secondDistractor.term],
          correctIndex: (index + 1) % 3,
        ),
      );
  }
  return questions;
}

QuizQuestion _multipleChoiceQuestion({
  required String prompt,
  required String answer,
  required List<String> distractors,
  required int correctIndex,
}) {
  final choices = [answer, ...distractors];
  final options = List<String>.generate(
    choices.length,
    (index) =>
        choices[(index - correctIndex + choices.length) % choices.length],
  );
  return QuizQuestion(
    prompt: prompt,
    options: options,
    correctOption: correctIndex,
  );
}

String _quizId(String lessonId) => switch (lessonId) {
  'english_alphabet' => 'english_alphabet_quiz',
  'english_vocabulary' => 'english_vocabulary_quiz',
  'computer_safety' => 'computer_safety_quiz',
  'math_fractions' => 'math_fractions_quiz',
  'programming_variables' => 'programming_variables_quiz',
  _ => '${lessonId}_quiz',
};

String _quizTitle(LessonDefinition lesson) => switch (lesson.id) {
  'english_alphabet' => 'English Alphabet Quiz',
  'english_vocabulary' => 'Vocabulary Essentials Quiz',
  'computer_safety' => 'Computer Safety Quiz',
  'math_fractions' => 'Fractions Quiz',
  'programming_variables' => 'Programming Variables Quiz',
  _ => '${lesson.title} Quiz',
};

const _khmerSubjectNames = <String, String>{
  LearningSubjectIds.englishBasic: 'មូលដ្ឋានភាសាអង់គ្លេស',
  LearningSubjectIds.computerBasic: 'មូលដ្ឋានកុំព្យូទ័រ',
  LearningSubjectIds.mathematicsBasic: 'មូលដ្ឋានគណិតវិទ្យា',
  LearningSubjectIds.programmingBasic: 'មូលដ្ឋានសរសេរកម្មវិធី',
};

const _khmerLevels = <String, String>{
  'Beginner': 'កម្រិតដំបូង',
  'Intermediate': 'កម្រិតមធ្យម',
  'Advanced': 'កម្រិតខ្ពស់',
};

const _lessonPlans = <_LessonPlan>[
  _LessonPlan(
    id: 'english_alphabet',
    title: 'English Alphabet: A, B, C',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '10 mins',
    summary:
        'រៀនស្គាល់អក្សរ A-Z អក្សរធំ/តូច និងសំឡេងដំបូងក្នុងពាក្យអង់គ្លេស។ '
        '(Recognize letters, cases, and beginning sounds.)',
    concepts: [
      LessonConcept(term: 'alphabet', meaning: 'សំណុំអក្សរ A-Z (letters A-Z)'),
      LessonConcept(
        term: 'uppercase',
        meaning: 'អក្សរធំ ដូចជា A (capital letter)',
      ),
      LessonConcept(
        term: 'lowercase',
        meaning: 'អក្សរតូច ដូចជា a (small letter)',
      ),
      LessonConcept(term: 'vowel', meaning: 'អក្សរស្រៈ A, E, I, O, U'),
      LessonConcept(term: 'consonant', meaning: 'ព្យញ្ជនៈ ដូចជា B និង C'),
    ],
  ),
  _LessonPlan(
    id: 'english_vocabulary',
    title: 'Vocabulary Essentials',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '15 mins',
    summary:
        'ពង្រីកពាក្យប្រើប្រាស់ប្រចាំថ្ងៃ ហើយប្រើបរិបទដើម្បីយល់ន័យ។ '
        '(Build everyday words and understand them in context.)',
    concepts: [
      LessonConcept(term: 'word', meaning: 'ពាក្យដែលមានសំឡេង និងអត្ថន័យ'),
      LessonConcept(term: 'meaning', meaning: 'អត្ថន័យដែលពាក្យចង់ប្រាប់'),
      LessonConcept(term: 'context', meaning: 'ពាក្យជុំវិញដែលជួយបកស្រាយន័យ'),
      LessonConcept(
        term: 'synonym',
        meaning: 'ពាក្យមានន័យប្រហាក់ប្រហែល (similar meaning)',
      ),
      LessonConcept(
        term: 'antonym',
        meaning: 'ពាក្យមានន័យផ្ទុយ (opposite meaning)',
      ),
    ],
  ),
  _LessonPlan(
    id: 'english_greetings',
    title: 'Greetings and Introductions',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '12 mins',
    summary:
        'ហាត់ស្វាគមន៍ ណែនាំខ្លួន និងប្រើពាក្យសមរម្យពេលជួបអ្នកដទៃ។ '
        '(Practice polite greetings and introductions.)',
    concepts: [
      LessonConcept(term: 'hello', meaning: 'ពាក្យស្វាគមន៍ “សួស្តី”'),
      LessonConcept(term: 'good morning', meaning: 'ការស្វាគមន៍ពេលព្រឹក'),
      LessonConcept(term: 'introduce', meaning: 'ប្រាប់ឈ្មោះ និងណែនាំខ្លួន'),
      LessonConcept(term: 'please', meaning: 'ពាក្យសុភាពពេលស្នើសុំ'),
      LessonConcept(term: 'thank you', meaning: 'ពាក្យសម្តែងការដឹងគុណ'),
    ],
  ),
  _LessonPlan(
    id: 'english_pronouns',
    title: 'Pronouns: I, You, We',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '14 mins',
    summary:
        'ស្គាល់ pronouns ដែលប្រើជំនួសឈ្មោះមនុស្ស ឬវត្ថុក្នុងប្រយោគ។ '
        '(Use pronouns instead of repeating names.)',
    concepts: [
      LessonConcept(
        term: 'pronoun',
        meaning: 'ពាក្យជំនួសនាម (a word used instead of a noun)',
      ),
      LessonConcept(term: 'I', meaning: 'ប្រើពេលអ្នកនិយាយសំដៅលើខ្លួនឯង'),
      LessonConcept(term: 'you', meaning: 'សំដៅលើមនុស្សដែលយើងកំពុងនិយាយជាមួយ'),
      LessonConcept(term: 'he / she', meaning: 'សំដៅលើមនុស្សម្នាក់ផ្សេងទៀត'),
      LessonConcept(
        term: 'we / they',
        meaning: 'we សំដៅក្រុមយើង; they សំដៅក្រុមផ្សេង',
      ),
    ],
  ),
  _LessonPlan(
    id: 'english_nouns',
    title: 'Nouns and Plurals',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '15 mins',
    summary:
        'រៀនសម្គាល់ nouns សម្រាប់មនុស្ស ទីកន្លែង វត្ថុ និងបង្កើតពហុវចនៈ។ '
        '(Name people, places, things, and more than one item.)',
    concepts: [
      LessonConcept(term: 'noun', meaning: 'នាមសម្រាប់មនុស្ស ទីកន្លែង ឬវត្ថុ'),
      LessonConcept(term: 'singular', meaning: 'នាមសំដៅលើមួយ (one item)'),
      LessonConcept(term: 'plural', meaning: 'នាមសំដៅលើច្រើនជាងមួយ'),
      LessonConcept(
        term: 'common noun',
        meaning: 'នាមទូទៅ ដូចជា city ឬ teacher',
      ),
      LessonConcept(
        term: 'proper noun',
        meaning: 'ឈ្មោះជាក់លាក់ ដូចជា Phnom Penh',
      ),
    ],
  ),
  _LessonPlan(
    id: 'english_verbs',
    title: 'Action Verbs',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '15 mins',
    summary:
        'រក verbs ក្នុងប្រយោគ ហើយប្រើពាក្យសកម្មភាពជាមួយប្រធានឱ្យត្រូវ។ '
        '(Find action words and match them with a subject.)',
    concepts: [
      LessonConcept(term: 'verb', meaning: 'កិរិយាសព្ទ ឬពាក្យបង្ហាញសកម្មភាព'),
      LessonConcept(term: 'action', meaning: 'អ្វីដែលមនុស្ស ឬវត្ថុកំពុងធ្វើ'),
      LessonConcept(
        term: 'base form',
        meaning: 'ទម្រង់ដើមរបស់កិរិយាសព្ទ ដូចជា play',
      ),
      LessonConcept(
        term: 'subject',
        meaning: 'អ្នក ឬវត្ថុដែលធ្វើសកម្មភាពក្នុងប្រយោគ',
      ),
      LessonConcept(
        term: 'present tense',
        meaning: 'ទម្រង់និយាយអំពីបច្ចុប្បន្ន',
      ),
    ],
  ),
  _LessonPlan(
    id: 'english_adjectives',
    title: 'Adjectives and Descriptions',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '14 mins',
    summary:
        'ប្រើ adjectives ដើម្បីពណ៌នាទំហំ ពណ៌ រូបរាង និងអារម្មណ៍។ '
        '(Describe nouns with clear details.)',
    concepts: [
      LessonConcept(term: 'adjective', meaning: 'គុណនាមដែលពណ៌នានាម'),
      LessonConcept(term: 'size', meaning: 'ទំហំ ដូចជា small ឬ large'),
      LessonConcept(term: 'color', meaning: 'ពណ៌ ដូចជា blue ឬ green'),
      LessonConcept(term: 'feeling', meaning: 'អារម្មណ៍ ដូចជា happy ឬ tired'),
      LessonConcept(
        term: 'description',
        meaning: 'ព័ត៌មានលម្អិតអំពីមនុស្ស ឬវត្ថុ',
      ),
    ],
  ),
  _LessonPlan(
    id: 'english_present_simple',
    title: 'Present Simple Sentences',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'បង្កើតប្រយោគ present simple សម្រាប់ទម្លាប់ និងការពិតប្រចាំថ្ងៃ។ '
        '(Talk about routines and facts.)',
    concepts: [
      LessonConcept(
        term: 'present simple',
        meaning: 'កាលបច្ចុប្បន្នសាមញ្ញ សម្រាប់ទម្លាប់',
      ),
      LessonConcept(term: 'routine', meaning: 'សកម្មភាពដែលធ្វើជាប្រចាំ'),
      LessonConcept(term: 'do / does', meaning: 'ជំនួយការសម្រាប់សំណួរ ឬបដិសេធ'),
      LessonConcept(term: 'negative', meaning: 'ប្រយោគបដិសេធ ដូចជា do not'),
      LessonConcept(
        term: 'often',
        meaning: 'adverb បង្ហាញភាពញឹកញាប់ (frequency)',
      ),
    ],
  ),
  _LessonPlan(
    id: 'english_question_words',
    title: 'Question Words',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '16 mins',
    summary:
        'ប្រើ question words ដើម្បីសួរអំពីវត្ថុ ទីកន្លែង ពេលវេលា និងមនុស្ស។ '
        '(Ask clear questions about everyday information.)',
    concepts: [
      LessonConcept(term: 'what', meaning: 'ប្រើសួរអំពីវត្ថុ ឬព័ត៌មាន'),
      LessonConcept(term: 'where', meaning: 'ប្រើសួរអំពីទីកន្លែង'),
      LessonConcept(term: 'when', meaning: 'ប្រើសួរអំពីពេលវេលា'),
      LessonConcept(term: 'who', meaning: 'ប្រើសួរអំពីមនុស្ស'),
      LessonConcept(term: 'why', meaning: 'ប្រើសួរអំពីមូលហេតុ'),
    ],
  ),
  _LessonPlan(
    id: 'english_reading',
    title: 'Reading Short Texts',
    subjectId: LearningSubjectIds.englishBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'អានអត្ថបទខ្លី ស្វែងរកគំនិតសំខាន់ ព័ត៌មានលម្អិត និងលំដាប់ព្រឹត្តិការណ៍។ '
        '(Read for meaning, details, and sequence.)',
    concepts: [
      LessonConcept(term: 'title', meaning: 'ចំណងជើងបង្ហាញប្រធានបទអត្ថបទ'),
      LessonConcept(
        term: 'main idea',
        meaning: 'គំនិតសំខាន់ដែលអត្ថបទចង់ប្រាប់',
      ),
      LessonConcept(
        term: 'detail',
        meaning: 'ព័ត៌មានជាក់លាក់គាំទ្រគំនិតសំខាន់',
      ),
      LessonConcept(term: 'context', meaning: 'ព័ត៌មានជុំវិញពាក្យជួយយល់ន័យ'),
      LessonConcept(term: 'sequence', meaning: 'លំដាប់ដែលព្រឹត្តិការណ៍កើតឡើង'),
    ],
  ),
  _LessonPlan(
    id: 'computer_parts',
    title: 'Computer Parts',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '15 mins',
    summary:
        'ស្គាល់ផ្នែករឹងសំខាន់ៗ និងរបៀបប្រើកុំព្យូទ័រសម្រាប់ការងារ។ '
        '(Identify common computer hardware.)',
    concepts: [
      LessonConcept(term: 'hardware', meaning: 'ផ្នែករឹងដែលអាចប៉ះបាន'),
      LessonConcept(
        term: 'CPU',
        meaning: 'ផ្នែកដំណើរការព័ត៌មាន និងបញ្ជាកុំព្យូទ័រ',
      ),
      LessonConcept(term: 'monitor', meaning: 'អេក្រង់បង្ហាញរូបភាព និងអត្ថបទ'),
      LessonConcept(term: 'keyboard', meaning: 'ឧបករណ៍បញ្ចូលអក្សរ និងលេខ'),
      LessonConcept(term: 'mouse', meaning: 'ឧបករណ៍ចង្អុល និងចុចលើអេក្រង់'),
    ],
  ),
  _LessonPlan(
    id: 'computer_software',
    title: 'Software and Operating Systems',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '16 mins',
    summary:
        'បែងចែក software, operating system និងកម្មវិធីដែលជួយធ្វើកិច្ចការ។ '
        '(Understand the programs that run a computer.)',
    concepts: [
      LessonConcept(
        term: 'software',
        meaning: 'កម្មវិធី និងសេចក្តីណែនាំសម្រាប់កុំព្យូទ័រ',
      ),
      LessonConcept(
        term: 'operating system',
        meaning: 'ប្រព័ន្ធគ្រប់គ្រងផ្នែករឹង និងកម្មវិធី',
      ),
      LessonConcept(
        term: 'application',
        meaning: 'កម្មវិធីសម្រាប់កិច្ចការជាក់លាក់',
      ),
      LessonConcept(
        term: 'update',
        meaning: 'កំណែថ្មីជួសជុលកំហុស និងពង្រឹងសុវត្ថិភាព',
      ),
      LessonConcept(
        term: 'license',
        meaning: 'លក្ខខណ្ឌអនុញ្ញាតឱ្យប្រើ software',
      ),
    ],
  ),
  _LessonPlan(
    id: 'computer_input_output',
    title: 'Input and Output Devices',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '15 mins',
    summary:
        'សម្គាល់ឧបករណ៍បញ្ចូលទិន្នន័យ និងឧបករណ៍បង្ហាញលទ្ធផល។ '
        '(Learn how devices send and receive information.)',
    concepts: [
      LessonConcept(
        term: 'input',
        meaning: 'ទិន្នន័យដែលអ្នកបញ្ចូលទៅកុំព្យូទ័រ',
      ),
      LessonConcept(term: 'output', meaning: 'លទ្ធផលដែលកុំព្យូទ័របង្ហាញចេញ'),
      LessonConcept(term: 'input device', meaning: 'ឧបករណ៍បញ្ជូនទិន្នន័យចូល'),
      LessonConcept(
        term: 'output device',
        meaning: 'ឧបករណ៍បង្ហាញ ឬបញ្ចេញលទ្ធផល',
      ),
      LessonConcept(
        term: 'touchscreen',
        meaning: 'អេក្រង់ដែលបញ្ចូល និងបង្ហាញព័ត៌មាន',
      ),
    ],
  ),
  _LessonPlan(
    id: 'computer_files',
    title: 'Files and Folders',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '16 mins',
    summary:
        'រៀបចំឯកសារដោយដាក់ឈ្មោះច្បាស់ និងរក្សាទុកក្នុង folders សមស្រប។ '
        '(Organize and protect your digital files.)',
    concepts: [
      LessonConcept(
        term: 'file',
        meaning: 'ឯកសារផ្ទុកទិន្នន័យមួយ ដូចជា text ឬ photo',
      ),
      LessonConcept(
        term: 'folder',
        meaning: 'ទីតាំងសម្រាប់ដាក់ និងរៀបចំ files',
      ),
      LessonConcept(
        term: 'file extension',
        meaning: 'អក្សរខាងចុងបង្ហាញប្រភេទ file ដូចជា .pdf',
      ),
      LessonConcept(term: 'save', meaning: 'រក្សាការផ្លាស់ប្តូរទៅក្នុងឯកសារ'),
      LessonConcept(
        term: 'backup',
        meaning: 'ច្បាប់ចម្លងសម្រាប់ស្ដារទិន្នន័យវិញ',
      ),
    ],
  ),
  _LessonPlan(
    id: 'computer_browser',
    title: 'Using a Web Browser',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '17 mins',
    summary:
        'ប្រើ browser ដើម្បីបើកគេហទំព័រ ស្វែងរកព័ត៌មាន និងពិនិត្យប្រភព។ '
        '(Browse the web carefully and find reliable information.)',
    concepts: [
      LessonConcept(
        term: 'internet',
        meaning: 'បណ្ដាញភ្ជាប់កុំព្យូទ័រទូទាំងពិភពលោក',
      ),
      LessonConcept(term: 'browser', meaning: 'កម្មវិធីសម្រាប់បើកគេហទំព័រ'),
      LessonConcept(term: 'URL', meaning: 'អាសយដ្ឋានរបស់ទំព័រគេហទំព័រ'),
      LessonConcept(
        term: 'search engine',
        meaning: 'សេវាកម្មស្វែងរកទំព័រព័ត៌មាន',
      ),
      LessonConcept(term: 'tab', meaning: 'ផ្ទាំងបើកគេហទំព័រមួយក្នុង browser'),
    ],
  ),
  _LessonPlan(
    id: 'computer_safety',
    title: 'Internet Safety and Passwords',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '20 mins',
    summary:
        'ការពារគណនី ពិនិត្យតំណភ្ជាប់សង្ស័យ និងសុំជំនួយពីមនុស្សដែលទុកចិត្ត។ '
        '(Protect accounts and make safe choices online.)',
    concepts: [
      LessonConcept(
        term: 'strong password',
        meaning: 'ពាក្យសម្ងាត់វែង និងពិបាកទាយ',
      ),
      LessonConcept(term: 'phishing', meaning: 'សារបោកបញ្ឆោតដើម្បីលួចព័ត៌មាន'),
      LessonConcept(
        term: 'privacy',
        meaning: 'ការរក្សាព័ត៌មានផ្ទាល់ខ្លួនឱ្យមានសុវត្ថិភាព',
      ),
      LessonConcept(
        term: 'suspicious link',
        meaning: 'តំណដែលមកពីប្រភពមិនស្គាល់ ឬគួរឱ្យសង្ស័យ',
      ),
      LessonConcept(term: 'sign out', meaning: 'ចាកចេញពីគណនីលើឧបករណ៍រួម'),
    ],
  ),
  _LessonPlan(
    id: 'computer_email',
    title: 'Email and Digital Communication',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '17 mins',
    summary:
        'សរសេរ email ច្បាស់ សុភាព និងពិនិត្យអ្នកទទួលមុនពេលផ្ញើ។ '
        '(Communicate clearly and safely by email.)',
    concepts: [
      LessonConcept(
        term: 'email address',
        meaning: 'អាសយដ្ឋានសម្រាប់ផ្ញើ និងទទួល email',
      ),
      LessonConcept(
        term: 'subject line',
        meaning: 'ចំណងជើងខ្លីបង្ហាញប្រធានបទ email',
      ),
      LessonConcept(term: 'inbox', meaning: 'ថតផ្ទុកសារដែលបានទទួល'),
      LessonConcept(term: 'attachment', meaning: 'ឯកសារភ្ជាប់ជាមួយសារ'),
      LessonConcept(term: 'reply', meaning: 'ការឆ្លើយតបទៅសារដែលបានទទួល'),
    ],
  ),
  _LessonPlan(
    id: 'computer_documents',
    title: 'Creating Documents',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'បង្កើតឯកសារអត្ថបទ កែទម្រង់ និងរក្សាទុកឯកសារឱ្យងាយរក។ '
        '(Create, format, and save a simple document.)',
    concepts: [
      LessonConcept(
        term: 'word processor',
        meaning: 'កម្មវិធីសម្រាប់សរសេរ និងកែអត្ថបទ',
      ),
      LessonConcept(term: 'cursor', meaning: 'សញ្ញាបង្ហាញទីតាំងអក្សរបន្ទាប់'),
      LessonConcept(term: 'format', meaning: 'ការកែរូបរាងអក្សរ និងកថាខណ្ឌ'),
      LessonConcept(term: 'document', meaning: 'ឯកសារដែលមានអត្ថបទ ឬរូបភាព'),
      LessonConcept(term: 'print', meaning: 'បញ្ជូនឯកសារទៅម៉ាស៊ីនបោះពុម្ព'),
    ],
  ),
  _LessonPlan(
    id: 'computer_networks',
    title: 'Networks and Connectivity',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'ស្គាល់ network, Wi-Fi និងរបៀបភ្ជាប់ឧបករណ៍ដើម្បីចែករំលែកទិន្នន័យ។ '
        '(Understand basic network connections.)',
    concepts: [
      LessonConcept(
        term: 'network',
        meaning: 'ឧបករណ៍ភ្ជាប់គ្នាដើម្បីចែករំលែកទិន្នន័យ',
      ),
      LessonConcept(term: 'Wi-Fi', meaning: 'ការភ្ជាប់បណ្ដាញឥតខ្សែ'),
      LessonConcept(term: 'router', meaning: 'ឧបករណ៍ចែកចាយការភ្ជាប់បណ្ដាញ'),
      LessonConcept(
        term: 'bandwidth',
        meaning: 'សមត្ថភាពផ្ទេរទិន្នន័យក្នុងពេលមួយ',
      ),
      LessonConcept(term: 'connection', meaning: 'តំណភ្ជាប់ឧបករណ៍ទៅ network'),
    ],
  ),
  _LessonPlan(
    id: 'computer_troubleshooting',
    title: 'Basic Troubleshooting',
    subjectId: LearningSubjectIds.computerBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'ពិនិត្យបញ្ហាកុំព្យូទ័រតាមជំហានសាមញ្ញ និងសុំជំនួយពេលចាំបាច់។ '
        '(Use safe steps to identify common problems.)',
    concepts: [
      LessonConcept(
        term: 'troubleshooting',
        meaning: 'ដំណើរការស្វែងរកមូលហេតុបញ្ហា',
      ),
      LessonConcept(
        term: 'restart',
        meaning: 'បិទហើយបើកប្រព័ន្ធឡើងវិញដោយសុវត្ថិភាព',
      ),
      LessonConcept(
        term: 'error message',
        meaning: 'សារបង្ហាញថាកម្មវិធីជួបបញ្ហា',
      ),
      LessonConcept(
        term: 'check connection',
        meaning: 'ពិនិត្យខ្សែ ឬ Wi-Fi មុនជំហានផ្សេង',
      ),
      LessonConcept(
        term: 'ask for help',
        meaning: 'សុំជំនួយពីអ្នកដែលមានចំណេះដឹង',
      ),
    ],
  ),
  _LessonPlan(
    id: 'math_place_value',
    title: 'Numbers and Place Value',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '16 mins',
    summary:
        'យល់ពីតម្លៃលេខតាមទីតាំង ones, tens, hundreds និងការបំបែកចំនួន។ '
        '(Read and build whole numbers.)',
    concepts: [
      LessonConcept(term: 'digit', meaning: 'និមិត្តសញ្ញាលេខពី 0 ដល់ 9'),
      LessonConcept(
        term: 'place value',
        meaning: 'តម្លៃរបស់លេខអាស្រ័យលើទីតាំង',
      ),
      LessonConcept(term: 'ones', meaning: 'ទីតាំងឯកតាខាងស្តាំបំផុត'),
      LessonConcept(term: 'tens', meaning: 'ទីតាំងស្មើក្រុមដប់'),
      LessonConcept(term: 'hundreds', meaning: 'ទីតាំងស្មើក្រុមមួយរយ'),
    ],
  ),
  _LessonPlan(
    id: 'math_addition_subtraction',
    title: 'Addition and Subtraction',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'ប្រើ addition ដើម្បីបូក និង subtraction ដើម្បីរកចំនួននៅសល់ ឬភាពខុសគ្នា។ '
        '(Combine and compare quantities.)',
    concepts: [
      LessonConcept(term: 'addition', meaning: 'ប្រមូលចំនួនចូលគ្នាដោយសញ្ញា +'),
      LessonConcept(term: 'sum', meaning: 'លទ្ធផលដែលបានពីការបូក'),
      LessonConcept(term: 'subtraction', meaning: 'ដកចំនួនដោយសញ្ញា −'),
      LessonConcept(term: 'difference', meaning: 'លទ្ធផលពីការដកចំនួនពីរ'),
      LessonConcept(
        term: 'inverse operations',
        meaning: 'ប្រមាណវិធីដែលអាចត្រួតពិនិត្យគ្នា',
      ),
    ],
  ),
  _LessonPlan(
    id: 'math_multiplication',
    title: 'Multiplication and Arrays',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'យល់ថាការគុណជាការបូកក្រុមស្មើៗគ្នា និងប្រើតារាងដើម្បីគណនា។ '
        '(Multiply equal groups efficiently.)',
    concepts: [
      LessonConcept(
        term: 'multiplication',
        meaning: 'ការបូកក្រុមចំនួនស្មើៗគ្នា',
      ),
      LessonConcept(term: 'factor', meaning: 'ចំនួនមួយក្នុងប្រមាណវិធីគុណ'),
      LessonConcept(term: 'product', meaning: 'លទ្ធផលដែលបានពីការគុណ'),
      LessonConcept(term: 'array', meaning: 'ការរៀបចំជាជួរដេក និងជួរឈរ'),
      LessonConcept(
        term: 'commutative property',
        meaning: 'ប្ដូរលំដាប់កត្តាហើយផលគុណនៅដដែល',
      ),
    ],
  ),
  _LessonPlan(
    id: 'math_division',
    title: 'Division and Equal Groups',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'ចែកចំនួនជាក្រុមស្មើៗគ្នា ហើយសម្គាល់ quotient និង remainder។ '
        '(Share quantities fairly and check with multiplication.)',
    concepts: [
      LessonConcept(term: 'division', meaning: 'ការបែងចែកជាក្រុមស្មើៗគ្នា'),
      LessonConcept(term: 'dividend', meaning: 'ចំនួនដែលត្រូវចែក'),
      LessonConcept(
        term: 'divisor',
        meaning: 'ចំនួនក្រុម ឬចំនួនដែលប្រើសម្រាប់ចែក',
      ),
      LessonConcept(term: 'quotient', meaning: 'ចម្លើយគត់ពីការចែក'),
      LessonConcept(term: 'remainder', meaning: 'ចំនួនដែលនៅសល់ក្រោយចែក'),
    ],
  ),
  _LessonPlan(
    id: 'math_fractions',
    title: 'Working with Fractions',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'សិក្សាប្រភាគជាផ្នែកស្មើៗគ្នានៃទាំងមូល និងអាន numerator/denominator។ '
        '(Describe equal parts of a whole.)',
    concepts: [
      LessonConcept(term: 'fraction', meaning: 'ចំនួនតំណាងឱ្យផ្នែកនៃទាំងមូល'),
      LessonConcept(
        term: 'numerator',
        meaning: 'លេខខាងលើប្រាប់ចំនួនផ្នែកដែលយក',
      ),
      LessonConcept(
        term: 'denominator',
        meaning: 'លេខខាងក្រោមប្រាប់ចំនួនផ្នែកសរុប',
      ),
      LessonConcept(
        term: 'equivalent fractions',
        meaning: 'ប្រភាគខុសទម្រង់តែមានតម្លៃស្មើគ្នា',
      ),
      LessonConcept(
        term: 'one half',
        meaning: 'មួយក្នុងចំណោមផ្នែកស្មើពីរ (1/2)',
      ),
    ],
  ),
  _LessonPlan(
    id: 'math_decimals',
    title: 'Decimals and Place Value',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'អានលេខទសភាគ និងស្គាល់ tenths, hundredths និងចំណុចទសភាគ។ '
        '(Read decimal values and compare their size.)',
    concepts: [
      LessonConcept(
        term: 'decimal',
        meaning: 'ចំនួនមានផ្នែកគត់ និងផ្នែកប្រភាគ',
      ),
      LessonConcept(
        term: 'decimal point',
        meaning: 'សញ្ញាបំបែកផ្នែកគត់ពីផ្នែកទសភាគ',
      ),
      LessonConcept(term: 'tenths', meaning: 'ទីតាំងដំបូងក្រោយចំណុចទសភាគ'),
      LessonConcept(term: 'hundredths', meaning: 'ទីតាំងទីពីរក្រោយចំណុចទសភាគ'),
      LessonConcept(
        term: 'compare decimals',
        meaning: 'ប្រៀបធៀបតម្លៃដោយមើលទីតាំងដូចគ្នា',
      ),
    ],
  ),
  _LessonPlan(
    id: 'math_measurement',
    title: 'Measurement and Units',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'វាស់ប្រវែង ម៉ាស និងចំណុះដោយជ្រើស units ដែលសមស្រប។ '
        '(Measure objects and choose useful units.)',
    concepts: [
      LessonConcept(term: 'length', meaning: 'ចម្ងាយពីចុងមួយទៅចុងមួយ'),
      LessonConcept(term: 'mass', meaning: 'បរិមាណសារធាតុក្នុងវត្ថុ'),
      LessonConcept(term: 'capacity', meaning: 'បរិមាណរាវដែលធុងអាចផ្ទុក'),
      LessonConcept(term: 'unit', meaning: 'ឯកតាសម្រាប់បង្ហាញការវាស់ ដូចជា cm'),
      LessonConcept(term: 'perimeter', meaning: 'ប្រវែងជុំវិញគែមរូបរាង'),
    ],
  ),
  _LessonPlan(
    id: 'math_geometry',
    title: 'Shapes and Geometry',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'ស្គាល់ shapes, sides, vertices និង angles ក្នុងរូបធរណីមាត្រ។ '
        '(Describe shapes by their sides and corners.)',
    concepts: [
      LessonConcept(term: 'shape', meaning: 'រូបរាងដែលកំណត់ដោយគែម ឬខ្សែកោង'),
      LessonConcept(term: 'side', meaning: 'ខ្សែបន្ទាត់បង្កើតគែមរូបរាង'),
      LessonConcept(term: 'vertex', meaning: 'ចំណុចដែលជ្រុងពីរជួបគ្នា'),
      LessonConcept(term: 'angle', meaning: 'ចន្លោះបើករវាងខ្សែពីរ'),
      LessonConcept(
        term: 'polygon',
        meaning: 'រូបបិទដែលមានជ្រុងជាបន្ទាត់ត្រង់',
      ),
    ],
  ),
  _LessonPlan(
    id: 'math_patterns',
    title: 'Patterns and Sequences',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '16 mins',
    summary:
        'រកលំនាំនៃចំនួន ឬរូបរាង ហើយព្យាករណ៍ធាតុបន្ទាប់ដោយប្រើ rule។ '
        '(Describe a pattern and continue its sequence.)',
    concepts: [
      LessonConcept(term: 'pattern', meaning: 'លំដាប់ដែលមានរបៀបកើតឡើងដដែលៗ'),
      LessonConcept(term: 'sequence', meaning: 'បញ្ជីធាតុតាមលំដាប់ជាក់លាក់'),
      LessonConcept(
        term: 'rule',
        meaning: 'សេចក្តីណែនាំបង្ហាញការផ្លាស់ប្តូររបស់លំនាំ',
      ),
      LessonConcept(term: 'term', meaning: 'ធាតុមួយនៅក្នុង sequence'),
      LessonConcept(term: 'predict', meaning: 'ទាយធាតុបន្ទាប់ដោយប្រើ rule'),
    ],
  ),
  _LessonPlan(
    id: 'math_word_problems',
    title: 'Solving Word Problems',
    subjectId: LearningSubjectIds.mathematicsBasic,
    level: 'Beginner',
    duration: '20 mins',
    summary:
        'អានបញ្ហា កំណត់ព័ត៌មានសំខាន់ ជ្រើសប្រមាណវិធី និងពិនិត្យចម្លើយ។ '
        '(Turn a story into a clear mathematical plan.)',
    concepts: [
      LessonConcept(
        term: 'known information',
        meaning: 'ទិន្នន័យដែលបញ្ហាបានផ្ដល់',
      ),
      LessonConcept(term: 'unknown', meaning: 'តម្លៃដែលយើងត្រូវរក'),
      LessonConcept(
        term: 'operation',
        meaning: 'ប្រមាណវិធីដែលត្រូវជ្រើស ដូចជា + ឬ ×',
      ),
      LessonConcept(
        term: 'estimate',
        meaning: 'ចម្លើយប្រហាក់ប្រហែលសម្រាប់ពិនិត្យ',
      ),
      LessonConcept(term: 'check', meaning: 'វិធីផ្ទៀងផ្ទាត់ថាចម្លើយសមហេតុផល'),
    ],
  ),
  _LessonPlan(
    id: 'programming_algorithms',
    title: 'Algorithms and Instructions',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'រៀបចំជំហានតាមលំដាប់ ដើម្បីដោះស្រាយបញ្ហាមុនសរសេរកូដ។ '
        '(Plan clear steps before writing a program.)',
    concepts: [
      LessonConcept(
        term: 'algorithm',
        meaning: 'ជំហានច្បាស់ៗសម្រាប់ដោះស្រាយបញ្ហា',
      ),
      LessonConcept(
        term: 'sequence',
        meaning: 'លំដាប់ដែលសេចក្តីណែនាំត្រូវអនុវត្ត',
      ),
      LessonConcept(
        term: 'instruction',
        meaning: 'បញ្ជាមួយដែលកុំព្យូទ័រអាចអនុវត្ត',
      ),
      LessonConcept(
        term: 'pseudocode',
        meaning: 'ផែនការកូដសរសេរជាភាសាមនុស្សងាយអាន',
      ),
      LessonConcept(term: 'decomposition', meaning: 'បំបែកបញ្ហាធំជាបញ្ហាតូចៗ'),
    ],
  ),
  _LessonPlan(
    id: 'programming_variables',
    title: 'Variables in Programming',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '25 mins',
    summary:
        'ប្រើ variables ដាក់ឈ្មោះទិន្នន័យ ហើយប្ដូរតម្លៃពេលកម្មវិធីដំណើរការ។ '
        '(Store and update information in a program.)',
    concepts: [
      LessonConcept(
        term: 'variable',
        meaning: 'កន្លែងមានឈ្មោះសម្រាប់រក្សាទុកតម្លៃ',
      ),
      LessonConcept(
        term: 'assignment',
        meaning: 'ការដាក់តម្លៃទៅក្នុង variable',
      ),
      LessonConcept(
        term: 'identifier',
        meaning: 'ឈ្មោះដែលប្រើសម្គាល់ variable',
      ),
      LessonConcept(
        term: 'value',
        meaning: 'ទិន្នន័យដែល variable កំពុងរក្សាទុក',
      ),
      LessonConcept(term: 'update', meaning: 'ការប្ដូរតម្លៃចាស់ទៅតម្លៃថ្មី'),
    ],
  ),
  _LessonPlan(
    id: 'programming_data_types',
    title: 'Data Types',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'ស្គាល់ប្រភេទទិន្នន័យ ដើម្បីជ្រើសរើសរបៀបរក្សា និងប្រើតម្លៃឱ្យត្រឹមត្រូវ។ '
        '(Choose a type that matches the data.)',
    concepts: [
      LessonConcept(term: 'integer', meaning: 'ចំនួនគត់គ្មានចំណុចទសភាគ'),
      LessonConcept(term: 'float', meaning: 'ចំនួនដែលអាចមានចំណុចទសភាគ'),
      LessonConcept(
        term: 'string',
        meaning: 'អត្ថបទ ឬតួអក្សរដែលដាក់ក្នុង quotes',
      ),
      LessonConcept(term: 'boolean', meaning: 'តម្លៃ true ឬ false'),
      LessonConcept(
        term: 'data type',
        meaning: 'ការបញ្ជាក់ប្រភេទតម្លៃដែល variable ផ្ទុក',
      ),
    ],
  ),
  _LessonPlan(
    id: 'programming_input_output',
    title: 'Input and Output',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '17 mins',
    summary:
        'ទទួល input ពីអ្នកប្រើ ដំណើរការទិន្នន័យ ហើយបង្ហាញ output ដែលងាយយល់។ '
        '(Build a simple input-process-output flow.)',
    concepts: [
      LessonConcept(term: 'input', meaning: 'ទិន្នន័យដែលកម្មវិធីទទួល'),
      LessonConcept(
        term: 'process',
        meaning: 'ការងារដែលកម្មវិធីធ្វើលើទិន្នន័យ',
      ),
      LessonConcept(term: 'output', meaning: 'លទ្ធផលដែលកម្មវិធីបង្ហាញ'),
      LessonConcept(
        term: 'prompt',
        meaning: 'សារ​ស្នើឱ្យអ្នកប្រើបញ្ចូលព័ត៌មាន',
      ),
      LessonConcept(
        term: 'validation',
        meaning: 'ការពិនិត្យ input មុនប្រើប្រាស់',
      ),
    ],
  ),
  _LessonPlan(
    id: 'programming_operators',
    title: 'Operators and Expressions',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '18 mins',
    summary:
        'ប្រើ operators សម្រាប់គណនា ប្រៀបធៀប និងបង្កើត expressions។ '
        '(Combine values into useful calculations and checks.)',
    concepts: [
      LessonConcept(
        term: 'arithmetic operator',
        meaning: 'សញ្ញាគណនា ដូចជា +, -, ×, ÷',
      ),
      LessonConcept(
        term: 'comparison operator',
        meaning: 'សញ្ញាប្រៀបធៀប ដូចជា < ឬ >',
      ),
      LessonConcept(
        term: 'equality operator',
        meaning: 'ពិនិត្យថាតម្លៃពីរស្មើគ្នាឬអត់',
      ),
      LessonConcept(
        term: 'logical operator',
        meaning: 'ភ្ជាប់លក្ខខណ្ឌ ដូចជា AND ឬ OR',
      ),
      LessonConcept(
        term: 'expression',
        meaning: 'តម្លៃ ឬប្រមាណវិធីដែលអាចគណនាបាន',
      ),
    ],
  ),
  _LessonPlan(
    id: 'programming_conditions',
    title: 'Conditions and Decisions',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '20 mins',
    summary:
        'ប្រើ if/else ដើម្បីឱ្យកម្មវិធីជ្រើសរើសសកម្មភាពតាមលក្ខខណ្ឌ។ '
        '(Make a program choose between paths.)',
    concepts: [
      LessonConcept(
        term: 'condition',
        meaning: 'សំណួរដែលមានចម្លើយ true ឬ false',
      ),
      LessonConcept(term: 'if', meaning: 'បញ្ជាឱ្យដំណើរការបើលក្ខខណ្ឌពិត'),
      LessonConcept(term: 'else', meaning: 'ផ្លូវជំនួសពេលលក្ខខណ្ឌមិនពិត'),
      LessonConcept(
        term: 'branch',
        meaning: 'ផ្លូវសកម្មភាពមួយក្នុងការសម្រេចចិត្ត',
      ),
      LessonConcept(
        term: 'boolean result',
        meaning: 'លទ្ធផល true ឬ false របស់ condition',
      ),
    ],
  ),
  _LessonPlan(
    id: 'programming_loops',
    title: 'Loops and Repetition',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '20 mins',
    summary:
        'ប្រើ loops ដើម្បីធ្វើសកម្មភាពដដែលៗ ហើយបញ្ចប់ពេលលក្ខខណ្ឌសមស្រប។ '
        '(Repeat instructions safely and predictably.)',
    concepts: [
      LessonConcept(term: 'loop', meaning: 'បញ្ជាឱ្យដំណើរការកូដម្តងហើយម្តងទៀត'),
      LessonConcept(term: 'iteration', meaning: 'ការធ្វើជុំមួយនៃ loop'),
      LessonConcept(term: 'for loop', meaning: 'loop សមស្របពេលដឹងចំនួនជុំ'),
      LessonConcept(term: 'while loop', meaning: 'loop បន្តដរាបណាលក្ខខណ្ឌពិត'),
      LessonConcept(
        term: 'stop condition',
        meaning: 'លក្ខខណ្ឌដែលធ្វើឱ្យ loop បញ្ចប់',
      ),
    ],
  ),
  _LessonPlan(
    id: 'programming_functions',
    title: 'Functions and Reusable Code',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '20 mins',
    summary:
        'រៀបចំកូដជាមុខងារដែលអាចហៅប្រើឡើងវិញ និងទទួលលទ្ធផលត្រឡប់។ '
        '(Organize repeated work into reusable functions.)',
    concepts: [
      LessonConcept(
        term: 'function',
        meaning: 'ក្រុមកូដមានឈ្មោះសម្រាប់កិច្ចការមួយ',
      ),
      LessonConcept(
        term: 'parameter',
        meaning: 'ឈ្មោះ input ដែល function រំពឹងទុក',
      ),
      LessonConcept(
        term: 'argument',
        meaning: 'តម្លៃជាក់ស្តែងដែលផ្ញើទៅ function',
      ),
      LessonConcept(
        term: 'return value',
        meaning: 'លទ្ធផលដែល function បញ្ជូនត្រឡប់',
      ),
      LessonConcept(term: 'reuse', meaning: 'ហៅប្រើកូដដដែលដោយមិនសរសេរឡើងវិញ'),
    ],
  ),
  _LessonPlan(
    id: 'programming_lists',
    title: 'Lists and Collections',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '20 mins',
    summary:
        'រក្សាតម្លៃជាច្រើនក្នុង list ហើយប្រើ index ដើម្បីអាន ឬកែធាតុ។ '
        '(Store and access an ordered group of values.)',
    concepts: [
      LessonConcept(term: 'list', meaning: 'បណ្ដុំតម្លៃដែលរក្សាតាមលំដាប់'),
      LessonConcept(term: 'element', meaning: 'តម្លៃមួយដែលស្ថិតនៅក្នុង list'),
      LessonConcept(term: 'index', meaning: 'ទីតាំងសម្រាប់ស្វែងរក element'),
      LessonConcept(term: 'length', meaning: 'ចំនួន elements នៅក្នុង list'),
      LessonConcept(term: 'append', meaning: 'បន្ថែម element ទៅចុង list'),
    ],
  ),
  _LessonPlan(
    id: 'programming_debugging',
    title: 'Debugging and Testing',
    subjectId: LearningSubjectIds.programmingBasic,
    level: 'Beginner',
    duration: '20 mins',
    summary:
        'សាកល្បងកូដ ស្វែងរក bugs និងកែបញ្ហាតាមភស្តុតាងពី error messages។ '
        '(Test, inspect, and improve a program.)',
    concepts: [
      LessonConcept(term: 'bug', meaning: 'កំហុសដែលធ្វើឱ្យកម្មវិធីដំណើរការខុស'),
      LessonConcept(
        term: 'error message',
        meaning: 'ព័ត៌មានបង្ហាញប្រភេទ ឬទីតាំងបញ្ហា',
      ),
      LessonConcept(
        term: 'breakpoint',
        meaning: 'ចំណុចផ្អាកកូដដើម្បីពិនិត្យតម្លៃ',
      ),
      LessonConcept(
        term: 'test case',
        meaning: 'input និងលទ្ធផលរំពឹងទុកសម្រាប់សាកល្បង',
      ),
      LessonConcept(term: 'debugging', meaning: 'ដំណើរការស្វែងរក និងកែ bugs'),
    ],
  ),
];

int calculateQuizScore(QuizDefinition quiz, List<int> selectedOptions) {
  if (selectedOptions.length != quiz.questions.length) {
    throw ArgumentError('An answer is required for every quiz question.');
  }

  final correctAnswers = quiz.questions
      .asMap()
      .entries
      .where((entry) => selectedOptions[entry.key] == entry.value.correctOption)
      .length;
  return (correctAnswers * 100 / quiz.questions.length).round();
}
