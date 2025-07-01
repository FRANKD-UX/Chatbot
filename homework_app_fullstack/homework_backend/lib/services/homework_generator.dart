import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/homework.dart';

class HomeworkGenerator {
  static const _uuid = Uuid();
  static final _random = Random();

  static Homework generateHomework({
    required String subject,
    required String language,
    required String learnerId,
  }) {
    final homeworkId = _uuid.v4();
    final questions = _generateQuestions(subject, language, homeworkId);
    
    return Homework(
      id: homeworkId,
      title: '${_capitalizeFirst(subject)} Homework',
      subject: subject,
      language: language,
      description: 'Practice questions for $subject in $language',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
      learnerId: learnerId,
      status: HomeworkStatus.inProgress,
      questions: questions,
    );
  }

  static List<HomeworkQuestion> _generateQuestions(String subject, String language, String homeworkId) {
    switch (subject) {
      case 'mathematics':
        return _generateMathQuestions(homeworkId, language);
      case 'science':
        return _generateScienceQuestions(homeworkId, language);
      case 'computer':
        return _generateComputerQuestions(homeworkId, language);
      default:
        return [];
    }
  }

  static List<HomeworkQuestion> _generateMathQuestions(String homeworkId, String language) {
    final questions = <HomeworkQuestion>[];
    
    // Addition question
    final a = _random.nextInt(50) + 10;
    final b = _random.nextInt(50) + 10;
    final correctSum = a + b;
    questions.add(HomeworkQuestion(
      id: _uuid.v4(),
      homeworkId: homeworkId,
      question: _translateQuestion('What is $a + $b?', language),
      options: _generateMathOptions(correctSum),
      correctAnswer: correctSum.toString(),
    ));

    // Multiplication question
    final c = _random.nextInt(12) + 2;
    final d = _random.nextInt(12) + 2;
    final correctProduct = c * d;
    questions.add(HomeworkQuestion(
      id: _uuid.v4(),
      homeworkId: homeworkId,
      question: _translateQuestion('What is $c × $d?', language),
      options: _generateMathOptions(correctProduct),
      correctAnswer: correctProduct.toString(),
    ));

    // Division question
    final divisor = _random.nextInt(10) + 2;
    final quotient = _random.nextInt(15) + 2;
    final dividend = divisor * quotient;
    questions.add(HomeworkQuestion(
      id: _uuid.v4(),
      homeworkId: homeworkId,
      question: _translateQuestion('What is $dividend ÷ $divisor?', language),
      options: _generateMathOptions(quotient),
      correctAnswer: quotient.toString(),
    ));

    return questions;
  }

  static List<HomeworkQuestion> _generateScienceQuestions(String homeworkId, String language) {
    final scienceQuestions = [
      {
        'question': 'What is the chemical symbol for water?',
        'options': ['H2O', 'CO2', 'O2', 'H2'],
        'correct': 'H2O',
      },
      {
        'question': 'How many planets are in our solar system?',
        'options': ['7', '8', '9', '10'],
        'correct': '8',
      },
      {
        'question': 'What gas do plants absorb from the atmosphere?',
        'options': ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
        'correct': 'Carbon Dioxide',
      },
      {
        'question': 'What is the largest organ in the human body?',
        'options': ['Heart', 'Brain', 'Liver', 'Skin'],
        'correct': 'Skin',
      },
      {
        'question': 'What is the speed of light?',
        'options': ['300,000 km/s', '150,000 km/s', '450,000 km/s', '600,000 km/s'],
        'correct': '300,000 km/s',
      },
    ];

    final selectedQuestions = (scienceQuestions..shuffle()).take(3).toList();
    
    return selectedQuestions.map((q) => HomeworkQuestion(
      id: _uuid.v4(),
      homeworkId: homeworkId,
      question: _translateQuestion(q['question'] as String, language),
      options: List<String>.from(q['options'] as List),
      correctAnswer: q['correct'] as String,
    )).toList();
  }

  static List<HomeworkQuestion> _generateComputerQuestions(String homeworkId, String language) {
    final computerQuestions = [
      {
        'question': 'What does CPU stand for?',
        'options': ['Central Processing Unit', 'Computer Personal Unit', 'Central Personal Unit', 'Computer Processing Unit'],
        'correct': 'Central Processing Unit',
      },
      {
        'question': 'Which of these is a programming language?',
        'options': ['HTML', 'Python', 'CSS', 'JSON'],
        'correct': 'Python',
      },
      {
        'question': 'What does RAM stand for?',
        'options': ['Random Access Memory', 'Read Access Memory', 'Random Available Memory', 'Read Available Memory'],
        'correct': 'Random Access Memory',
      },
      {
        'question': 'What is the binary representation of the decimal number 8?',
        'options': ['1000', '1010', '1100', '1001'],
        'correct': '1000',
      },
      {
        'question': 'Which company developed the Java programming language?',
        'options': ['Microsoft', 'Apple', 'Sun Microsystems', 'Google'],
        'correct': 'Sun Microsystems',
      },
    ];

    final selectedQuestions = (computerQuestions..shuffle()).take(3).toList();
    
    return selectedQuestions.map((q) => HomeworkQuestion(
      id: _uuid.v4(),
      homeworkId: homeworkId,
      question: _translateQuestion(q['question'] as String, language),
      options: List<String>.from(q['options'] as List),
      correctAnswer: q['correct'] as String,
    )).toList();
  }

  static List<String> _generateMathOptions(int correct) {
    final options = <String>[correct.toString()];
    
    while (options.length < 4) {
      final offset = _random.nextInt(20) - 10; // -10 to +10
      final option = (correct + offset).toString();
      if (!options.contains(option) && int.parse(option) > 0) {
        options.add(option);
      }
    }
    
    options.shuffle();
    return options;
  }

  static String _translateQuestion(String question, String language) {
    // Simple translation logic - in a real app, you'd use a proper translation service
    if (language == 'spanish') {
      final translations = {
        'What is': '¿Cuál es',
        'How many': '¿Cuántos',
        'What gas': '¿Qué gas',
        'What does': '¿Qué significa',
        'Which of': '¿Cuál de',
        'What is the': '¿Cuál es el/la',
        'Which company': '¿Qué empresa',
      };
      
      String translated = question;
      translations.forEach((key, value) {
        translated = translated.replaceFirst(key, value);
      });
      return translated;
    }
    
    if (language == 'swahili') {
      final translations = {
        'What is': 'Ni nini',
        'How many': 'Ni ngapi',
        'What gas': 'Ni gesi gani',
        'What does': 'Ni nini maana ya',
        'Which of': 'Ni ipi kati ya',
        'What is the': 'Ni nini',
        'Which company': 'Ni kampuni gani',
      };
      
      String translated = question;
      translations.forEach((key, value) {
        translated = translated.replaceFirst(key, value);
      });
      return translated;
    }
    
    return question; // Default to English
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

