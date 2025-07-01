import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class QuestionCard extends StatefulWidget {
  final ChatMessage message;
  final Function(String questionId, String answer) onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.message,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selectedAnswer;
  bool _isAnswered = false;

  @override
  Widget build(BuildContext context) {
    final metadata = widget.message.metadata;
    if (metadata == null) return const SizedBox.shrink();

    final questionId = metadata['questionId'] as String?;
    final options = metadata['options'] as List<dynamic>?;
    final questionIndex = metadata['questionIndex'] as int?;

    if (questionId == null || options == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.smart_toy,
              size: 20,
              color: Colors.blue.shade600,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Question card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Text(
                    widget.message.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Answer options
                  ...options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value as String;
                    final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: _isAnswered ? null : () => _selectAnswer(questionId, option),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getOptionColor(option),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getOptionBorderColor(option),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _getOptionLabelColor(option),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    optionLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _getOptionLabelTextColor(option),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _getOptionTextColor(option),
                                  ),
                                ),
                              ),
                              if (_selectedAnswer == option)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 8),
                  
                  // Timestamp
                  Text(
                    _formatTime(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String questionId, String answer) {
    if (_isAnswered) return;
    
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
    });
    
    // Call the callback after a short delay to show the selection
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAnswerSelected(questionId, answer);
    });
  }

  Color _getOptionColor(String option) {
    if (_selectedAnswer == option) {
      return Colors.green.shade50;
    }
    return Colors.grey.shade50;
  }

  Color _getOptionBorderColor(String option) {
    if (_selectedAnswer == option) {
      return Colors.green.shade300;
    }
    return Colors.grey.shade300;
  }

  Color _getOptionLabelColor(String option) {
    if (_selectedAnswer == option) {
      return Colors.green.shade600;
    }
    return Colors.grey.shade400;
  }

  Color _getOptionLabelTextColor(String option) {
    if (_selectedAnswer == option) {
      return Colors.white;
    }
    return Colors.white;
  }

  Color _getOptionTextColor(String option) {
    if (_selectedAnswer == option) {
      return Colors.green.shade700;
    }
    return Colors.black87;
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

