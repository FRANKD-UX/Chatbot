// Replace with secure implementation
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthService {
  Future<String> generateToken(User user) async {
    final jwt = JWT(
      {'sub': user.id, 'email': user.email},
      issuer: 'homework_helper',
    );
    return jwt.sign(SecretKey(Config.jwtSecret));
  }

  int verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(Config.jwtSecret));
      return jwt.payload['sub'] as int;
    } catch (e) {
      throw AuthException('Invalid token');
    }
  }
  
  String _hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
}
