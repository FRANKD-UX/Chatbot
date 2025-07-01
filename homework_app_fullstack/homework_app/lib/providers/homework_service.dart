import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/homework.dart';
import '../models/chat_message.dart';

class HomeworkService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000/api';
  
  Homework? _currentHomework;
  Subject? _selectedSubject;
  Language? _selectedLanguage;
  List<ChatMessage> _sessionMessages = [];
  bool _isGeneratingQuestions = false;

  // Getters
  Homework? get currentHomework => _currentHomework;
  Subject? get selectedSubject => _selectedSubject;
  Language? get selectedLanguage => _selectedLanguage;
  List<ChatMessage> get sessionMessages => _sessionMessages;
  bool get isGeneratingQuestions => _isGeneratingQuestions;

  // Subject and Language selection
  void setSelectedSubject(Subject subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setSelectedLanguage(Language language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void clearSelections() {
    _selectedSubject = null;
    _selectedLanguage = null;
    notifyListeners();
  }

  // Homework session management
  void setCurrentHomework(Homework homework) {
    _currentHomework = homework;
    notifyListeners();
  }

  void clearCurrentHomework() {
    _currentHomework = null;
    _sessionMessages.clear();
    notifyListeners();
  }

  // Chat session management
  void addSessionMessage(ChatMessage message) {
    _sessionMessages.add(message);
    notifyListeners();
  }

  void clearSessionMessages() {
    _sessionMessages.clear();
    notifyListeners();
  }

  // Generate homework questions based on subject and language
  Future<Homework> generateHomework({
    required Subject subject,
    required Language language,
    required String learnerId,
  }) async {
    _isGeneratingQuestions = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/homework/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subject': subject.toString().split('.').last,
          'language': language.toString().split('.').last,
          'learnerId': learnerId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final homework = Homework.fromJson(data);
        _currentHomework = homework;
        _isGeneratingQuestions = false;
        notifyListeners();
        return homework;
      } else {
        throw Exception('Failed to generate homework: ${response.statusCode}');
      }
    } catch (e) {
      _isGeneratingQuestions = false;
      notifyListeners();
      throw Exception('Error generating homework: $e');
    }
  }

  // Submit answer for a question
  Future<bool> submitAnswer({
    required String homeworkId,
    required String questionId,
    required String answer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/homework/$homeworkId/answer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'questionId': questionId,
          'answer': answer,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isCorrect = data['isCorrect'] as bool;
        
        // Update the current homework with the new answer
        if (_currentHomework != null) {
          final updatedQuestions = _currentHomework!.questions.map((q) {
            if (q.id == questionId) {
              return q.copyWith(answer: answer, isCorrect: isCorrect);
            }
            return q;
          }).toList();

          _currentHomework = Homework(
            id: _currentHomework!.id,
            title: _currentHomework!.title,
            subject: _currentHomework!.subject,
            language: _currentHomework!.language,
            description: _currentHomework!.description,
            dueDate: _currentHomework!.dueDate,
            createdAt: _currentHomework!.createdAt,
            learnerId: _currentHomework!.learnerId,
            status: _currentHomework!.status,
            score: _currentHomework!.score,
            questions: updatedQuestions,
          );
          notifyListeners();
        }

        return isCorrect;
      } else {
        throw Exception('Failed to submit answer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting answer: $e');
    }
  }

  // Complete homework session
  Future<double> completeHomework(String homeworkId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/homework/$homeworkId/complete'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final score = data['score'] as double;
        
        if (_currentHomework != null) {
          _currentHomework = Homework(
            id: _currentHomework!.id,
            title: _currentHomework!.title,
            subject: _currentHomework!.subject,
            language: _currentHomework!.language,
            description: _currentHomework!.description,
            dueDate: _currentHomework!.dueDate,
            createdAt: _currentHomework!.createdAt,
            learnerId: _currentHomework!.learnerId,
            status: HomeworkStatus.completed,
            score: score,
            questions: _currentHomework!.questions,
          );
          notifyListeners();
        }

        return score;
      } else {
        throw Exception('Failed to complete homework: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error completing homework: $e');
    }
  }

  // Get homework list for a user
  Future<List<Homework>> getHomeworkList(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/homework/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => Homework.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get homework list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting homework list: $e');
    }
  }

  // Mock data for development
  List<HomeworkQuestion> generateMockQuestions(Subject subject, Language language) {
    final questions = <HomeworkQuestion>[];
    
    switch (subject) {
      case Subject.mathematics:
        questions.addAll([
          HomeworkQuestion(
            id: '1',
            question: 'What is 15 + 27?',
            options: ['40', '42', '45', '47'],
            correctAnswer: '42',
          ),
          HomeworkQuestion(
            id: '2',
            question: 'What is 8 × 7?',
            options: ['54', '56', '58', '60'],
            correctAnswer: '56',
          ),
          HomeworkQuestion(
            id: '3',
            question: 'What is 144 ÷ 12?',
            options: ['10', '11', '12', '13'],
            correctAnswer: '12',
          ),
        ]);
        break;
      case Subject.science:
        questions.addAll([
          HomeworkQuestion(
            id: '1',
            question: 'What is the chemical symbol for water?',
            options: ['H2O', 'CO2', 'O2', 'H2'],
            correctAnswer: 'H2O',
          ),
          HomeworkQuestion(
            id: '2',
            question: 'How many planets are in our solar system?',
            options: ['7', '8', '9', '10'],
            correctAnswer: '8',
          ),
          HomeworkQuestion(
            id: '3',
            question: 'What gas do plants absorb from the atmosphere?',
            options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
            correctAnswer: 'Carbon Dioxide',
          ),
        ]);
        break;
      case Subject.computer:
        questions.addAll([
          HomeworkQuestion(
            id: '1',
            question: 'What does CPU stand for?',
            options: ['Central Processing Unit', 'Computer Personal Unit', 'Central Personal Unit', 'Computer Processing Unit'],
            correctAnswer: 'Central Processing Unit',
          ),
          HomeworkQuestion(
            id: '2',
            question: 'Which of these is a programming language?',
            options: ['HTML', 'Python', 'CSS', 'JSON'],
            correctAnswer: 'Python',
          ),
          HomeworkQuestion(
            id: '3',
            question: 'What does RAM stand for?',
            options: ['Random Access Memory', 'Read Access Memory', 'Random Available Memory', 'Read Available Memory'],
            correctAnswer: 'Random Access Memory',
          ),
        ]);
        break;
    }

    return questions;
  }

  Homework createMockHomework({
    required Subject subject,
    required Language language,
    required String learnerId,
  }) {
    final questions = generateMockQuestions(subject, language);
    
    return Homework(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${subject.toString().split('.').last.toUpperCase()} Homework',
      subject: subject.toString().split('.').last,
      language: language.toString().split('.').last,
      description: 'Practice questions for ${subject.toString().split('.').last}',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
      learnerId: learnerId,
      status: HomeworkStatus.inProgress,
      questions: questions,
    );
  }
}

