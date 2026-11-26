import 'learning_language.dart';

class LearningContentTranslations {
  static String lessonTitle({
    required String lessonId,
    required String englishTitle,
    required LearningLanguage language,
  }) {
    if (!language.isKhmer) return englishTitle;
    return _khmerLessonTitles[lessonId] ??
        (throw StateError('Missing Khmer title for lesson "$lessonId".'));
  }

  static String lessonSummary({
    required String summary,
    required LearningLanguage language,
  }) {
    final openingParenthesis = summary.lastIndexOf('(');
    final hasEnglishTranslation =
        openingParenthesis >= 0 && summary.endsWith(')');
    if (language.isKhmer) {
      return hasEnglishTranslation
          ? summary.substring(0, openingParenthesis).trim()
          : summary;
    }
    return hasEnglishTranslation
        ? summary.substring(openingParenthesis + 1, summary.length - 1).trim()
        : summary;
  }

  static String conceptMeaning({
    required String lessonId,
    required String term,
    required String khmerMeaning,
    required LearningLanguage language,
  }) {
    if (language.isKhmer) {
      return khmerMeaning.replaceFirst(RegExp(r'\s*\([^)]*\)\s*$'), '');
    }
    final key = '$lessonId::$term';
    return _englishConceptMeanings[key] ??
        (throw StateError('Missing English meaning for "$key".'));
  }
}

const _khmerLessonTitles = <String, String>{
  'english_alphabet': 'អក្ខរក្រមអង់គ្លេស៖ A, B, C',
  'english_vocabulary': 'មូលដ្ឋានពាក្យប្រើប្រាស់',
  'english_greetings': 'ការស្វាគមន៍ និងការណែនាំខ្លួន',
  'english_pronouns': 'សព្វនាម៖ I, You, We',
  'english_nouns': 'នាម និងពហុវចនៈ',
  'english_verbs': 'កិរិយាសព្ទសកម្មភាព',
  'english_adjectives': 'គុណនាម និងការពិពណ៌នា',
  'english_present_simple': 'ប្រយោគកាលបច្ចុប្បន្នធម្មតា',
  'english_question_words': 'ពាក្យសំណួរ',
  'english_reading': 'ការអានអត្ថបទខ្លី',
  'computer_parts': 'ផ្នែកផ្សេងៗរបស់កុំព្យូទ័រ',
  'computer_software': 'កម្មវិធី និងប្រព័ន្ធប្រតិបត្តិការ',
  'computer_input_output': 'ឧបករណ៍បញ្ចូល និងបញ្ចេញទិន្នន័យ',
  'computer_files': 'ឯកសារ និងថតឯកសារ',
  'computer_browser': 'ការប្រើប្រាស់កម្មវិធីរុករកគេហទំព័រ',
  'computer_safety': 'សុវត្ថិភាពអ៊ីនធឺណិត និងពាក្យសម្ងាត់',
  'computer_email': 'អ៊ីមែល និងការទំនាក់ទំនងតាមប្រព័ន្ធឌីជីថល',
  'computer_documents': 'ការបង្កើតឯកសារ',
  'computer_networks': 'បណ្ដាញ និងការតភ្ជាប់',
  'computer_troubleshooting': 'ការដោះស្រាយបញ្ហាមូលដ្ឋាន',
  'math_place_value': 'ចំនួន និងតម្លៃតាមខ្ទង់',
  'math_addition_subtraction': 'ការបូក និងការដក',
  'math_multiplication': 'ការគុណ និងការរៀបចំជាក្រឡា',
  'math_division': 'ការចែក និងក្រុមស្មើៗគ្នា',
  'math_fractions': 'ការរៀនអំពីប្រភាគ',
  'math_decimals': 'ចំនួនទសភាគ និងតម្លៃតាមខ្ទង់',
  'math_measurement': 'ការវាស់វែង និងឯកតា',
  'math_geometry': 'រូបរាង និងធរណីមាត្រ',
  'math_patterns': 'លំនាំ និងស្វ៊ីត',
  'math_word_problems': 'ការដោះស្រាយចំណោទ',
  'programming_algorithms': 'ក្បួនដោះស្រាយ និងសេចក្តីណែនាំ',
  'programming_variables': 'អថេរក្នុងការសរសេរកម្មវិធី',
  'programming_data_types': 'ប្រភេទទិន្នន័យ',
  'programming_input_output': 'ទិន្នន័យបញ្ចូល និងលទ្ធផល',
  'programming_operators': 'សញ្ញាប្រមាណវិធី និងកន្សោម',
  'programming_conditions': 'លក្ខខណ្ឌ និងការសម្រេចចិត្ត',
  'programming_loops': 'រង្វិលជុំ និងការធ្វើសកម្មភាពដដែលៗ',
  'programming_functions': 'អនុគមន៍ និងកូដដែលអាចប្រើឡើងវិញ',
  'programming_lists': 'បញ្ជី និងបណ្ដុំទិន្នន័យ',
  'programming_debugging': 'ការស្វែងរកកំហុស និងការសាកល្បង',
};

