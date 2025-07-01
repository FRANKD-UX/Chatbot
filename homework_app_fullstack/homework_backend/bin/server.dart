import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../lib/routes/homework_routes.dart';
import '../lib/routes/user_routes.dart';
import '../lib/database/database.dart';

void main(List<String> args) async {
  // Initialize database
  final db = DatabaseService.instance;
  print('Database initialized');

  // Create routes
  final app = Router();
  
  // Health check
  app.get('/', (Request request) {
    return Response.ok('Homework App API is running!');
  });

  app.get('/health', (Request request) {
    return Response.ok('OK');
  });

  // API routes
  app.mount('/api/homework', HomeworkRoutes().router);
  app.mount('/api/users', UserRoutes().router);

  // CORS middleware
  final handler = Pipeline()
      .addMiddleware(corsHeaders(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token, Authorization',
      }))
      .addMiddleware(logRequests())
      .addHandler(app);

  // Start server
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '3000');
  final server = await serve(handler, ip, port);
  
  print('Server listening on port ${server.port}');
  print('API endpoints:');
  print('  GET  /health - Health check');
  print('  POST /api/homework/generate - Generate homework');
  print('  GET  /api/homework/<id> - Get homework by ID');
  print('  GET  /api/homework/user/<userId> - Get user homework');
  print('  POST /api/homework/<id>/answer - Submit answer');
  print('  POST /api/homework/<id>/complete - Complete homework');
  print('  GET  /api/users/<id> - Get user by ID');
  print('  POST /api/users - Create user');
  print('  GET  /api/users/email/<email> - Get user by email');
}

