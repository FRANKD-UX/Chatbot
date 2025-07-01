import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/database.dart';
import '../services/homework_generator.dart';
import '../models/homework.dart';

class HomeworkRoutes {
  final DatabaseService _db = DatabaseService.instance;

  Router get router {
    final router = Router();

    // Generate new homework
    router.post('/generate', _generateHomework);
    
    // Get homework by ID
    router.get('/<id>', _getHomework);
    
    // Get homework list for a user
    router.get('/user/<userId>', _getUserHomework);
    
    // Submit answer for a question
    router.post('/<homeworkId>/answer', _submitAnswer);
    
    // Complete homework session
    router.post('/<homeworkId>/complete', _completeHomework);

    return router;
  }

  Future<Response> _generateHomework(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      
      final subject = data['subject'] as String?;
      final language = data['language'] as String?;
      final learnerId = data['learnerId'] as String?;

      if (subject == null || language == null || learnerId == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Missing required fields: subject, language, learnerId'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Generate homework
      final homework = HomeworkGenerator.generateHomework(
        subject: subject,
        language: language,
        learnerId: learnerId,
      );

      // Save to database
      await _db.createHomework(homework);

      return Response.ok(
        json.encode(homework.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Failed to generate homework: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getHomework(Request request) async {
    try {
      final id = request.params['id']!;
      final homework = await _db.getHomeworkById(id);

      if (homework == null) {
        return Response.notFound(
          json.encode({'error': 'Homework not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode(homework.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Failed to get homework: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getUserHomework(Request request) async {
    try {
      final userId = request.params['userId']!;
      final homeworks = await _db.getHomeworkByLearner(userId);

      return Response.ok(
        json.encode(homeworks.map((h) => h.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Failed to get user homework: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _submitAnswer(Request request) async {
    try {
      final homeworkId = request.params['homeworkId']!;
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      
      final questionId = data['questionId'] as String?;
      final answer = data['answer'] as String?;

      if (questionId == null || answer == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Missing required fields: questionId, answer'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Get the question
      final question = await _db.getQuestionById(questionId);
      if (question == null) {
        return Response.notFound(
          json.encode({'error': 'Question not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if answer is correct
      final isCorrect = question.correctAnswer == answer;

      // Update question with answer
      final updatedQuestion = question.copyWith(
        answer: answer,
        isCorrect: isCorrect,
      );
      await _db.updateQuestion(updatedQuestion);

      return Response.ok(
        json.encode({
          'isCorrect': isCorrect,
          'correctAnswer': question.correctAnswer,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Failed to submit answer: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _completeHomework(Request request) async {
    try {
      final homeworkId = request.params['homeworkId']!;
      final homework = await _db.getHomeworkById(homeworkId);

      if (homework == null) {
        return Response.notFound(
          json.encode({'error': 'Homework not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Calculate score
      final totalQuestions = homework.questions.length;
      final correctAnswers = homework.questions.where((q) => q.isCorrect).length;
      final score = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

      // Update homework status and score
      final updatedHomework = Homework(
        id: homework.id,
        title: homework.title,
        subject: homework.subject,
        language: homework.language,
        description: homework.description,
        dueDate: homework.dueDate,
        createdAt: homework.createdAt,
        learnerId: homework.learnerId,
        status: HomeworkStatus.completed,
        score: score,
        questions: homework.questions,
      );

      await _db.updateHomework(updatedHomework);

      return Response.ok(
        json.encode({
          'score': score,
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Failed to complete homework: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

