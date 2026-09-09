enum WalletTransactionType {
  deposit,
  bookingPayment,
  refund,
  reservedHold,
}

enum WalletTransactionStatus {
  success,
  pending,
  failed,
}

class WalletTransactionModel {
  final String id;
  final String invoiceId;
  final WalletTransactionType type;
  final double amount;
  final WalletTransactionStatus status;
  final DateTime timestamp;
  final String title;
  final String description;
  final String paymentMethod;
  final String? razorpayPaymentId;
  final double baseAmount;
  final double gstAmount;
  final String? bookingSessionId;

  const WalletTransactionModel({
    required this.id,
    required this.invoiceId,
    required this.type,
    required this.amount,
    required this.status,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.paymentMethod,
    this.razorpayPaymentId,
    required this.baseAmount,
    required this.gstAmount,
    this.bookingSessionId,
  });

  bool get isCredit =>
      type == WalletTransactionType.deposit ||
      type == WalletTransactionType.refund;

  String get typeLabel {
    switch (type) {
      case WalletTransactionType.deposit:
        return 'Deposit';
      case WalletTransactionType.bookingPayment:
        return 'Booking Payment';
      case WalletTransactionType.refund:
        return 'Refund';
      case WalletTransactionType.reservedHold:
        return 'Session Hold';
    }
  }

  String get statusLabel {
    switch (status) {
      case WalletTransactionStatus.success:
        return 'Success';
      case WalletTransactionStatus.pending:
        return 'Pending';
      case WalletTransactionStatus.failed:
        return 'Failed';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'type': type.name,
      'amount': amount,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'description': description,
      'paymentMethod': paymentMethod,
      'razorpayPaymentId': razorpayPaymentId,
      'baseAmount': baseAmount,
      'gstAmount': gstAmount,
      'bookingSessionId': bookingSessionId,
    };
  }

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String? ?? '',
      invoiceId: json['invoiceId'] as String? ?? '',
      type: WalletTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WalletTransactionType.deposit,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: WalletTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WalletTransactionStatus.success,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'UPI',
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      baseAmount: (json['baseAmount'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      bookingSessionId: json['bookingSessionId'] as String?,
    );
  }
}
