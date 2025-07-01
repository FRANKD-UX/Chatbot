import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/homework_service.dart';
import '../models/homework.dart';
import 'homework_bot_interaction_screen.dart';

class HomeworkSelectionScreen extends StatefulWidget {
  const HomeworkSelectionScreen({super.key});

  @override
  State<HomeworkSelectionScreen> createState() => _HomeworkSelectionScreenState();
}

class _HomeworkSelectionScreenState extends State<HomeworkSelectionScreen> {
  Subject? _selectedSubject;
  Language? _selectedLanguage;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Let\'s Do Your Homework',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Subject Selection
              const Text(
                'Choose the Subject',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildSubjectSelection(),
              
              const SizedBox(height: 32),
              
              // Language Selection
              const Text(
                'Choose the Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildLanguageSelection(),
              
              const Spacer(),
              
              // Proceed Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canProceed() ? () => _proceedToHomework(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text(
                    'Proceed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSelection() {
    return Column(
      children: Subject.values.map((subject) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _selectedSubject == subject 
                  ? Colors.green.shade600 
                  : Colors.grey.shade300,
              width: _selectedSubject == subject ? 2 : 1,
            ),
          ),
          child: RadioListTile<Subject>(
            title: Row(
              children: [
                Icon(
                  _getSubjectIcon(subject),
                  color: _selectedSubject == subject 
                      ? Colors.green.shade600 
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  _getSubjectDisplayName(subject),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            value: subject,
            groupValue: _selectedSubject,
            activeColor: Colors.green.shade600,
            onChanged: (Subject? value) {
              setState(() {
                _selectedSubject = value;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSelection() {
    return Column(
      children: Language.values.map((language) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _selectedLanguage == language 
                  ? Colors.green.shade600 
                  : Colors.grey.shade300,
              width: _selectedLanguage == language ? 2 : 1,
            ),
          ),
          child: RadioListTile<Language>(
            title: Row(
              children: [
                Icon(
                  Icons.language,
                  color: _selectedLanguage == language 
                      ? Colors.green.shade600 
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  _getLanguageDisplayName(language),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            value: language,
            groupValue: _selectedLanguage,
            activeColor: Colors.green.shade600,
            onChanged: (Language? value) {
              setState(() {
                _selectedLanguage = value;
              });
            },
          ),
        );
      }).toList(),
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

  bool _canProceed() {
    return _selectedSubject != null && _selectedLanguage != null;
  }

  void _proceedToHomework(BuildContext context) {
    if (!_canProceed()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both subject and language'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final homeworkService = Provider.of<HomeworkService>(context, listen: false);
    homeworkService.setSelectedSubject(_selectedSubject!);
    homeworkService.setSelectedLanguage(_selectedLanguage!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeworkBotInteractionScreen(
          subject: _selectedSubject!,
          language: _selectedLanguage!,
        ),
      ),
    );
  }
}

