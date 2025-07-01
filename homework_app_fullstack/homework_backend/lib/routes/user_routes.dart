import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../models/user.dart';

class UserRoutes {
  final DatabaseService _db = DatabaseService.instance;
  static const _uuid = Uuid();

  Router get router {
    final router = Router();

    // Get user by ID
    router.get('/<id>', _getUser);
    
    // Create new user
    router.post('/', _createUser);
    
    // Get user by email
    router.get('/email/<email>', _getUserByEmail);

    return router;
  }

  Future<Response> _getUser(Request request) async {
    try {
      final id = request.params['id']!;
      final user = await _db.getUserById(id);

      if (user == null) {
        return Response.notFound(
          json.encode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Failed to get user: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _createUser(Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      
      final name = data['name'] as String?;
      final email = data['email'] as String?;
      final roleString = data['role'] as String?;

      if (name == null || email == null || roleString == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Missing required fields: name, email, role'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if user already exists
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        return Response(409,
          body: json.encode({'error': 'User with this email already exists'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Parse role
      UserRole role;
      try {
        role = UserRole.values.firstWhere(
          (r) => r.toString().split('.').last == roleString,
        );
      } catch (e) {
        return Response.badRequest(
          body: json.encode({'error': 'Invalid role. Must be "parent" or "learner"'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Create user
      final user = User(
        id: _uuid.v4(),
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _db.createUser(user);

      return Response(201,
        body: json.encode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Failed to create user: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getUserByEmail(Request request) async {
    try {
      final email = Uri.decodeComponent(request.params['email']!);
      final user = await _db.getUserByEmail(email);

      if (user == null) {
        return Response.notFound(
          json.encode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': 'Failed to get user by email: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

