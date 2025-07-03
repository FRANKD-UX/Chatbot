import 'package:flutter/foundation.dart';
import '../models/homework.dart';
import '../models/chat_message.dart';
import '../services/supabase_service.dart';

class HomeworkService extends ChangeNotifier {
  bool useSupabase;
  HomeworkService({this.useSupabase = true});
  Homework? _currentHomework;
  Subject? _selectedSubject;
  Language? _selectedLanguage;
  List<ChatMessage> _sessionMessages = [];
  bool _isGeneratingQuestions = true;

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

  // Generate homework (create in Supabase)
  Future<void> generateHomework({
    required Subject subject,
    required Language language,
    required String learnerId,
  }) async {
    _isGeneratingQuestions = true;
    notifyListeners();
    try {
      final data = {
        'title': 'Homework for ${subject.toString().split('.').last}',
        'subject': subject.toString().split('.').last,
        'language': language.toString().split('.').last,
        'description': 'Auto-generated homework',
        'due_date': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'learner_id': learnerId,
        'status': 'pending',
        'score': null,
      };
      await SupabaseService.createHomework(data);
      final homeworks = await SupabaseService.getHomeworkList(learnerId);
      if (homeworks.isNotEmpty) {
        _currentHomework = Homework.fromJson(homeworks.last);
      }
      _isGeneratingQuestions = false;
      notifyListeners();
    } catch (e) {
      _isGeneratingQuestions = false;
      notifyListeners();
      rethrow;
    }
  }

  // Submit answer for a question (update in Supabase)
  Future<void> submitAnswer({
    required String homeworkId,
    required String questionId,
    required String answer,
  }) async {
    if (useSupabase) {
      print('[HomeworkService] Submitting answer to Supabase');
      await SupabaseService.submitAnswer(
        homeworkId: homeworkId,
        questionId: questionId,
        answer: answer,
      );
    }
    notifyListeners();
  }

  // Complete homework session (update status in Supabase)
  Future<void> completeHomework(String homeworkId) async {
    // Mock implementation: just notify listeners
    notifyListeners();
  }

  // Get homework list for a user
  Future<List<Homework>> getHomeworkList(String userId) async {
    final data = await SupabaseService.getHomeworkList(userId);
    return data.map((item) => Homework.fromJson(item)).toList();
  }

  // Fetch questions for a homework from Supabase
  Future<List<HomeworkQuestion>> getQuestions(Subject subject, Language language, {String? homeworkId}) async {
    if (useSupabase && homeworkId != null) {
      print('[HomeworkService] Fetching questions from Supabase');
      final data = await SupabaseService.getQuestions(homeworkId);
      return data.map((item) => HomeworkQuestion.fromJson(item)).toList();
    } else {
      return generateMockQuestions(subject, language);
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

