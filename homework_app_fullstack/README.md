# Homework App - Full Stack Flutter & Dart Application

A comprehensive homework management application built with Flutter for the frontend and Dart (Shelf) for the backend, featuring parent and learner modes with an interactive chatbot interface.

## 🚀 Features

### Parent Mode
- **Manage Payments**: View subscription details, payment history, and manage payment methods
- **Homework Bot**: Monitor child's homework progress, view completed assignments, and track performance
- **Progress Tracking**: Real-time insights into learning progress with visual charts and statistics

### Learner Mode
- **Subject Selection**: Choose from Mathematics, Science, and Computer subjects
- **Language Support**: Available in English, Spanish, and Swahili
- **Interactive Chatbot**: AI-powered homework assistance with step-by-step guidance
- **Question-Answer Interface**: Multiple choice questions with immediate feedback
- **Progress Tracking**: Visual progress indicators and score tracking

## 🏗️ Architecture

### Frontend (Flutter)
- **State Management**: Provider pattern for reactive state management
- **Navigation**: Declarative routing between screens
- **UI Components**: Custom widgets for chat bubbles, question cards, and progress indicators
- **Responsive Design**: Optimized for both mobile and web platforms

### Backend (Dart + Shelf)
- **RESTful API**: Clean API endpoints for homework and user management
- **Database**: SQLite for local data persistence
- **CORS Support**: Cross-origin resource sharing for web compatibility
- **Question Generation**: Dynamic homework question generation with multi-language support

## 📁 Project Structure

```
homework_app/                 # Flutter Frontend
├── lib/
│   ├── models/              # Data models (User, Homework, Payment, ChatMessage)
│   ├── providers/           # State management (AppState, HomeworkService)
│   ├── screens/             # UI screens (Welcome, Parent/Learner modes)
│   ├── widgets/             # Reusable UI components
│   └── main.dart           # App entry point
├── test/                   # Unit and widget tests
└── pubspec.yaml           # Dependencies

homework_backend/            # Dart Backend
├── lib/
│   ├── models/             # Backend data models
│   ├── routes/             # API route handlers
│   ├── services/           # Business logic (HomeworkGenerator)
│   └── database/           # Database service (SQLite)
├── bin/
│   └── server.dart         # Server entry point
└── pubspec.yaml           # Backend dependencies
```

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK (3.19.6 or later)
- Dart SDK (included with Flutter)
- SQLite3 development libraries

### Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd homework_backend
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

3. Install SQLite3 (Ubuntu/Debian):
   ```bash
   sudo apt-get install -y libsqlite3-dev sqlite3
   ```

4. Start the backend server:
   ```bash
   dart run bin/server.dart
   ```

The backend will be available at `http://localhost:3000`

### Frontend Setup
1. Navigate to the Flutter app directory:
   ```bash
   cd homework_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # For web
   flutter run -d web-server --web-port 8080
   
   # For mobile (with device/emulator connected)
   flutter run
   ```

## 🔌 API Endpoints

### Homework Management
- `POST /api/homework/generate` - Generate new homework
- `GET /api/homework/<id>` - Get homework by ID
- `GET /api/homework/user/<userId>` - Get user's homework list
- `POST /api/homework/<id>/answer` - Submit answer for question
- `POST /api/homework/<id>/complete` - Complete homework session

### User Management
- `GET /api/users/<id>` - Get user by ID
- `POST /api/users` - Create new user
- `GET /api/users/email/<email>` - Get user by email

### Health Check
- `GET /health` - API health status

## 🎯 Usage Examples

### Generate Homework (API)
```bash
curl -X POST http://localhost:3000/api/homework/generate \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "mathematics",
    "language": "english", 
    "learnerId": "learner_1"
  }'
```

### Submit Answer (API)
```bash
curl -X POST http://localhost:3000/api/homework/{homework_id}/answer \
  -H "Content-Type: application/json" \
  -d '{
    "questionId": "question_id",
    "answer": "42"
  }'
```

## 🧪 Testing

### Backend Testing
```bash
cd homework_backend

# Test API health
curl http://localhost:3000/health

# Test homework generation
curl -X POST http://localhost:3000/api/homework/generate \
  -H "Content-Type: application/json" \
  -d '{"subject": "mathematics", "language": "english", "learnerId": "learner_1"}'
```

### Frontend Testing
```bash
cd homework_app

# Run Flutter tests
flutter test

# Run Flutter analyzer
flutter analyze

# Build for web
flutter build web
```

## 🌐 Deployment

### Backend Deployment
The Dart backend can be deployed to any cloud platform that supports Dart applications:

1. **Docker**: Create a Dockerfile for containerized deployment
2. **Cloud Run**: Deploy to Google Cloud Run
3. **Heroku**: Deploy using Heroku buildpacks
4. **VPS**: Deploy to any virtual private server

### Frontend Deployment
The Flutter web app can be deployed to:

1. **Firebase Hosting**: `flutter build web && firebase deploy`
2. **Netlify**: Deploy the `build/web` directory
3. **Vercel**: Connect GitHub repository for automatic deployments
4. **GitHub Pages**: Deploy static web build

## 🔧 Configuration

### Environment Variables
- `PORT`: Backend server port (default: 3000)
- `DATABASE_URL`: SQLite database path (default: homework_app.db)

### Flutter Configuration
Update `lib/providers/homework_service.dart` to change the backend URL:
```dart
static const String baseUrl = 'http://your-backend-url/api';
```

## 🎨 UI/UX Features

### Design System
- **Material Design 3**: Modern Flutter UI components
- **Color Scheme**: Blue for parents, Green for learners
- **Typography**: Roboto font family with consistent sizing
- **Responsive Layout**: Adapts to different screen sizes

### Interactive Elements
- **Chat Interface**: Real-time messaging with bot responses
- **Progress Indicators**: Visual feedback for homework completion
- **Card-based Layout**: Clean, organized information display
- **Smooth Animations**: Engaging user interactions

## 🔒 Security Considerations

- **Input Validation**: All API inputs are validated
- **CORS Configuration**: Properly configured for web deployment
- **Data Sanitization**: User inputs are sanitized before database storage
- **Error Handling**: Comprehensive error handling throughout the application

## 🚧 Known Issues & Limitations

1. **Flutter Web Build**: Some color shade properties may need adjustment for web compilation
2. **Real-time Features**: Currently uses mock data; real-time chat requires WebSocket implementation
3. **Authentication**: Basic user management; production apps should implement proper authentication
4. **Offline Support**: Currently requires internet connection; offline mode can be added

## 🔮 Future Enhancements

- **Real-time Chat**: WebSocket integration for live chat
- **Push Notifications**: Homework reminders and progress updates
- **Advanced Analytics**: Detailed learning analytics and insights
- **Multi-language Support**: Extended language options
- **Voice Integration**: Speech-to-text for question answering
- **Gamification**: Points, badges, and achievement system

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation for common solutions
- Review the API endpoints for integration help

---

**Built with ❤️ using Flutter & Dart**

