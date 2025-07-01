import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/homework.dart';

class ParentHomeworkBotScreen extends StatefulWidget {
  const ParentHomeworkBotScreen({super.key});

  @override
  State<ParentHomeworkBotScreen> createState() => _ParentHomeworkBotScreenState();
}

class _ParentHomeworkBotScreenState extends State<ParentHomeworkBotScreen> {
  List<Homework> _mockHomeworks = [];

  @override
  void initState() {
    super.initState();
    _loadMockHomeworks();
  }

  void _loadMockHomeworks() {
    _mockHomeworks = [
      Homework(
        id: 'hw_1',
        title: 'Mathematics Homework',
        subject: 'mathematics',
        language: 'english',
        description: 'Basic arithmetic and problem solving',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        learnerId: 'learner_1',
        status: HomeworkStatus.completed,
        score: 85.0,
        questions: _generateMockQuestions('mathematics', 5),
      ),
      Homework(
        id: 'hw_2',
        title: 'Science Homework',
        subject: 'science',
        language: 'english',
        description: 'Basic chemistry and biology concepts',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        learnerId: 'learner_1',
        status: HomeworkStatus.inProgress,
        questions: _generateMockQuestions('science', 4),
      ),
      Homework(
        id: 'hw_3',
        title: 'Computer Homework',
        subject: 'computer',
        language: 'english',
        description: 'Introduction to programming concepts',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        learnerId: 'learner_1',
        status: HomeworkStatus.pending,
        questions: _generateMockQuestions('computer', 3),
      ),
    ];
  }

  List<HomeworkQuestion> _generateMockQuestions(String subject, int count) {
    return List.generate(count, (index) {
      return HomeworkQuestion(
        id: 'q_${subject}_$index',
        question: 'Sample question ${index + 1} for $subject',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 'Option A',
        answer: index < count - 1 ? 'Option A' : null, // Some answered, some not
        isCorrect: index < count - 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Bot (Parent)'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Welcome message
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Welcome Parent!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Here you can manage your child\'s homework and monitor their progress.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    _mockHomeworks.where((h) => h.status == HomeworkStatus.completed).length.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'In Progress',
                    _mockHomeworks.where((h) => h.status == HomeworkStatus.inProgress).length.toString(),
                    Colors.blue,
                    Icons.pending,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    _mockHomeworks.where((h) => h.status == HomeworkStatus.pending).length.toString(),
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Homework list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Homework',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Homework list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockHomeworks.length,
              itemBuilder: (context, index) {
                final homework = _mockHomeworks[index];
                return _buildHomeworkCard(homework);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(Homework homework) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSubjectColor(homework.subject).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSubjectIcon(homework.subject),
                    color: _getSubjectColor(homework.subject),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homework.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        homework.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(homework.status),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${(homework.progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: homework.progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getSubjectColor(homework.subject),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Additional info
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(homework.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                if (homework.score != null) ...[
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.yellow.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Score: ${homework.score!.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(HomeworkStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case HomeworkStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case HomeworkStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case HomeworkStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case HomeworkStatus.reviewed:
        color = Colors.purple;
        text = 'Reviewed';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(color.red, color.green, color.blue, 0.8),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'mathematics':
        return Colors.blue;
      case 'science':
        return Colors.green;
      case 'computer':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'computer':
        return Icons.computer;
      default:
        return Icons.book;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

