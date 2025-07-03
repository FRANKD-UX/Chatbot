# models.py
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator
import uuid

class User(AbstractUser):
    SUBSCRIPTION_TYPES = [
        ('free', 'Free'),
        ('pay-per-use', 'Pay Per Use'),
        ('monthly', 'Monthly'),
        ('family', 'Family'),
    ]
    
    SUBSCRIPTION_STATUS = [
        ('active', 'Active'),
        ('expired', 'Expired'),
        ('cancelled', 'Cancelled'),
    ]
    
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=15)
    subscription_type = models.CharField(
        max_length=20, 
        choices=SUBSCRIPTION_TYPES, 
        default='free'
    )
    subscription_status = models.CharField(
        max_length=20, 
        choices=SUBSCRIPTION_STATUS, 
        default='active'
    )
    subscription_end_date = models.DateTimeField(null=True, blank=True)
    credits = models.IntegerField(default=3)  # Free tier gets 3 questions
    total_spent = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    last_login = models.DateTimeField(auto_now=True)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username', 'phone']

class Child(models.Model):
    parent = models.ForeignKey(User, on_delete=models.CASCADE, related_name='children')
    name = models.CharField(max_length=100)
    grade = models.CharField(max_length=20)
    subjects = models.JSONField(default=list)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.name} - Grade {self.grade}"

class Question(models.Model):
    TYPE_CHOICES = [
        ('text', 'Text'),
        ('image', 'Image'),
    ]
    
    DIFFICULTY_CHOICES = [
        ('easy', 'Easy'),
        ('medium', 'Medium'),
        ('hard', 'Hard'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='questions')
    question_id = models.UUIDField(default=uuid.uuid4, unique=True)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    content = models.TextField()
    image = models.ImageField(upload_to='question_images/', null=True, blank=True)
    subject = models.CharField(max_length=100)
    grade_level = models.CharField(max_length=20)
    child = models.ForeignKey(Child, on_delete=models.SET_NULL, null=True, blank=True)
    ai_response = models.TextField(null=True, blank=True)
    explanation = models.TextField(null=True, blank=True)
    step_by_step = models.JSONField(default=list)
    difficulty = models.CharField(max_length=10, choices=DIFFICULTY_CHOICES, null=True)
    processing_time = models.IntegerField(null=True)  # in milliseconds
    rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)], 
        null=True, blank=True
    )
    feedback = models.TextField(null=True, blank=True)
    cost = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    is_processed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Question {self.question_id} - {self.subject}"

class Payment(models.Model):
    PAYMENT_METHODS = [
        ('mpesa', 'M-Pesa'),
        ('card', 'Card'),
        ('airtel', 'Airtel Money'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]
    
    TYPE_CHOICES = [
        ('subscription', 'Subscription'),
        ('credits', 'Credits'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments')
    transaction_id = models.CharField(max_length=100, unique=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='KES')
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHODS)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    description = models.TextField(null=True, blank=True)
    mpesa_receipt_number = models.CharField(max_length=50, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Payment {self.transaction_id} - {self.amount} {self.currency}"

class Subscription(models.Model):
    PLAN_TYPES = [
        ('monthly', 'Monthly'),
        ('family', 'Family'),
    ]
    
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('expired', 'Expired'),
        ('cancelled', 'Cancelled'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='subscriptions')
    plan_type = models.CharField(max_length=20, choices=PLAN_TYPES)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    start_date = models.DateTimeField(auto_now_add=True)
    end_date = models.DateTimeField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    auto_renew = models.BooleanField(default=True)
    payment = models.ForeignKey(Payment, on_delete=models.SET_NULL, null=True)
    
    class Meta:
        ordering = ['-start_date']
    
    def __str__(self):
        return f"{self.user.email} - {self.plan_type} - {self.status}"

