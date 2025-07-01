import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user.dart';
import 'parent_home_screen.dart';
import 'learner_home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.blue.shade600,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Welcome text
              const Text(
                'Hi there! Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Need some help?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Parent Mode Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _navigateToParentMode(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Parent Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Learner Mode Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _navigateToLearnerMode(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Learner Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToParentMode(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Set mock parent user
    final parentUser = User(
      id: 'parent_1',
      name: 'Parent User',
      email: 'parent@example.com',
      role: UserRole.parent,
      createdAt: DateTime.now(),
    );
    
    appState.setCurrentUser(parentUser);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParentHomeScreen(),
      ),
    );
  }

  void _navigateToLearnerMode(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Set mock learner user
    final learnerUser = User(
      id: 'learner_1',
      name: 'Little Superstar',
      email: 'learner@example.com',
      role: UserRole.learner,
      createdAt: DateTime.now(),
    );
    
    appState.setCurrentUser(learnerUser);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LearnerHomeScreen(),
      ),
    );
  }
}

