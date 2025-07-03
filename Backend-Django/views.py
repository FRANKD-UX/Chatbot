from rest_framework import generics, status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import login
from django.shortcuts import get_object_or_404
from django.utils import timezone
from django.conf import settings
import requests
import json
import base64
import time
from datetime import datetime, timedelta
from .models import User, Child, Question, Payment, Subscription
from .serializers import (
    UserRegistrationSerializer, UserLoginSerializer, UserProfileSerializer,
    ChildSerializer, QuestionSerializer, PaymentSerializer, SubscriptionSerializer
)
from .services import AIService, PaymentService

class UserRegistrationView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [permissions.AllowAny]
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'user': UserProfileSerializer(user).data,
            'token': token.key
        }, status=status.HTTP_201_CREATED)

class UserLoginView(generics.GenericAPIView):
    serializer_class = UserLoginSerializer
    permission_classes = [permissions.AllowAny]
    
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)
        user.last_login = timezone.now()
        user.save()
        return Response({
            'user': UserProfileSerializer(user).data,
            'token': token.key
        })

class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return self.request.user

class ChildListCreateView(generics.ListCreateAPIView):
    serializer_class = ChildSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Child.objects.filter(parent=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(parent=self.request.user)

class ChildDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ChildSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Child.objects.filter(parent=self.request.user)

class QuestionListCreateView(generics.ListCreateAPIView):
    serializer_class = QuestionSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Question.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        user = self.request.user
        
        # Check if user has credits or active subscription
        if user.subscription_type == 'free' and user.credits <= 0:
            return Response(
                {'error': 'No credits remaining. Please purchase credits or subscribe.'},
                status=status.HTTP_402_PAYMENT_REQUIRED
            )
        
        # Calculate cost based on subscription type
        cost = 0
        if user.subscription_type == 'pay-per-use':
            cost = 10  # KES 10 per question
        elif user.subscription_type == 'free':
            user.credits -= 1
            user.save()
        
        question = serializer.save(user=user, cost=cost)
        
        # Process question with AI
        ai_service = AIService()
        ai_service.process_question(question)

class QuestionDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = QuestionSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Question.objects.filter(user=self.request.user)

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def rate_question(request, question_id):
    question = get_object_or_404(Question, question_id=question_id, user=request.user)
    rating = request.data.get('rating')
    feedback = request.data.get('feedback', '')
    
    if not rating or not (1 <= int(rating) <= 5):
        return Response(
            {'error': 'Rating must be between 1 and 5'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    question.rating = rating
    question.feedback = feedback
    question.save()
    
    return Response({'message': 'Thank you for your feedback!'})

class PaymentListCreateView(generics.ListCreateAPIView):
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Payment.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        payment = serializer.save(user=self.request.user)
        
        # Process payment based on method
        payment_service = PaymentService()
        if payment.payment_method == 'mpesa':
            payment_service.process_mpesa_payment(payment)

class SubscriptionListCreateView(generics.ListCreateAPIView):
    serializer_class = SubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Subscription.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        plan_type = serializer.validated_data['plan_type']
        amount = 500 if plan_type == 'monthly' else 1000  # KES
        end_date = timezone.now() + timedelta(days=30)
        
        subscription = serializer.save(
            user=self.request.user,
            amount=amount,
            end_date=end_date
        )
        
        # Update user subscription
        user = self.request.user
        user.subscription_type = plan_type
        user.subscription_end_date = end_date
        user.save()    

