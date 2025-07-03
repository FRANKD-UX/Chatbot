import openai
import requests
from django.conf import settings
import base64
import json
import time

class AIService:
    def __init__(self):
        self.openai_api_key = settings.OPENAI_API_KEY
        self.claude_api_key = settings.CLAUDE_API_KEY
    
    def process_question(self, question):
        try:
            start_time = time.time()
            
            if question.type == 'text':
                response = self._process_text_question(question.content, question.subject, question.grade_level)
            else:
                response = self._process_image_question(question.image, question.content, question.subject, question.grade_level)
            
            processing_time = int((time.time() - start_time) * 1000)
            
            question.ai_response = response.get('explanation', '')
            question.explanation = response.get('simple_explanation', '')
            question.step_by_step = response.get('steps', [])
            question.difficulty = response.get('difficulty', 'medium')
            question.processing_time = processing_time
            question.is_processed = True
            question.save()
            
        except Exception as e:
            question.ai_response = f"Sorry, I encountered an error processing your question: {str(e)}"
            question.is_processed = True
            question.save()
    
    def _process_text_question(self, content, subject, grade_level):
        prompt = f"""
        You are a friendly homework helper for parents. A parent needs help explaining this {subject} question to their child in grade {grade_level}.

        Question: {content}

        Please provide:
        1. A simple, parent-friendly explanation
        2. Step-by-step solution if applicable
        3. Difficulty level (easy/medium/hard)
        4. Tips for the parent to help their child understand

        Keep the language simple and encouraging.
        """
        
        try:
            openai.api_key = self.openai_api_key
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                max_tokens=500,
                temperature=0.7
            )
            
            content = response.choices[0].message.content
            
            # Parse response (simplified)
            return {
                'explanation': content,
                'simple_explanation': content[:200] + "...",
                'steps': [{'step': 1, 'description': content}],
                'difficulty': 'medium'
            }
            
        except Exception as e:
            return {
                'explanation': f"I'm having trouble processing this question right now. Please try again later.",
                'simple_explanation': "Technical difficulty occurred.",
                'steps': [],
                'difficulty': 'medium'
            }
    
    def _process_image_question(self, image_file, additional_context, subject, grade_level):
        # For image processing, you would typically use OCR first, then process the text
        # This is a simplified implementation
        return {
            'explanation': "Image processing is not fully implemented in this demo. Please convert the image to text and ask again.",
            'simple_explanation': "Please describe the problem in text form.",
            'steps': [],
            'difficulty': 'medium'
        }

class PaymentService:
    def __init__(self):
        self.mpesa_consumer_key = settings.MPESA_CONSUMER_KEY
        self.mpesa_consumer_secret = settings.MPESA_CONSUMER_SECRET
        self.mpesa_shortcode = settings.MPESA_SHORTCODE
        self.mpesa_passkey = settings.MPESA_PASSKEY
    
    def process_mpesa_payment(self, payment):
        """Process M-Pesa STK Push payment"""
        try:
            # Get access token
            access_token = self._get_mpesa_access_token()
            
            # Generate timestamp
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            
            # Generate password
            password = base64.b64encode(
                f"{self.mpesa_shortcode}{self.mpesa_passkey}{timestamp}".encode()
            ).decode('utf-8')
            
            # STK Push request
            stk_push_data = {
                "BusinessShortCode": self.mpesa_shortcode,
                "Password": password,
                "Timestamp": timestamp,
                "TransactionType": "CustomerPayBillOnline",
                "Amount": int(payment.amount),
                "PartyA": payment.user.phone,
                "PartyB": self.mpesa_shortcode,
                "PhoneNumber": payment.user.phone,
                "CallBackURL": "https://yourdomain.com/api/mpesa/callback/",
                "AccountReference": payment.transaction_id,
                "TransactionDesc": payment.description or "Homework Helper Payment"
            }
            
            response = requests.post(
                "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
                json=stk_push_data,
                headers={
                    "Authorization": f"Bearer {access_token}",
                    "Content-Type": "application/json"
                }
            )
            
            if response.status_code == 200:
                payment.status = 'pending'
                payment.save()
                return True
            else:
                payment.status = 'failed'
                payment.save()
                return False
                
        except Exception as e:
            payment.status = 'failed'
            payment.save()
            return False
    
    def _get_mpesa_access_token(self):
        """Get M-Pesa access token"""
        consumer_key = self.mpesa_consumer_key
        consumer_secret = self.mpesa_consumer_secret
        api_url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
        
        response = requests.get(
            api_url,
            auth=(consumer_key, consumer_secret)
        )
        
        return response.json()['access_token']

