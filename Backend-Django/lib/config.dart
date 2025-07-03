import 'package:dotenv/dotenv.dart';
import 'package:envy/envy.dart';

class Config {
  static final DotEnv _env = DotEnv(includePlatformEnvironment: true);
  static final Envy _envy = Envy.loadSync(path: 'config.yaml');
  
  static String get jwtSecret => _get('JWT_SECRET');
  static String get dbHost => _get('DB_HOST');
  static int get dbPort => int.parse(_get('DB_PORT'));
  static String get dbName => _get('DB_NAME');
  static String get dbUser => _get('DB_USER');
  static String get dbPassword => _get('DB_PASSWORD');
  static String get redisHost => _get('REDIS_HOST');
  
  static void init() {
    _env.load();
  }
  
  static String _get(String key) {
    return _env[key] ?? _envy.get(key) ?? '';
  }
}
