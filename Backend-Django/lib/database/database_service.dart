import 'package:postgres/postgres.dart';

class DatabaseService {
  late PostgreSQLConnection _connection;

  Future<void> connect() async {
    _connection = PostgreSQLConnection(
      Config.dbHost,
      Config.dbPort,
      Config.dbName,
      username: Config.dbUser,
      password: Config.dbPassword,
      useSSL: true,
    );
    await _connection.open();
  }

  Future<User> getUserById(int id) async {
    final result = await _connection.query(
      'SELECT * FROM users WHERE id = @id',
      substitutionValues: {'id': id}
    );
    return User.fromJson(result.first.toColumnMap());
  }
  
  // Update all methods to use _connection
}

