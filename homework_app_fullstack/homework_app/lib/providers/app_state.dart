import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/homework.dart';
import '../models/payment.dart';
import '../models/chat_message.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  UserRole? _selectedMode;
  List<Homework> _homeworks = [];
  List<Payment> _payments = [];
  List<ChatMessage> _chatMessages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  UserRole? get selectedMode => _selectedMode;
  List<Homework> get homeworks => _homeworks;
  List<Payment> get payments => _payments;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // User management
  void setCurrentUser(User user) {
    _currentUser = user;
    _selectedMode = user.role;
    notifyListeners();
  }

  void setSelectedMode(UserRole mode) {
    _selectedMode = mode;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _selectedMode = null;
    _homeworks.clear();
    _payments.clear();
    _chatMessages.clear();
    notifyListeners();
  }

  // Loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error handling
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Homework management
  void setHomeworks(List<Homework> homeworks) {
    _homeworks = homeworks;
    notifyListeners();
  }

  void addHomework(Homework homework) {
    _homeworks.add(homework);
    notifyListeners();
  }

  void updateHomework(Homework updatedHomework) {
    final index = _homeworks.indexWhere((h) => h.id == updatedHomework.id);
    if (index != -1) {
      _homeworks[index] = updatedHomework;
      notifyListeners();
    }
  }

  void removeHomework(String homeworkId) {
    _homeworks.removeWhere((h) => h.id == homeworkId);
    notifyListeners();
  }

  // Payment management
  void setPayments(List<Payment> payments) {
    _payments = payments;
    notifyListeners();
  }

  void addPayment(Payment payment) {
    _payments.add(payment);
    notifyListeners();
  }

  void updatePayment(Payment updatedPayment) {
    final index = _payments.indexWhere((p) => p.id == updatedPayment.id);
    if (index != -1) {
      _payments[index] = updatedPayment;
      notifyListeners();
    }
  }

  // Chat management
  void setChatMessages(List<ChatMessage> messages) {
    _chatMessages = messages;
    notifyListeners();
  }

  void addChatMessage(ChatMessage message) {
    _chatMessages.add(message);
    notifyListeners();
  }

  void clearChatMessages() {
    _chatMessages.clear();
    notifyListeners();
  }

  // Homework filtering
  List<Homework> getHomeworksByStatus(HomeworkStatus status) {
    return _homeworks.where((h) => h.status == status).toList();
  }

  List<Homework> getHomeworksByLearner(String learnerId) {
    return _homeworks.where((h) => h.learnerId == learnerId).toList();
  }

  // Payment filtering
  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _payments.where((p) => p.status == status).toList();
  }

  List<Payment> getPaymentsByUser(String userId) {
    return _payments.where((p) => p.userId == userId).toList();
  }
}

