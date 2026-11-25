class LessonDefinition {
  final String id;
  final String title;
  final String subject;
  final String level;
  final String duration;

  const LessonDefinition({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.duration,
  });
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

  static const lessons = [
    LessonDefinition(
      id: 'english_alphabet',
      title: 'English Alphabet: A, B, C',
      subject: 'English Basic',
      level: 'Beginner',
      duration: '10 mins',
    ),
    LessonDefinition(
      id: 'english_vocabulary',
      title: 'Vocabulary Essentials',
      subject: 'English Basic',
      level: 'Beginner',
      duration: '15 mins',
    ),
    LessonDefinition(
      id: 'computer_safety',
      title: 'Computer Safety',
      subject: 'Computer Basic',
      level: 'Beginner',
      duration: '20 mins',
    ),
    LessonDefinition(
      id: 'math_fractions',
      title: 'Working with Fractions',
      subject: 'Mathematics Basic',
      level: 'Beginner',
      duration: '18 mins',
    ),
    LessonDefinition(
      id: 'programming_variables',
      title: 'Variables in Programming',
      subject: 'Programming Basic',
      level: 'Beginner',
      duration: '25 mins',
    ),
  ];

  static const quizzes = [
    QuizDefinition(
      id: 'english_alphabet_quiz',
      title: 'English Alphabet Quiz',
      lessonId: 'english_alphabet',
      nextLessonId: 'english_vocabulary',
      questions: [
        QuizQuestion(
          prompt: 'Which letter comes first in the English alphabet?',
          options: ['A', 'B', 'C'],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'Which letter comes after A?',
          options: ['C', 'B', 'D'],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'Which one is the lowercase letter a?',
          options: ['A', 'b', 'a'],
          correctOption: 2,
        ),
        QuizQuestion(
          prompt: 'C is for which word?',
          options: ['Apple', 'Cat', 'Ball'],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'Which one is the uppercase letter B?',
          options: ['b', 'B', 'c'],
          correctOption: 1,
        ),
      ],
    ),
    QuizDefinition(
      id: 'english_vocabulary_quiz',
      title: 'Vocabulary Essentials Quiz',
      lessonId: 'english_vocabulary',
      nextLessonId: 'computer_safety',
      questions: [
        QuizQuestion(
          prompt: 'Which one is a fruit?',
          options: ['Apple', 'Chair', 'Pencil'],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'What is the opposite of hot?',
          options: ['Warm', 'Cold', 'Fast'],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'What do we use to read?',
          options: ['A book', 'A shoe', 'A cup'],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'What does happy mean?',
          options: ['Feeling glad', 'Feeling tired', 'Feeling hungry'],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'What is the plural of cat?',
          options: ['Cates', 'Cats', 'Caties'],
          correctOption: 1,
        ),
      ],
    ),
    QuizDefinition(
      id: 'computer_safety_quiz',
      title: 'Computer Safety Quiz',
      lessonId: 'computer_safety',
      nextLessonId: 'math_fractions',
      questions: [
        QuizQuestion(
          prompt: 'Which password is the safest?',
          options: ['123456', 'password', 'R7!mQ2#v'],
          correctOption: 2,
        ),
        QuizQuestion(
          prompt: 'What should you do with a suspicious link?',
          options: ['Open it', 'Avoid clicking it', 'Send it to everyone'],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'Should you share your password with strangers?',
          options: ['Yes', 'No', 'Only online'],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'What should you do on a shared computer?',
          options: [
            'Log out when finished',
            'Save your password',
            'Leave it open',
          ],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'Who should you tell about an unsafe message?',
          options: ['A trusted adult', 'A stranger', 'Nobody'],
          correctOption: 0,
        ),
      ],
    ),
    QuizDefinition(
      id: 'math_fractions_quiz',
      title: 'Fractions Quiz',
      lessonId: 'math_fractions',
      nextLessonId: 'programming_variables',
      questions: [
        QuizQuestion(
          prompt: 'What is one half of 8?',
          options: ['2', '4', '6'],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'Which fraction means one out of two equal parts?',
          options: ['1/2', '1/3', '2/3'],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'What is one quarter of 12?',
          options: ['2', '3', '4'],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'Which fraction is larger?',
          options: ['1/4', '1/2', 'They are equal'],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'How many quarters make one whole?',
          options: ['2', '3', '4'],
          correctOption: 2,
        ),
      ],
    ),
    QuizDefinition(
      id: 'programming_variables_quiz',
      title: 'Programming Variables Quiz',
      lessonId: 'programming_variables',
      nextLessonId: null,
      questions: [
        QuizQuestion(
          prompt: 'What does a variable do?',
          options: [
            'Stores information',
            'Turns off a computer',
            'Draws a picture',
          ],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'Which is a valid variable name?',
          options: ['studentName', 'student name', '2student'],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'In `score = 10`, what is the value?',
          options: ['score', '10', '='],
          correctOption: 1,
        ),
        QuizQuestion(
          prompt: 'Can a variable value change?',
          options: ['Yes', 'Never', 'Only once ever'],
          correctOption: 0,
        ),
        QuizQuestion(
          prompt: 'Which name best describes a variable holding an age?',
          options: ['x', 'studentAge', 'thing'],
          correctOption: 1,
        ),
      ],
    ),
  ];

  static LessonDefinition lessonById(String id) =>
      lessons.firstWhere((lesson) => lesson.id == id);

  static QuizDefinition quizById(String id) =>
      quizzes.firstWhere((quiz) => quiz.id == id);

  static QuizDefinition? quizUnlockingLesson(String lessonId) {
    for (final quiz in quizzes) {
      if (quiz.nextLessonId == lessonId) return quiz;
    }
    return null;
  }
}

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
