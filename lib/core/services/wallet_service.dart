import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_transaction_model.dart';

class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  static WalletService get instance => _instance;

  WalletService._internal();

  static const double minDepositAmount = 50.0;
  static const double maxWalletBalance = 10000.0; // RBI PPI Non-KYC limit

  double _availableBalance = 750.0;
  double _reservedBalance = 350.0;
  final List<WalletTransactionModel> _transactions = [];
  bool _isInitialized = false;

  double get availableBalance => _availableBalance;
  double get reservedBalance => _reservedBalance;
  double get totalBalance => _availableBalance + _reservedBalance;
  List<WalletTransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('trylo_wallet_state');

      if (dataStr != null && dataStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(dataStr);
        _availableBalance = (data['availableBalance'] as num?)?.toDouble() ?? 750.0;
        _reservedBalance = (data['reservedBalance'] as num?)?.toDouble() ?? 350.0;
        final list = (data['transactions'] as List<dynamic>?) ?? [];
        _transactions.clear();
        for (var item in list) {
          _transactions.add(WalletTransactionModel.fromJson(item as Map<String, dynamic>));
        }
      } else {
        _seedDefaultTransactions();
      }
    } catch (e) {
      debugPrint('WalletService init error: $e');
      if (_transactions.isEmpty) {
        _seedDefaultTransactions();
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _seedDefaultTransactions() {
    final now = DateTime.now();
    _transactions.clear();
    _transactions.addAll([
      WalletTransactionModel(
        id: 'TXN_${now.millisecondsSinceEpoch - 100000}',
        invoiceId: 'INV-2026-09-8472',
        type: WalletTransactionType.reservedHold,
        amount: 350.0,
        status: WalletTransactionStatus.success,
        timestamp: now.subtract(const Duration(hours: 2)),
        title: 'Session Booking Hold - Priya S.',
        description: 'Locked for ongoing video connection session',
        paymentMethod: 'Wallet Balance',
        baseAmount: 296.61,
        gstAmount: 53.39,
        bookingSessionId: 'SES_9042',
      ),
      WalletTransactionModel(
        id: 'TXN_${now.millisecondsSinceEpoch - 500000}',
        invoiceId: 'INV-2026-09-8460',
        type: WalletTransactionType.deposit,
        amount: 500.0,
        status: WalletTransactionStatus.success,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        title: 'Wallet Deposit via UPI',
        description: 'Instant UPI funds addition via PhonePe',
        paymentMethod: 'UPI - PhonePe',
        razorpayPaymentId: 'pay_P92kL1093847',
        baseAmount: 423.73,
        gstAmount: 76.27,
      ),
      WalletTransactionModel(
        id: 'TXN_${now.millisecondsSinceEpoch - 900000}',
        invoiceId: 'INV-2026-09-8411',
        type: WalletTransactionType.bookingPayment,
        amount: 200.0,
        status: WalletTransactionStatus.success,
        timestamp: now.subtract(const Duration(days: 3, hours: 5)),
        title: 'Completed Session - Ananya R.',
        description: '30-minute verified video session completed',
        paymentMethod: 'Wallet Balance',
        baseAmount: 169.49,
        gstAmount: 30.51,
        bookingSessionId: 'SES_8812',
      ),
      WalletTransactionModel(
        id: 'TXN_${now.millisecondsSinceEpoch - 1500000}',
        invoiceId: 'INV-2026-09-8390',
        type: WalletTransactionType.refund,
        amount: 150.0,
        status: WalletTransactionStatus.success,
        timestamp: now.subtract(const Duration(days: 5)),
        title: 'Cancelled Session Refund',
        description: 'Host unavailable - reserved amount returned to wallet',
        paymentMethod: 'Wallet Balance',
        baseAmount: 127.12,
        gstAmount: 22.88,
        bookingSessionId: 'SES_8700',
      ),
      WalletTransactionModel(
        id: 'TXN_${now.millisecondsSinceEpoch - 2500000}',
        invoiceId: 'INV-2026-09-8320',
        type: WalletTransactionType.deposit,
        amount: 1000.0,
        status: WalletTransactionStatus.success,
        timestamp: now.subtract(const Duration(days: 12)),
        title: 'Wallet Deposit via Net Banking',
        description: 'HDFC Net Banking payment verified by Razorpay',
        paymentMethod: 'Net Banking - HDFC',
        razorpayPaymentId: 'pay_P88mX776102',
        baseAmount: 847.46,
        gstAmount: 152.54,
      ),
    ]);
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'availableBalance': _availableBalance,
        'reservedBalance': _reservedBalance,
        'transactions': _transactions.map((t) => t.toJson()).toList(),
      };
      await prefs.setString('trylo_wallet_state', jsonEncode(data));
    } catch (e) {
      debugPrint('WalletService save error: $e');
    }
  }

  /// Deposit money into wallet via Razorpay (UPI, Card, Netbanking)
  Future<Map<String, dynamic>> depositFunds({
    required double amount,
    required String paymentMethod,
    String? upiId,
  }) async {
    if (amount < minDepositAmount) {
      return {
        'success': false,
        'message': 'Minimum deposit amount is ₹${minDepositAmount.toInt()}.',
      };
    }

    if (totalBalance + amount > maxWalletBalance) {
      return {
        'success': false,
        'message':
            'Deposit exceeds the RBI PPI wallet limit of ₹${maxWalletBalance.toInt()} without full KYC.',
      };
    }

    final randomId = Random().nextInt(899999) + 100000;
    final rzpId = 'pay_${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    final invId = 'INV-2026-09-${Random().nextInt(8999) + 1000}';

    final base = (amount / 1.18);
    final gst = amount - base;

    final newTxn = WalletTransactionModel(
      id: 'TXN_$randomId',
      invoiceId: invId,
      type: WalletTransactionType.deposit,
      amount: amount,
      status: WalletTransactionStatus.success,
      timestamp: DateTime.now(),
      title: 'Wallet Deposit via $paymentMethod',
      description: 'Funds successfully added via Razorpay Gateway',
      paymentMethod: paymentMethod,
      razorpayPaymentId: rzpId,
      baseAmount: double.parse(base.toStringAsFixed(2)),
      gstAmount: double.parse(gst.toStringAsFixed(2)),
    );

    _availableBalance += amount;
    _transactions.insert(0, newTxn);
    notifyListeners();
    await _saveToPrefs();

    return {
      'success': true,
      'message': '₹${amount.toStringAsFixed(0)} added successfully to your wallet.',
      'transaction': newTxn,
    };
  }

  /// Lock funds for an active session booking
  Future<bool> holdForBooking({
    required double amount,
    required String sessionTitle,
  }) async {
    if (_availableBalance < amount) {
      return false;
    }

    final randomId = Random().nextInt(899999) + 100000;
    final invId = 'INV-2026-09-${Random().nextInt(8999) + 1000}';
    final base = (amount / 1.18);
    final gst = amount - base;

    final holdTxn = WalletTransactionModel(
      id: 'TXN_$randomId',
      invoiceId: invId,
      type: WalletTransactionType.reservedHold,
      amount: amount,
      status: WalletTransactionStatus.success,
      timestamp: DateTime.now(),
      title: 'Session Hold - $sessionTitle',
      description: 'Locked for ongoing session',
      paymentMethod: 'Wallet Balance',
      baseAmount: double.parse(base.toStringAsFixed(2)),
      gstAmount: double.parse(gst.toStringAsFixed(2)),
      bookingSessionId: 'SES_$randomId',
    );

    _availableBalance -= amount;
    _reservedBalance += amount;
    _transactions.insert(0, holdTxn);
    notifyListeners();
    await _saveToPrefs();
    return true;
  }

  /// Refund reserved funds when a session is cancelled (Requirement 7)
  Future<bool> refundReservedBooking({
    required double amount,
    required String sessionTitle,
  }) async {
    if (_reservedBalance < amount) {
      return false;
    }

    final randomId = Random().nextInt(899999) + 100000;
    final invId = 'INV-2026-09-${Random().nextInt(8999) + 1000}';
    final base = (amount / 1.18);
    final gst = amount - base;

    final refundTxn = WalletTransactionModel(
      id: 'TXN_$randomId',
      invoiceId: invId,
      type: WalletTransactionType.refund,
      amount: amount,
      status: WalletTransactionStatus.success,
      timestamp: DateTime.now(),
      title: 'Refund - $sessionTitle',
      description: 'Cancelled session amount returned to available balance',
      paymentMethod: 'Wallet Balance',
      baseAmount: double.parse(base.toStringAsFixed(2)),
      gstAmount: double.parse(gst.toStringAsFixed(2)),
      bookingSessionId: 'SES_$randomId',
    );

    _reservedBalance -= amount;
    _availableBalance += amount;
    _transactions.insert(0, refundTxn);
    notifyListeners();
    await _saveToPrefs();
    return true;
  }

  /// Filter transactions by time and type
  List<WalletTransactionModel> getFilteredTransactions({
    String timeFilter = 'all',
    String typeFilter = 'all',
  }) {
    final now = DateTime.now();

    return _transactions.where((txn) {
      // Time filter
      if (timeFilter == 'week') {
        final weekAgo = now.subtract(const Duration(days: 7));
        if (txn.timestamp.isBefore(weekAgo)) return false;
      } else if (timeFilter == 'month') {
        final monthAgo = now.subtract(const Duration(days: 30));
        if (txn.timestamp.isBefore(monthAgo)) return false;
      }

      // Type filter
      if (typeFilter == 'deposits') {
        if (txn.type != WalletTransactionType.deposit) return false;
      } else if (typeFilter == 'bookings') {
        if (txn.type != WalletTransactionType.bookingPayment &&
            txn.type != WalletTransactionType.reservedHold) {
          return false;
        }
      } else if (typeFilter == 'refunds') {
        if (txn.type != WalletTransactionType.refund) return false;
      }

      return true;
    }).toList();
  }
}
