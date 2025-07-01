class Payment {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? transactionId;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    required this.createdAt,
    this.paidAt,
    this.transactionId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
      ),
      method: PaymentMethod.values.firstWhere(
        (method) => method.toString().split('.').last == json['method'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      transactionId: json['transactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'transactionId': transactionId,
    };
  }
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  bankTransfer,
  mobileMoney,
}

