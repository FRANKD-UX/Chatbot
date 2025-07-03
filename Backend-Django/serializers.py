from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User, Child, Question, Payment, Subscription

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password_confirm', 'phone', 'first_name', 'last_name']
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Passwords don't match")
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user

class UserLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()
    
    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')
        
        if email and password:
            user = authenticate(username=email, password=password)
            if not user:
                raise serializers.ValidationError('Invalid credentials')
            if not user.is_active:
                raise serializers.ValidationError('User account is disabled')
            attrs['user'] = user
        else:
            raise serializers.ValidationError('Must include email and password')
        return attrs

class ChildSerializer(serializers.ModelSerializer):
    class Meta:
        model = Child
        fields = ['id', 'name', 'grade', 'subjects', 'created_at']

class UserProfileSerializer(serializers.ModelSerializer):
    children = ChildSerializer(many=True, read_only=True)
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 'phone',
            'subscription_type', 'subscription_status', 'subscription_end_date',
            'credits', 'total_spent', 'children', 'created_at', 'last_login'
        ]
        read_only_fields = ['subscription_type', 'subscription_status', 'credits', 'total_spent']

class QuestionSerializer(serializers.ModelSerializer):
    child_name = serializers.CharField(source='child.name', read_only=True)
    
    class Meta:
        model = Question
        fields = [
            'id', 'question_id', 'type', 'content', 'image', 'subject',
            'grade_level', 'child', 'child_name', 'ai_response', 'explanation',
            'step_by_step', 'difficulty', 'processing_time', 'rating',
            'feedback', 'cost', 'is_processed', 'created_at', 'updated_at'
        ]
        read_only_fields = [
            'question_id', 'ai_response', 'explanation', 'step_by_step',
            'difficulty', 'processing_time', 'cost', 'is_processed'
        ]

class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = [
            'id', 'transaction_id', 'amount', 'currency', 'payment_method',
            'status', 'type', 'description', 'mpesa_receipt_number', 'created_at'
        ]
        read_only_fields = ['transaction_id', 'status', 'mpesa_receipt_number']

class SubscriptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subscription
        fields = [
            'id', 'plan_type', 'amount', 'start_date', 'end_date',
            'status', 'auto_renew', 'payment'
        ]
        read_only_fields = ['start_date', 'status']

