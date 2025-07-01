import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/homework_service.dart';
import '../providers/app_state.dart';
import '../models/homework.dart';
import 'homework_session_screen.dart';

class HomeworkBotInteractionScreen extends StatelessWidget {
  final Subject subject;
  final Language language;

  const HomeworkBotInteractionScreen({
    super.key,
    required this.subject,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Mode'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Bot introduction text
              const Text(
                'Hi There! I\'m Your Bot from Homework Bot.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Click on the Image Button of the Bot to proceed with the Homework that you have chosen.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Bot image button
              GestureDetector(
                onTap: () => _startHomeworkSession(context),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_toy,
                        size: 80,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Homework Bot',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Subject and Language info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getSubjectIcon(subject),
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Subject: ${_getSubjectDisplayName(subject)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.language,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Language: ${_getLanguageDisplayName(language)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Tap instruction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.orange.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap the bot to start your homework session!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubjectDisplayName(Subject subject) {
    switch (subject) {
      case Subject.mathematics:
        return 'Mathematics';
      case Subject.science:
        return 'Science';
      case Subject.computer:
        return 'Computer';
    }
  }

  String _getLanguageDisplayName(Language language) {
    switch (language) {
      case Language.swahili:
        return 'Swahili';
      case Language.english:
        return 'English';
      case Language.spanish:
        return 'Spanish';
    }
  }

  IconData _getSubjectIcon(Subject subject) {
    switch (subject) {
      case Subject.mathematics:
        return Icons.calculate;
      case Subject.science:
        return Icons.science;
      case Subject.computer:
        return Icons.computer;
    }
  }

  void _startHomeworkSession(BuildContext context) async {
    final homeworkService = Provider.of<HomeworkService>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create mock homework for demo purposes
      final homework = homeworkService.createMockHomework(
        subject: subject,
        language: language,
        learnerId: appState.currentUser?.id ?? 'learner_1',
      );

      homeworkService.setCurrentHomework(homework);

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to homework session
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeworkSessionScreen(),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting homework session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

