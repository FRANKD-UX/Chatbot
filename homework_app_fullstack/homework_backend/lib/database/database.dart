import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import '../models/user.dart';
import '../models/homework.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Database get database {
    _database ??= _initDatabase();
    return _database!;
  }

  Database _initDatabase() {
    final db = sqlite3.open('homework_app.db');
    _createTables(db);
    _insertSampleData(db);
    return db;
  }

  void _createTables(Database db) {
    // Users table
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Homework table
    db.execute('''
      CREATE TABLE IF NOT EXISTS homework (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        language TEXT NOT NULL,
        description TEXT NOT NULL,
        due_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        learner_id TEXT NOT NULL,
        status TEXT NOT NULL,
        score REAL,
        FOREIGN KEY (learner_id) REFERENCES users (id)
      )
    ''');

    // Questions table
    db.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        id TEXT PRIMARY KEY,
        homework_id TEXT NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        answer TEXT,
        is_correct INTEGER DEFAULT 0,
        FOREIGN KEY (homework_id) REFERENCES homework (id)
      )
    ''');

    // Payments table
    db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        status TEXT NOT NULL,
        method TEXT NOT NULL,
        created_at TEXT NOT NULL,
        paid_at TEXT,
        transaction_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  void _insertSampleData(Database db) {
    // Check if sample data already exists
    final result = db.select('SELECT COUNT(*) as count FROM users');
    if (result.first['count'] > 0) return;

    // Insert sample users
    db.execute('''
      INSERT INTO users (id, name, email, role, created_at) VALUES
      ('parent_1', 'Parent User', 'parent@example.com', 'parent', '${DateTime.now().toIso8601String()}'),
      ('learner_1', 'Little Superstar', 'learner@example.com', 'learner', '${DateTime.now().toIso8601String()}')
    ''');

    print('Sample data inserted successfully');
  }

  // User operations
  Future<User?> getUserById(String id) async {
    final result = database.select('SELECT * FROM users WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final result = database.select('SELECT * FROM users WHERE email = ?', [email]);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<String> createUser(User user) async {
    database.execute(
      'INSERT INTO users (id, name, email, role, created_at) VALUES (?, ?, ?, ?, ?)',
      [user.id, user.name, user.email, user.role.toString().split('.').last, user.createdAt.toIso8601String()],
    );
    return user.id;
  }

  // Homework operations
  Future<List<Homework>> getHomeworkByLearner(String learnerId) async {
    final result = database.select('SELECT * FROM homework WHERE learner_id = ? ORDER BY created_at DESC', [learnerId]);
    final homeworks = <Homework>[];
    
    for (final row in result) {
      final homework = Homework.fromMap(row);
      final questions = await getQuestionsByHomework(homework.id);
      homeworks.add(Homework(
        id: homework.id,
        title: homework.title,
        subject: homework.subject,
        language: homework.language,
        description: homework.description,
        dueDate: homework.dueDate,
        createdAt: homework.createdAt,
        learnerId: homework.learnerId,
        status: homework.status,
        score: homework.score,
        questions: questions,
      ));
    }
    
    return homeworks;
  }

  Future<Homework?> getHomeworkById(String id) async {
    final result = database.select('SELECT * FROM homework WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    
    final homework = Homework.fromMap(result.first);
    final questions = await getQuestionsByHomework(id);
    
    return Homework(
      id: homework.id,
      title: homework.title,
      subject: homework.subject,
      language: homework.language,
      description: homework.description,
      dueDate: homework.dueDate,
      createdAt: homework.createdAt,
      learnerId: homework.learnerId,
      status: homework.status,
      score: homework.score,
      questions: questions,
    );
  }

  Future<String> createHomework(Homework homework) async {
    database.execute(
      'INSERT INTO homework (id, title, subject, language, description, due_date, created_at, learner_id, status, score) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        homework.id,
        homework.title,
        homework.subject,
        homework.language,
        homework.description,
        homework.dueDate.toIso8601String(),
        homework.createdAt.toIso8601String(),
        homework.learnerId,
        homework.status.toString().split('.').last,
        homework.score,
      ],
    );

    // Insert questions
    for (final question in homework.questions) {
      await createQuestion(question);
    }

    return homework.id;
  }

  Future<void> updateHomework(Homework homework) async {
    database.execute(
      'UPDATE homework SET title = ?, subject = ?, language = ?, description = ?, due_date = ?, status = ?, score = ? WHERE id = ?',
      [
        homework.title,
        homework.subject,
        homework.language,
        homework.description,
        homework.dueDate.toIso8601String(),
        homework.status.toString().split('.').last,
        homework.score,
        homework.id,
      ],
    );
  }

  // Question operations
  Future<List<HomeworkQuestion>> getQuestionsByHomework(String homeworkId) async {
    final result = database.select('SELECT * FROM questions WHERE homework_id = ?', [homeworkId]);
    return result.map((row) => HomeworkQuestion.fromMap(row)).toList();
  }

  Future<HomeworkQuestion?> getQuestionById(String id) async {
    final result = database.select('SELECT * FROM questions WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    return HomeworkQuestion.fromMap(result.first);
  }

  Future<String> createQuestion(HomeworkQuestion question) async {
    database.execute(
      'INSERT INTO questions (id, homework_id, question, options, correct_answer, answer, is_correct) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        question.id,
        question.homeworkId,
        question.question,
        question.options.join('|'),
        question.correctAnswer,
        question.answer,
        question.isCorrect ? 1 : 0,
      ],
    );
    return question.id;
  }

  Future<void> updateQuestion(HomeworkQuestion question) async {
    database.execute(
      'UPDATE questions SET answer = ?, is_correct = ? WHERE id = ?',
      [question.answer, question.isCorrect ? 1 : 0, question.id],
    );
  }

  void close() {
    _database?.dispose();
    _database = null;
  }
}

