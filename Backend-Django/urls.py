from django.urls import path
from . import views

urlpatterns = [
    # Authentication
    path('auth/register/', views.UserRegistrationView.as_view(), name='register'),
    path('auth/login/', views.UserLoginView.as_view(), name='login'),
    path('auth/profile/', views.UserProfileView.as_view(), name='profile'),
    
    # Children
    path('children/', views.ChildListCreateView.as_view(), name='children-list'),
    path('children/<int:pk>/', views.ChildDetailView.as_view(), name='child-detail'),
    
    # Questions
    path('questions/', views.QuestionListCreateView.as_view(), name='questions-list'),
    path('questions/<int:pk>/', views.QuestionDetailView.as_view(), name='question-detail'),
    path('questions/<uuid:question_id>/rate/', views.rate_question, name='rate-question'),
    
    # Payments
    path('payments/', views.PaymentListCreateView.as_view(), name='payments-list'),
    
    # Subscriptions
    path('subscriptions/', views.SubscriptionListCreateView.as_view(), name='subscriptions-list'),
]
