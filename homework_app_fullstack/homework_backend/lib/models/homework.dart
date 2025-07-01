class Homework {
  final String id;
  final String title;
  final String subject;
  final String language;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final String learnerId;
  final HomeworkStatus status;
  final double? score;
  final List<HomeworkQuestion> questions;

  Homework({
    required this.id,
    required this.title,
    required this.subject,
    required this.language,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.learnerId,
    required this.status,
    this.score,
    required this.questions,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      language: json['language'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      learnerId: json['learnerId'],
      status: HomeworkStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      score: json['score']?.toDouble(),
      questions: (json['questions'] as List)
          .map((q) => HomeworkQuestion.fromJson(q))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'language': language,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'learnerId': learnerId,
      'status': status.toString().split('.').last,
      'score': score,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  factory Homework.fromMap(Map<String, dynamic> map) {
    return Homework(
      id: map['id'],
      title: map['title'],
      subject: map['subject'],
      language: map['language'],
      description: map['description'],
      dueDate: DateTime.parse(map['due_date']),
      createdAt: DateTime.parse(map['created_at']),
      learnerId: map['learner_id'],
      status: HomeworkStatus.values.firstWhere(
        (status) => status.toString().split('.').last == map['status'],
      ),
      score: map['score']?.toDouble(),
      questions: [], // Questions will be loaded separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'language': language,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'learner_id': learnerId,
      'status': status.toString().split('.').last,
      'score': score,
    };
  }

  double get progress {
    if (questions.isEmpty) return 0.0;
    int answeredQuestions = questions.where((q) => q.answer != null).length;
    return answeredQuestions / questions.length;
  }
}

class HomeworkQuestion {
  final String id;
  final String homeworkId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? answer;
  final bool isCorrect;

  HomeworkQuestion({
    required this.id,
    required this.homeworkId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.answer,
    this.isCorrect = false,
  });

  factory HomeworkQuestion.fromJson(Map<String, dynamic> json) {
    return HomeworkQuestion(
      id: json['id'],
      homeworkId: json['homeworkId'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      answer: json['answer'],
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeworkId': homeworkId,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'answer': answer,
      'isCorrect': isCorrect,
    };
  }

  factory HomeworkQuestion.fromMap(Map<String, dynamic> map) {
    return HomeworkQuestion(
      id: map['id'],
      homeworkId: map['homework_id'],
      question: map['question'],
      options: (map['options'] as String).split('|'),
      correctAnswer: map['correct_answer'],
      answer: map['answer'],
      isCorrect: map['is_correct'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'homework_id': homeworkId,
      'question': question,
      'options': options.join('|'),
      'correct_answer': correctAnswer,
      'answer': answer,
      'is_correct': isCorrect ? 1 : 0,
    };
  }

  HomeworkQuestion copyWith({
    String? answer,
    bool? isCorrect,
  }) {
    return HomeworkQuestion(
      id: id,
      homeworkId: homeworkId,
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      answer: answer ?? this.answer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

enum HomeworkStatus {
  pending,
  inProgress,
  completed,
  reviewed,
}

enum Subject {
  mathematics,
  science,
  computer,
}

enum Language {
  swahili,
  english,
  spanish,
}

