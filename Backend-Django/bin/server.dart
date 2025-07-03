// Add these imports
import 'package:shelf_helmet/shelf_helmet.dart';
import 'package:shelf_rate_limiter/shelf_rate_limiter.dart';
import 'package:shelf_logger/shelf_logger.dart';
import 'package:telemetry/telemetry.dart';
import '../lib/config.dart';
import '../lib/services/task_service.dart'; // New

void main() async {
  Config.init(); // Initialize config
  
  // Initialize services with Config
  final databaseService = DatabaseService();
  await databaseService.connect(); // Initialize PostgreSQL
  
  final taskService = TaskService(databaseService); // New
  taskService.startProcessingQueue(); // New

  // Add security middleware
  final securityMiddleware = helmet(
    options: HelmetOptions(
      contentSecurityPolicy: {"default-src": ["'self'"]},
      xssFilter: true,
      hidePoweredBy: true
    )
  );

  final rateLimiter = rateLimiterMiddleware(/*...*/);
  
  final handler = Pipeline()
    .addMiddleware(securityMiddleware) // New
    .addMiddleware(rateLimiter) // New
    .addMiddleware(loggerMiddleware()) // New
    .addMiddleware(telemetry.middleware) // New
    .addMiddleware(corsHeaders())
    .addMiddleware(_authMiddleware)
    .addHandler(router);

  // Add health endpoint
  router.get('/health', (Request req) => Response.ok('OK'));
}
