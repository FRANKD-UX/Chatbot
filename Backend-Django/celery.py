import os
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'homework_helper_project.settings')

app = Celery('homework_helper_project')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

# Celery Beat Schedule
from celery.schedules import crontab

app.conf.beat_schedule = {
    'process-expired-subscriptions': {
        'task': 'homework_helper.tasks.process_expired_subscriptions',
        'schedule': crontab(hour=0, minute=0),  # Run daily at midnight
    },
    'send-daily-usage-report': {
        'task': 'homework_helper.tasks.send_daily_usage_report',
        'schedule': crontab(hour=8, minute=0),  # Run daily at 8 AM
    },
}

# ================================
# tests.py
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from .models import Child, Question, Payment, Subscription

User = get_user_model()

class UserAuthTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user_data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123',
            'password_confirm': 'testpass123',
            'phone': '+254712345678',
            'first_name': 'Test',
            'last_name': 'User'
        }

    def test_user_registration(self):
        response = self.client.post('/api/auth/register/', self.user_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('token', response.data)
        self.assertIn('user', response.data)

    def test_user_login(self):
        # Create user first
        User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            phone='+254712345678'
        )
        
        login_data = {
            'email': 'test@example.com',
            'password': 'testpass123'
        }
        
        response = self.client.post('/api/auth/login/', login_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)

class QuestionTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            phone='+254712345678'
        )
        self.client.force_authenticate(user=self.user)

    def test_create_question(self):
        question_data = {
            'type': 'text',
            'content': 'What is 2 + 2?',
            'subject': 'Mathematics',
            'grade_level': 'Grade 1'
        }
        
        response = self.client.post('/api/questions/', question_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Check that user's credits were deducted
        self.user.refresh_from_db()
        self.assertEqual(self.user.credits, 2)

    def test_free_user_credit_limit(self):
        # Use up all credits
        self.user.credits = 0
        self.user.save()
        
        question_data = {
            'type': 'text',
            'content': 'What is 3 + 3?',
            'subject': 'Mathematics',
            'grade_level': 'Grade 1'
        }
        
        response = self.client.post('/api/questions/', question_data)
        self.assertEqual(response.status_code, status.HTTP_402_PAYMENT_REQUIRED)

class ChildTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123',
            phone='+254712345678'
        )
        self.client.force_authenticate(user=self.user)

    def test_create_child(self):
        child_data = {
            'name': 'John Doe',
            'grade': 'Grade 5',
            'subjects': ['Mathematics', 'English', 'Science']
        }
        
        response = self.client.post('/api/children/', child_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Child.objects.count(), 1)

    def test_list_children(self):
        Child.objects.create(
            parent=self.user,
            name='Jane Doe',
            grade='Grade 3',
            subjects=['Mathematics', 'English']
        )
        
        response = self.client.get('/api/children/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

# ================================
# Dockerfile
"""
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Run migrations
RUN python manage.py migrate

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "homework_helper_project.wsgi:application"]
"""

# ================================
# docker-compose.yml
"""
version: '3.8'

services:
  db:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data/
    environment:
      POSTGRES_DB: homework_helper
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  web:
    build: .
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis
    environment:
      - DEBUG=True
      - DB_HOST=db
      - DB_PORT=5432
      - REDIS_URL=redis://redis:6379

  celery:
    build: .
    command: celery -A homework_helper_project worker --loglevel=info
    volumes:
      - .:/app
    depends_on:
      - db
      - redis
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - REDIS_URL=redis://redis:6379

  celery-beat:
    build: .
    command: celery -A homework_helper_project beat --loglevel=info
    volumes:
      - .:/app
    depends_on:
      - db
      - redis
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - REDIS_URL=redis://redis:6379

volumes:
  postgres_data:
"""

# ================================
# API Documentation (README.md)
"""
# Homework Helper API

## Overview
This is the backend API for the Homework Helper mobile application that helps parents assist their children with homework through AI-powered explanations.

## Features
- User authentication and profiles
- Child management
- Question submission (text and images)
- AI-powered explanations
- Payment processing (M-Pesa integration)
- Subscription management
- Usage analytics

## Setup Instructions

### 1. Clone the repository
```bash
git clone <repository-url>
cd homework-helper-backend
```

### 2. Create virtual environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Set up environment variables
Create a `.env` file in the project root with the required variables (see .env example above).

### 5. Run migrations
```bash
python manage.py migrate
```

### 6. Create superuser
```bash
python manage.py createsuperuser
```

### 7. Run the development server
```bash
python manage.py runserver
```

## API Endpoints

### Authentication
- `POST /api/auth/register/` - User registration
- `POST /api/auth/login/` - User login
- `GET /api/auth/profile/` - Get user profile
- `PUT /api/auth/profile/` - Update user profile

### Children Management
- `GET /api/children/` - List user's children
- `POST /api/children/` - Add a child
- `GET /api/children/{id}/` - Get child details
- `PUT /api/children/{id}/` - Update child
- `DELETE /api/children/{id}/` - Delete child

### Questions
- `GET /api/questions/` - List user's questions
- `POST /api/questions/` - Submit a new question
- `GET /api/questions/{id}/` - Get question details
- `PUT /api/questions/{id}/` - Update question
- `POST /api/questions/{uuid}/rate/` - Rate a question

### Payments
- `GET /api/payments/` - List user's payments
- `POST /api/payments/` - Create a payment

### Subscriptions
- `GET /api/subscriptions/` - List user's subscriptions
- `POST /api/subscriptions/` - Create a subscription

## Pricing Structure
- Free Tier: 3 questions per month
- Pay-per-use: KES 10 per question
- Monthly Subscription: KES 500 (unlimited questions)
- Family Plan: KES 1,000 (unlimited questions, multiple children)

## Deployment
The application is containerized using Docker. Use the provided docker-compose.yml for easy deployment.

```bash
docker-compose up -d
```

## Testing
Run tests with:
```bash
python manage.py test
```

## Background Tasks
The application uses Celery for background tasks:
- Question processing with AI
- Email notifications
- Usage analytics
- Subscription management

Start Celery worker:
```bash
celery -A homework_helper_project worker --loglevel=info
```

Start Celery beat (scheduler):
```bash
celery -A homework_helper_project beat --loglevel=info
```
"""
