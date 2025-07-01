# Deployment Guide - Homework App

This guide provides step-by-step instructions for deploying the Homework App's backend and frontend components.

## 🎯 Overview

The Homework App consists of two main components:
- **Backend**: Dart server using Shelf framework with SQLite database
- **Frontend**: Flutter web application

## 🖥️ Backend Deployment

### Option 1: Local Development Server

1. **Prerequisites**:
   ```bash
   # Install SQLite3 development libraries
   sudo apt-get install -y libsqlite3-dev sqlite3
   ```

2. **Setup and Run**:
   ```bash
   cd homework_backend
   dart pub get
   dart run bin/server.dart
   ```

3. **Verify Deployment**:
   ```bash
   curl http://localhost:3000/health
   # Should return: OK
   ```

### Option 2: Docker Deployment

1. **Create Dockerfile** (`homework_backend/Dockerfile`):
   ```dockerfile
   FROM dart:stable AS build
   
   WORKDIR /app
   COPY pubspec.* ./
   RUN dart pub get
   
   COPY . .
   RUN dart compile exe bin/server.dart -o bin/server
   
   FROM debian:bullseye-slim
   RUN apt-get update && apt-get install -y \
       libsqlite3-0 \
       && rm -rf /var/lib/apt/lists/*
   
   COPY --from=build /app/bin/server /app/bin/
   
   EXPOSE 3000
   CMD ["/app/bin/server"]
   ```

2. **Build and Run**:
   ```bash
   cd homework_backend
   docker build -t homework-backend .
   docker run -p 3000:3000 homework-backend
   ```

### Option 3: Cloud Deployment (Google Cloud Run)

1. **Prepare for Cloud Run**:
   ```bash
   # Install Google Cloud SDK
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   gcloud init
   ```

2. **Deploy to Cloud Run**:
   ```bash
   cd homework_backend
   gcloud run deploy homework-backend \
     --source . \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

## 🌐 Frontend Deployment

### Option 1: Local Development Server

1. **Build and Serve**:
   ```bash
   cd homework_app
   flutter build web
   
   # Serve using Python (for testing)
   cd build/web
   python3 -m http.server 8080
   ```

2. **Access**: Open `http://localhost:8080` in your browser

### Option 2: Firebase Hosting

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Initialize Firebase**:
   ```bash
   cd homework_app
   firebase init hosting
   # Select build/web as public directory
   # Configure as single-page app: Yes
   # Set up automatic builds: No
   ```

3. **Deploy**:
   ```bash
   flutter build web
   firebase deploy
   ```

### Option 3: Netlify Deployment

1. **Build the App**:
   ```bash
   cd homework_app
   flutter build web
   ```

2. **Deploy via Netlify CLI**:
   ```bash
   npm install -g netlify-cli
   netlify deploy --dir=build/web --prod
   ```