const _englishConceptMeanings = <String, String>{
  'english_alphabet::alphabet': 'The complete set of letters from A to Z.',
  'english_alphabet::uppercase': 'A capital letter, such as A.',
  'english_alphabet::lowercase': 'A small letter, such as a.',
  'english_alphabet::vowel': 'One of the letters A, E, I, O, or U.',
  'english_alphabet::consonant':
      'A letter that is not a vowel, such as B or C.',
  'english_vocabulary::word': 'A unit of language with a sound and a meaning.',
  'english_vocabulary::meaning': 'The idea or message that a word expresses.',
  'english_vocabulary::context':
      'The surrounding words that help explain meaning.',
  'english_vocabulary::synonym': 'A word with a similar meaning.',
  'english_vocabulary::antonym': 'A word with an opposite meaning.',
  'english_greetings::hello': 'A friendly word used to greet someone.',
  'english_greetings::good morning': 'A greeting used in the morning.',
  'english_greetings::introduce':
      'To tell someone your name or present yourself.',
  'english_greetings::please': 'A polite word used when making a request.',
  'english_greetings::thank you': 'A polite phrase used to show gratitude.',
  'english_pronouns::pronoun': 'A word used instead of a noun.',
  'english_pronouns::I': 'The pronoun a speaker uses to refer to themself.',
  'english_pronouns::you': 'The pronoun for the person being spoken to.',
  'english_pronouns::he / she': 'Pronouns used for another person.',
  'english_pronouns::we / they':
      '“We” includes the speaker; “they” refers to others.',
  'english_nouns::noun': 'A word that names a person, place, or thing.',
  'english_nouns::singular': 'A form that refers to one person or thing.',
  'english_nouns::plural': 'A form that refers to more than one.',
  'english_nouns::common noun': 'A general name, such as city or teacher.',
  'english_nouns::proper noun': 'The specific name of a person or place.',
  'english_verbs::verb': 'A word that describes an action or state.',
  'english_verbs::action': 'Something a person or thing does.',
  'english_verbs::base form': 'The basic form of a verb, such as play.',
  'english_verbs::subject': 'The person or thing that performs an action.',
  'english_verbs::present tense': 'A verb form used for the present.',
  'english_adjectives::adjective': 'A word that describes a noun.',
  'english_adjectives::size': 'How big or small something is.',
  'english_adjectives::color':
      'The visual quality of something, such as blue or green.',
  'english_adjectives::feeling': 'An emotion or state, such as happy or tired.',
  'english_adjectives::description':
      'Details that explain what a person or thing is like.',
  'english_present_simple::present simple':
      'A tense used for routines and general facts.',
  'english_present_simple::routine': 'An activity that happens regularly.',
  'english_present_simple::do / does':
      'Helping verbs used in questions and negatives.',
  'english_present_simple::negative':
      'A sentence that says something does not happen or is not true.',
  'english_present_simple::often':
      'An adverb that describes how frequently something happens.',
  'english_question_words::what':
      'A question word used to ask about a thing or information.',
  'english_question_words::where': 'A question word used to ask about a place.',
  'english_question_words::when': 'A question word used to ask about a time.',
  'english_question_words::who': 'A question word used to ask about a person.',
  'english_question_words::why': 'A question word used to ask for a reason.',
  'english_reading::title': 'The heading that tells what a text is about.',
  'english_reading::main idea': 'The most important message in a text.',
  'english_reading::detail':
      'Specific information that supports the main idea.',
  'english_reading::context':
      'Information around a word that helps explain it.',
  'english_reading::sequence': 'The order in which events happen.',
  'computer_parts::hardware':
      'The physical parts of a computer that can be touched.',
  'computer_parts::CPU':
      'The component that processes information and controls computer tasks.',
  'computer_parts::monitor': 'A screen that displays images and text.',
  'computer_parts::keyboard': 'A device used to enter letters and numbers.',
  'computer_parts::mouse':
      'A pointing device used to move and click on the screen.',
  'computer_software::software':
      'Programs and instructions that tell a computer what to do.',
  'computer_software::operating system':
      'The main software that manages computer hardware and applications.',
  'computer_software::application':
      'A program designed to perform a particular task.',
  'computer_software::update':
      'A newer version that can fix problems and improve security.',
  'computer_software::license':
      'The terms that explain how software may be used.',
  'computer_input_output::input': 'Information entered into a computer.',
  'computer_input_output::output':
      'Information or results produced by a computer.',
  'computer_input_output::input device':
      'A device that sends information into a computer.',
  'computer_input_output::output device':
      'A device that presents information from a computer.',
  'computer_input_output::touchscreen':
      'A screen that both displays information and accepts touch input.',
  'computer_files::file':
      'A saved item of data, such as a text document or photo.',
  'computer_files::folder': 'A place used to store and organize files.',
  'computer_files::file extension':
      'The ending of a file name that indicates its type, such as .pdf.',
  'computer_files::save': 'To store changes in a file.',
  'computer_files::backup': 'A copy kept so data can be restored later.',
  'computer_browser::internet': 'A worldwide network that connects computers.',
  'computer_browser::browser': 'A program used to open and view websites.',
  'computer_browser::URL': 'The address of a page or resource on the web.',
  'computer_browser::search engine':
      'A service that helps find information on the web.',
  'computer_browser::tab': 'A separate page opened within a browser window.',
  'computer_safety::strong password':
      'A long password that is difficult to guess.',
  'computer_safety::phishing':
      'A dishonest message designed to steal personal information.',
  'computer_safety::privacy': 'Keeping personal information protected.',
  'computer_safety::suspicious link':
      'A link from an unknown or untrusted source.',
  'computer_safety::sign out':
      'To leave an account, especially on a shared device.',
  'computer_email::email address':
      'The address used to send and receive email.',
  'computer_email::subject line':
      'A short heading that describes an email topic.',
  'computer_email::inbox': 'The folder where received messages are stored.',
  'computer_email::attachment': 'A file sent along with a message.',
  'computer_email::reply': 'A response sent to a message you received.',
  'computer_documents::word processor':
      'A program for writing and editing text.',
  'computer_documents::cursor':
      'The marker showing where the next typed character will appear.',
  'computer_documents::format': 'To change how text or paragraphs look.',
  'computer_documents::document':
      'A file that contains text, images, or other information.',
  'computer_documents::print': 'To produce a paper copy using a printer.',
  'computer_networks::network':
      'Connected devices that share information or resources.',
  'computer_networks::Wi-Fi': 'A wireless way to connect to a network.',
  'computer_networks::router':
      'A device that directs network traffic between devices.',
  'computer_networks::bandwidth':
      'The amount of data a connection can transfer over time.',
  'computer_networks::connection':
      'A link that lets devices communicate with a network.',
  'computer_troubleshooting::troubleshooting':
      'A step-by-step process for finding the cause of a problem.',
  'computer_troubleshooting::restart':
      'To safely turn a system off and start it again.',
  'computer_troubleshooting::error message':
      'A message that reports a problem in a program or system.',
  'computer_troubleshooting::check connection':
      'To inspect cables or Wi-Fi before trying other fixes.',
  'computer_troubleshooting::ask for help':
      'To get support from someone with the right knowledge.',
  'math_place_value::digit':
      'One of the symbols from 0 to 9 used to write numbers.',
  'math_place_value::place value':
      'The value of a digit based on its position in a number.',
  'math_place_value::ones': 'The rightmost place, representing single units.',
  'math_place_value::tens': 'The place representing groups of ten.',
  'math_place_value::hundreds': 'The place representing groups of one hundred.',
  'math_addition_subtraction::addition':
      'Combining quantities using the plus sign.',
  'math_addition_subtraction::sum': 'The result of adding numbers.',
  'math_addition_subtraction::subtraction':
      'Taking one quantity away from another.',
  'math_addition_subtraction::difference':
      'The result of subtracting one number from another.',
  'math_addition_subtraction::inverse operations':
      'Operations that can be used to check each other.',
  'math_multiplication::multiplication': 'Adding equal groups efficiently.',
  'math_multiplication::factor': 'A number multiplied by another number.',
  'math_multiplication::product': 'The result of multiplication.',
  'math_multiplication::array': 'Objects arranged in rows and columns.',
  'math_multiplication::commutative property':
      'Changing the order of factors does not change the product.',
  'math_division::division': 'Splitting a quantity into equal groups.',
  'math_division::dividend': 'The number that is being divided.',
  'math_division::divisor': 'The number used to divide another number.',
  'math_division::quotient': 'The answer to a division problem.',
  'math_division::remainder': 'The amount left over after division.',
  'math_fractions::fraction': 'A number that represents part of a whole.',
  'math_fractions::numerator':
      'The top number, showing how many parts are selected.',
  'math_fractions::denominator':
      'The bottom number, showing the total equal parts.',
  'math_fractions::equivalent fractions':
      'Fractions that look different but have the same value.',
  'math_fractions::one half': 'One of two equal parts of a whole.',
  'math_decimals::decimal': 'A number with a whole part and a fractional part.',
  'math_decimals::decimal point':
      'The mark separating the whole and fractional parts.',
  'math_decimals::tenths': 'The first place to the right of the decimal point.',
  'math_decimals::hundredths':
      'The second place to the right of the decimal point.',
  'math_decimals::compare decimals':
      'To compare values by checking matching place values.',
  'math_measurement::length':
      'The distance from one end of an object to the other.',
  'math_measurement::mass': 'The amount of matter in an object.',
  'math_measurement::capacity': 'The amount of liquid a container can hold.',
  'math_measurement::unit': 'A standard amount used to describe a measurement.',
  'math_measurement::perimeter':
      'The total distance around the outside of a shape.',
  'math_geometry::shape': 'A figure defined by its edges or curves.',
  'math_geometry::side':
      'A straight line that forms part of a shape’s boundary.',
  'math_geometry::vertex': 'A point where two sides meet.',
  'math_geometry::angle': 'The opening between two lines that meet.',
  'math_geometry::polygon': 'A closed shape made from straight sides.',
  'math_patterns::pattern': 'A repeated or predictable way that things change.',
  'math_patterns::sequence': 'A list of items arranged in a specific order.',
  'math_patterns::rule': 'An instruction that explains how a pattern changes.',
  'math_patterns::term': 'One item or number in a sequence.',
  'math_patterns::predict': 'To work out what comes next by using a rule.',
  'math_word_problems::known information':
      'The facts or values already given in a problem.',
  'math_word_problems::unknown': 'The value that needs to be found.',
  'math_word_problems::operation': 'A calculation chosen to solve a problem.',
  'math_word_problems::estimate':
      'An approximate answer used to check if a result is reasonable.',
  'math_word_problems::check': 'To verify that an answer makes sense.',
  'programming_algorithms::algorithm':
      'A clear sequence of steps for solving a problem.',
  'programming_algorithms::sequence':
      'The order in which instructions are carried out.',
  'programming_algorithms::instruction':
      'A command that a computer can perform.',
  'programming_algorithms::pseudocode':
      'A readable, human-language plan for a program.',
  'programming_algorithms::decomposition':
      'Breaking a large problem into smaller parts.',
  'programming_variables::variable': 'A named place used to store a value.',
  'programming_variables::assignment': 'Giving a value to a variable.',
  'programming_variables::identifier': 'A name used to identify a variable.',
  'programming_variables::value': 'The data currently stored in a variable.',
  'programming_variables::update': 'Changing an old value to a new value.',
  'programming_data_types::integer': 'A whole number with no decimal part.',
  'programming_data_types::float': 'A number that can have a decimal part.',
  'programming_data_types::string': 'Text stored as a sequence of characters.',
  'programming_data_types::boolean': 'A value that is either true or false.',
  'programming_data_types::data type':
      'A category that describes what kind of value is stored.',
  'programming_input_output::input': 'Data that a program receives.',
  'programming_input_output::process': 'The work a program performs on data.',
  'programming_input_output::output': 'The result that a program produces.',
  'programming_input_output::prompt':
      'A message asking a user to enter information.',
  'programming_input_output::validation': 'Checking input before it is used.',
  'programming_operators::arithmetic operator':
      'A symbol for a calculation, such as +, -, ×, or ÷.',
  'programming_operators::comparison operator':
      'A symbol used to compare values, such as < or >.',
  'programming_operators::equality operator':
      'An operator that checks whether two values are equal.',
  'programming_operators::logical operator':
      'An operator that combines conditions, such as AND or OR.',
  'programming_operators::expression':
      'A value or calculation that can be evaluated.',
  'programming_conditions::condition': 'A test whose result is true or false.',
  'programming_conditions::if':
      'A command that runs code when a condition is true.',
  'programming_conditions::else':
      'An alternative path used when a condition is false.',
  'programming_conditions::branch': 'One possible path in a decision.',
  'programming_conditions::boolean result':
      'A true-or-false result from a condition.',
  'programming_loops::loop': 'Code that repeats instructions.',
  'programming_loops::iteration': 'One cycle of a loop.',
  'programming_loops::for loop':
      'A loop often used when the number of repetitions is known.',
  'programming_loops::while loop':
      'A loop that continues while a condition remains true.',
  'programming_loops::stop condition': 'A condition that ends a loop.',
  'programming_functions::function':
      'A named block of code that performs a task.',
  'programming_functions::parameter': 'A named input that a function expects.',
  'programming_functions::argument':
      'A value supplied to a function when it is called.',
  'programming_functions::return value':
      'The result that a function sends back.',
  'programming_functions::reuse':
      'Using the same code again instead of rewriting it.',
  'programming_lists::list': 'An ordered collection of values.',
  'programming_lists::element': 'One value stored in a list.',
  'programming_lists::index': 'A position used to find an element in a list.',
  'programming_lists::length': 'The number of elements in a list.',
  'programming_lists::append': 'To add an element to the end of a list.',
  'programming_debugging::bug':
      'A mistake that causes a program to behave incorrectly.',
  'programming_debugging::error message':
      'Information that describes a problem or where it occurred.',
  'programming_debugging::breakpoint':
      'A point where a program pauses so its values can be inspected.',
  'programming_debugging::test case':
      'An input and expected result used to check a program.',
  'programming_debugging::debugging':
      'The process of finding and fixing errors in code.',
};
