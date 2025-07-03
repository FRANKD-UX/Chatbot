import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // USER AUTH
  static Future<AuthResponse> signUp({required String email, required String password}) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // USER PROFILE
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _client.from('users').select().eq('id', userId).single();
    return response;
  }

  static Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _client.from('users').update(data).eq('id', userId);
  }

  // HOMEWORK CRUD
  static Future<List<Map<String, dynamic>>> getHomeworkList(String userId) async {
    final response = await _client.from('homework').select().eq('learner_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createHomework(Map<String, dynamic> data) async {
    await _client.from('homework').insert(data);
  }

  static Future<void> updateHomework(String homeworkId, Map<String, dynamic> data) async {
    await _client.from('homework').update(data).eq('id', homeworkId);
  }

  // PAYMENTS CRUD
  static Future<List<Map<String, dynamic>>> getPayments(String userId) async {
    final response = await _client.from('payments').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createPayment(Map<String, dynamic> data) async {
    await _client.from('payments').insert(data);
  }

  // CHAT CRUD (if needed)
  static Future<List<Map<String, dynamic>>> getChatMessages(String sessionId) async {
    final response = await _client.from('chat_messages').select().eq('session_id', sessionId);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createChatMessage(Map<String, dynamic> data) async {
    await _client.from('chat_messages').insert(data);
  }

  // HOMEWORK QUESTIONS
  static Future<List<Map<String, dynamic>>> getQuestions(String homeworkId) async {
    print('[SupabaseService] Fetching questions for homeworkId: ' + homeworkId);
    final response = await _client
        .from('homework_questions')
        .select()
        .eq('homework_id', homeworkId);
    print('[SupabaseService] Questions response: ' + response.toString());
    return List<Map<String, dynamic>>.from(response);
  }

  // SUBMIT ANSWER
  static Future<void> submitAnswer({
    required String homeworkId,
    required String questionId,
    required String answer,
  }) async {
    print('[SupabaseService] Submitting answer for homeworkId: $homeworkId, questionId: $questionId, answer: $answer');
    await _client.from('homework_answers').upsert({
      'homework_id': homeworkId,
      'question_id': questionId,
      'answer': answer,
    });
    print('[SupabaseService] Answer submitted.');
  }
} 