3. **Or Deploy via Web Interface**:
   - Go to [Netlify](https://netlify.com)
   - Drag and drop the `build/web` folder

### Option 4: GitHub Pages

1. **Build and Prepare**:
   ```bash
   cd homework_app
   flutter build web --base-href "/homework-app/"
   ```

2. **Deploy to GitHub Pages**:
   ```bash
   # Copy build/web contents to gh-pages branch
   git checkout -b gh-pages
   cp -r build/web/* .
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push origin gh-pages
   ```

## ⚙️ Configuration

### Backend Configuration

1. **Environment Variables**:
   ```bash
   export PORT=3000
   export DATABASE_PATH=/path/to/database.db
   ```

2. **CORS Configuration**: Already configured in `bin/server.dart` for all origins

### Frontend Configuration

1. **Update API Base URL** in `lib/providers/homework_service.dart`:
   ```dart
   static const String baseUrl = 'https://your-backend-url.com/api';
   ```

2. **Build with Custom Base URL**:
   ```bash
   flutter build web --base-href "/your-app-path/"
   ```

## 🔧 Production Optimizations

### Backend Optimizations

1. **Database Optimization**:
   ```dart
   // Add database connection pooling
   // Implement proper indexing
   // Add query optimization
   ```

2. **Security Headers**:
   ```dart
   // Add security middleware
   final handler = Pipeline()
       .addMiddleware(corsHeaders())
       .addMiddleware(securityHeaders())
       .addHandler(app);
   ```

3. **Logging and Monitoring**:
   ```dart
   // Add structured logging
   // Implement health checks
   // Add performance monitoring
   ```

### Frontend Optimizations

1. **Build Optimizations**:
   ```bash
   flutter build web --release --tree-shake-icons
   ```

2. **Performance Optimizations**:
   - Enable code splitting
   - Optimize images and assets
   - Implement lazy loading

## 🚀 CI/CD Pipeline

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Homework App

on:
  push:
    branches: [ main ]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: dart-lang/setup-dart@v1
    - name: Install dependencies
      run: |
        cd homework_backend
        dart pub get
    - name: Deploy to Cloud Run
      run: |
        # Add Cloud Run deployment commands
        
  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
    - name: Build web app
      run: |
        cd homework_app
        flutter build web
    - name: Deploy to Firebase
      run: |
        # Add Firebase deployment commands
```

## 🔍 Health Checks and Monitoring

### Backend Health Checks

1. **Basic Health Check**:
   ```bash
   curl https://your-backend-url.com/health
   ```

2. **Database Health Check**:
   ```bash
   curl https://your-backend-url.com/api/users/health
   ```

### Frontend Monitoring

1. **Performance Monitoring**:
   - Use Firebase Performance Monitoring
   - Implement Google Analytics
   - Add error tracking with Sentry

2. **Uptime Monitoring**:
   - Use services like UptimeRobot
   - Set up alerts for downtime

## 🛡️ Security Considerations

### Backend Security

1. **Environment Variables**:
   ```bash
   # Never commit sensitive data
   # Use environment variables for secrets
   export DATABASE_PASSWORD=your_secure_password
   ```

2. **HTTPS Configuration**:
   ```bash
   # Always use HTTPS in production
   # Configure SSL certificates
   ```

### Frontend Security

1. **Content Security Policy**:
   ```html
   <meta http-equiv="Content-Security-Policy" 
         content="default-src 'self'; script-src 'self' 'unsafe-inline';">
   ```

2. **Environment-specific Builds**:
   ```dart
   // Use different API URLs for different environments
   static const String baseUrl = kDebugMode 
     ? 'http://localhost:3000/api'
     : 'https://production-api.com/api';
   ```

## 📊 Scaling Considerations

### Backend Scaling

1. **Horizontal Scaling**:
   - Use load balancers
   - Implement stateless design
   - Use external database

2. **Database Scaling**:
   - Migrate from SQLite to PostgreSQL/MySQL
   - Implement connection pooling
   - Add read replicas

### Frontend Scaling

1. **CDN Integration**:
   - Use CloudFlare or AWS CloudFront
   - Optimize asset delivery
   - Enable compression

2. **Caching Strategies**:
   - Implement service workers
   - Use browser caching
   - Add API response caching

## 🔧 Troubleshooting

### Common Issues

1. **CORS Errors**:
   ```dart
   // Ensure CORS is properly configured
   corsHeaders(headers: {
     'Access-Control-Allow-Origin': '*',
     'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
   })
   ```

2. **Database Connection Issues**:
   ```bash
   # Check SQLite installation
   sqlite3 --version
   
   # Verify database file permissions
   ls -la homework_app.db
   ```

3. **Flutter Web Build Issues**:
   ```bash
   # Clear build cache
   flutter clean
   flutter pub get
   flutter build web
   ```

### Debugging

1. **Backend Debugging**:
   ```bash
   # Enable verbose logging
   dart run bin/server.dart --verbose
   ```

2. **Frontend Debugging**:
   ```bash
   # Run in debug mode
   flutter run -d web-server --web-port 8080 --debug
   ```

## 📞 Support

For deployment issues:
1. Check the logs for error messages
2. Verify all dependencies are installed
3. Ensure environment variables are set correctly
4. Test API endpoints individually
5. Check network connectivity and firewall settings

---

**Happy Deploying! 🚀**

