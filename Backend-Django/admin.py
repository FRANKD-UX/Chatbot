from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Child, Question, Payment, Subscription

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ['email', 'username', 'subscription_type', 'credits', 'total_spent', 'created_at']
    list_filter = ['subscription_type', 'subscription_status', 'created_at']
    search_fields = ['email', 'username', 'phone']
    readonly_fields = ['created_at', 'last_login']
    
    fieldsets = UserAdmin.fieldsets + (
        ('Subscription Info', {
            'fields': ('subscription_type', 'subscription_status', 'subscription_end_date', 'credits', 'total_spent')
        }),
        ('Contact Info', {
            'fields': ('phone',)
        }),
    )

@admin.register(Child)
class ChildAdmin(admin.ModelAdmin):
    list_display = ['name', 'parent', 'grade', 'created_at']
    list_filter = ['grade', 'created_at']
    search_fields = ['name', 'parent__email']

@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ['question_id', 'user', 'subject', 'grade_level', 'type', 'is_processed', 'rating', 'cost', 'created_at']
    list_filter = ['type', 'subject', 'grade_level', 'difficulty', 'is_processed', 'created_at']
    search_fields = ['user__email', 'subject', 'content']
    readonly_fields = ['question_id', 'processing_time', 'created_at', 'updated_at']

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ['transaction_id', 'user', 'amount', 'currency', 'payment_method', 'status', 'type', 'created_at']
    list_filter = ['payment_method', 'status', 'type', 'created_at']
    search_fields = ['transaction_id', 'user__email', 'mpesa_receipt_number']
    readonly_fields = ['created_at']

@admin.register(Subscription)
class SubscriptionAdmin(admin.ModelAdmin):
    list_display = ['user', 'plan_type', 'amount', 'status', 'start_date', 'end_date', 'auto_renew']
    list_filter = ['plan_type', 'status', 'auto_renew', 'start_date']
    search_fields = ['user__email']
    readonly_fields = ['start_date']

# ================================
# management/commands/process_expired_subscriptions.py
from django.core.management.base import BaseCommand
from django.utils import timezone
from homework_helper.models import User, Subscription

class Command(BaseCommand):
    help = 'Process expired subscriptions'

    def handle(self, *args, **options):
        now = timezone.now()
        expired_subscriptions = Subscription.objects.filter(
            end_date__lt=now,
            status='active'
        )
        
        for subscription in expired_subscriptions:
            subscription.status = 'expired'
            subscription.save()
            
            # Update user subscription status
            user = subscription.user
            user.subscription_type = 'free'
            user.subscription_status = 'expired'
            user.credits = 0  # Reset credits for expired users
            user.save()
            
            self.stdout.write(
                self.style.SUCCESS(
                    f'Processed expired subscription for {user.email}'
                )
            )

# ================================
# management/commands/send_subscription_reminders.py
from django.core.management.base import BaseCommand
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from datetime import timedelta
from homework_helper.models import User, Subscription

class Command(BaseCommand):
    help = 'Send subscription renewal reminders'

    def handle(self, *args, **options):
        # Send reminders 3 days before expiry
        reminder_date = timezone.now() + timedelta(days=3)
        
        upcoming_expiries = Subscription.objects.filter(
            end_date__date=reminder_date.date(),
            status='active',
            auto_renew=False
        )
        
        for subscription in upcoming_expiries:
            user = subscription.user
            
            send_mail(
                subject='Homework Helper Subscription Reminder',
                message=f'''
                Hi {user.first_name},
                
                Your Homework Helper subscription will expire on {subscription.end_date.strftime('%B %d, %Y')}.
                
                Don't miss out on getting help with your children's homework!
                
                Renew your subscription now to continue enjoying unlimited questions and expert explanations.
                
                Best regards,
                The Homework Helper Team
                ''',
                from_email=settings.EMAIL_HOST_USER,
                recipient_list=[user.email],
                fail_silently=False,
            )
            
            self.stdout.write(
                self.style.SUCCESS(
                    f'Sent reminder to {user.email}'
                )
            )
