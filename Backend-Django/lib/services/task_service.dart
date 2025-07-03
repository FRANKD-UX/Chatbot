import 'package:redis/redis.dart';
import 'dart:isolate';
import 'dart:convert';
import '../config.dart';
import '../models/question.dart';
import 'homework_generator_service.dart';
import 'database_service.dart';

class TaskService {
  final DatabaseService _db;
  final HomeworkGeneratorService _aiService;
  
  TaskService(this._db)
    : _aiService = HomeworkGeneratorService(
        openaiApiKey: Config.openAiKey,
        claudeApiKey: Config.claudeApiKey
      );
  
  void startProcessingQueue() {
    Isolate.spawn(_processQueue, null);
  }
  
  Future<void> _processQueue(_) async {
    final conn = await RedisConnection().connect(Config.redisHost, 6379);
    while (true) {
      final task = await conn.lpop('question_queue');
      if (task != null) {
        final question = Question.fromJson(jsonDecode(task));
        await _aiService.processQuestion(question);
        await _db.updateQuestion(question); // Add this method to DatabaseService
      } else {
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }
  
  Future<void> enqueueQuestion(Question question) async {
    final conn = await RedisConnection().connect(Config.redisHost, 6379);
    await conn.lpush('question_queue', jsonEncode(question.toJson()));
  }
}
