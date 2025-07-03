from celery import shared_task
from django.core.mail import send_mail
from django.conf import settings
from .models import Question, User
from .services import AIService

@shared_task
def process_question_async(question_id):
    """Process question with AI asynchronously"""
    try:
        question = Question.objects.get(id=question_id)
        ai_service = AIService()
        ai_service.process_question(question)
        
        # Send email notification to user
        send_mail(
            subject='Your homework question has been answered!',
            message=f'''
            Hi {question.user.first_name},
            
            Your question about {question.subject} has been processed and answered.
            
            Log in to your Homework Helper app to view the detailed explanation.
            
            Question: {question.content[:100]}...
            
            Best regards,
            The Homework Helper Team
            ''',
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[question.user.email],
            fail_silently=True,
        )
        
    except Question.DoesNotExist:
        pass

@shared_task
def send_daily_usage_report():
    """Send daily usage report to admin"""
    from django.db.models import Count, Sum
    from datetime import datetime, timedelta
    
    today = datetime.now().date()
    yesterday = today - timedelta(days=1)
    
    # Get statistics
    daily_questions = Question.objects.filter(created_at__date=yesterday).count()
    daily_users = User.objects.filter(last_login__date=yesterday).count()
    daily_revenue = Question.objects.filter(
        created_at__date=yesterday
    ).aggregate(total=Sum('cost'))['total'] or 0
    
    # Send report
    send_mail(
        subject=f'Homework Helper Daily Report - {yesterday}',
        message=f'''
        Daily Usage Report for {yesterday}
        
        Questions Asked: {daily_questions}
        Active Users: {daily_users}
        Revenue Generated: KES {daily_revenue}
        
        Best regards,
        System
        ''',
        from_email=settings.EMAIL_HOST_USER,
        recipient_list=['admin@homeworkhelper.com'],
        fail_silently=True,
    )
