import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/homework_service.dart';
import '../models/homework.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/question_card.dart';

class HomeworkSessionScreen extends StatefulWidget {
  const HomeworkSessionScreen({super.key});

  @override
  State<HomeworkSessionScreen> createState() => _HomeworkSessionScreenState();
}

class _HomeworkSessionScreenState extends State<HomeworkSessionScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentQuestionIndex = 0;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    final homeworkService = Provider.of<HomeworkService>(context, listen: false);
    final homework = homeworkService.currentHomework;
    
    if (homework != null) {
      _messages = [
        ChatMessage.bot(
          'Welcome to your ${homework.subject} homework session! I\'ll help you with ${homework.questions.length} questions. Let\'s start with the first one:',
          homeworkId: homework.id,
        ),
      ];
      
      if (homework.questions.isNotEmpty) {
        _showCurrentQuestion();
      }
    }
  }

  void _showCurrentQuestion() {
    final homeworkService = Provider.of<HomeworkService>(context, listen: false);
    final homework = homeworkService.currentHomework;
    
    if (homework != null && _currentQuestionIndex < homework.questions.length) {
      final question = homework.questions[_currentQuestionIndex];
      setState(() {
        _messages.add(
          ChatMessage.bot(
            'Question ${_currentQuestionIndex + 1}: ${question.question}',
            homeworkId: homework.id,
            metadata: {
              'questionId': question.id,
              'options': question.options,
              'questionIndex': _currentQuestionIndex,
            },
          ),
        );
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<HomeworkService>(
          builder: (context, homeworkService, child) {
            final homework = homeworkService.currentHomework;
            return Text(homework?.title ?? 'Homework Session');
          },
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<HomeworkService>(
            builder: (context, homeworkService, child) {
              final homework = homeworkService.currentHomework;
              if (homework != null) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: Text(
                      '${_currentQuestionIndex + 1}/${homework.questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Progress indicator
          Consumer<HomeworkService>(
            builder: (context, homeworkService, child) {
              final homework = homeworkService.currentHomework;
              if (homework != null && homework.questions.isNotEmpty) {
                final progress = (_currentQuestionIndex + 1) / homework.questions.length;
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                    minHeight: 6,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                
                if (message.type == MessageType.bot && message.metadata != null) {
                  // This is a question message
                  return QuestionCard(
                    message: message,
                    onAnswerSelected: _handleAnswerSelection,
                  );
                } else {
                  // Regular chat message
                  return ChatBubble(message: message);
                }
              },
            ),
          ),
          
          // Input area (disabled during questions)
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final homeworkService = Provider.of<HomeworkService>(context);
    final homework = homeworkService.currentHomework;
    
    // Disable input during question answering
    final isQuestionActive = homework != null && 
        _currentQuestionIndex < homework.questions.length &&
        _messages.isNotEmpty &&
        _messages.last.type == MessageType.bot &&
        _messages.last.metadata != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !isQuestionActive,
              decoration: InputDecoration(
                hintText: isQuestionActive 
                    ? 'Please select an answer above'
                    : 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.green.shade600),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: isQuestionActive ? null : _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isQuestionActive ? null : () => _sendMessage(_messageController.text),
            icon: Icon(
              Icons.send,
              color: isQuestionActive ? Colors.grey : Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAnswerSelection(String questionId, String answer) async {
    final homeworkService = Provider.of<HomeworkService>(context, listen: false);
    final homework = homeworkService.currentHomework;
    
    if (homework == null) return;

    // Add user's answer to chat
    setState(() {
      _messages.add(ChatMessage.user('My answer: $answer'));
    });

    try {
      // Simulate answer checking (in real app, this would call the backend)
      final question = homework.questions.firstWhere((q) => q.id == questionId);
      final isCorrect = question.correctAnswer == answer;
      
      // Add bot response
      setState(() {
        _messages.add(ChatMessage.bot(
          isCorrect 
              ? '✅ Correct! Well done!' 
              : '❌ Not quite right. The correct answer is: ${question.correctAnswer}',
        ));
      });

      // Move to next question or complete session
      _currentQuestionIndex++;
      
      if (_currentQuestionIndex < homework.questions.length) {
        // Show next question after a delay
        await Future.delayed(const Duration(seconds: 1));
        _showCurrentQuestion();
      } else {
        // Session complete
        await Future.delayed(const Duration(seconds: 1));
        _completeSession();
      }
      
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing answer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage.user(text));
      _messages.add(ChatMessage.bot('Thanks for your message! Please continue with the questions above.'));
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _completeSession() {
    final homeworkService = Provider.of<HomeworkService>(context, listen: false);
    final homework = homeworkService.currentHomework;
    
    if (homework != null) {
      final correctAnswers = homework.questions.where((q) => q.answer == q.correctAnswer).length;
      final totalQuestions = homework.questions.length;
      final score = (correctAnswers / totalQuestions) * 100;
      
      setState(() {
        _messages.add(ChatMessage.bot(
          '🎉 Congratulations! You\'ve completed your homework session!\\n\\n'
          'Your score: $correctAnswers/$totalQuestions (${score.toStringAsFixed(1)}%)\\n\\n'
          'Great job! Keep up the excellent work!',
        ));
      });
      
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

