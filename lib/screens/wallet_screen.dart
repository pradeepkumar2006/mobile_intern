import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/models/wallet_transaction_model.dart';
import '../core/services/user_profile_service.dart';
import '../core/services/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _timeFilter = 'all'; // 'week', 'month', 'all'
  String _typeFilter = 'all'; // 'all', 'deposits', 'bookings', 'refunds'

  @override
  void initState() {
    super.initState();
    WalletService.instance.init();
  }

  void _showAddFundsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddFundsBottomSheet(),
    );
  }

  void _showInvoiceSheet(WalletTransactionModel txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvoiceBottomSheet(txn: txn),
    );
  }

  void _handleSimulateHoldAndRefund() async {
    final wallet = WalletService.instance;
    if (wallet.availableBalance < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient available balance to test hold. Please deposit at least ₹100.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Step 1: Hold funds for session
    final success = await wallet.holdForBooking(
      amount: 100.0,
      sessionTitle: 'Creator Audio Session',
    );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '₹100 held for ongoing session. Reserved balance updated.',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.pineDark,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Simulate Cancel',
          textColor: AppColors.seafoamTeal,
          onPressed: () async {
            // Step 2: Session cancelled -> Automatic Refund to available balance
            await wallet.refundReservedBooking(
              amount: 100.0,
              sessionTitle: 'Creator Audio Session',
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Session cancelled: ₹100 refunded to Available Balance.',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.seafoamTeal,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WalletService.instance,
      builder: (context, _) {
        final wallet = WalletService.instance;
        final transactions = wallet.getFilteredTransactions(
          timeFilter: _timeFilter,
          typeFilter: _typeFilter,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFFBFDFD),
          body: SafeArea(
            bottom: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trylo Wallet',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.pineDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'India-first digital balance with Razorpay UPI & Cards',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.iceMint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.paleMint),
                      ),
                      child: Text(
                        'INR (₹)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pineDark,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Main Tri-Balance Card
                _buildTriBalanceCard(wallet),

                const SizedBox(height: 16),

                // Quick Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _showAddFundsSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pineDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                        label: Text(
                          'Add Money',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _handleSimulateHoldAndRefund,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.pineDark,
                          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: Text(
                          'Hold / Refund',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // RBI PPI Compliance Notice Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FAF8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.paleMint),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, size: 20, color: AppColors.seafoamTeal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RBI PPI Guideline Protected',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.pineDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Wallet balances are limited to ₹10,000 for standard accounts. Minimum reload is ₹50.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // Transaction History Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction History',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pineDark,
                      ),
                    ),
                    Text(
                      '${transactions.length} records',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Time Filter Segment (This Week, This Month, All Time)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      _buildTimeTab('all', 'All Time'),
                      _buildTimeTab('month', 'This Month'),
                      _buildTimeTab('week', 'This Week'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Type Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildTypeChip('all', 'All Types'),
                      const SizedBox(width: 8),
                      _buildTypeChip('deposits', 'Deposits'),
                      const SizedBox(width: 8),
                      _buildTypeChip('bookings', 'Bookings & Holds'),
                      const SizedBox(width: 8),
                      _buildTypeChip('refunds', 'Refunds'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Transaction Items List
                if (transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.paleMint),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transactions matching this filter will appear here',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...transactions.map((txn) => _buildTransactionCard(txn)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTriBalanceCard(WalletService wallet) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF222C2A), // Deep Charcoal Pine
            Color(0xFF374442),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A1B2422),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA0CFC9),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_rounded, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-Secured',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${wallet.totalBalance.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 20),

          // Sub-row: Available and Reserved
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                // Available Balance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.seafoamTeal,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Available Balance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${wallet.availableBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ready to spend',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFFA0CFC9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider
                Container(
                  width: 1,
                  height: 44,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(width: 14),

                // Reserved Balance (Locked for ongoing session)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBBF24), // Amber
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Reserved Balance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${wallet.reservedBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Locked for ongoing session',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFFFBBF24),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTab(String key, String label) {
    final isSelected = _timeFilter == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _timeFilter = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.pineDark : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String key, String label) {
    final isSelected = _typeFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.seafoamTeal.withValues(alpha: 0.18) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.seafoamTeal : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.pineDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransactionModel txn) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (txn.type) {
      case WalletTransactionType.deposit:
        icon = Icons.arrow_downward_rounded;
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFFD1FAE5);
        break;
      case WalletTransactionType.bookingPayment:
        icon = Icons.arrow_upward_rounded;
        iconColor = AppColors.pineDark;
        iconBg = AppColors.iceMint;
        break;
      case WalletTransactionType.refund:
        icon = Icons.replay_rounded;
        iconColor = AppColors.seafoamTeal;
        iconBg = const Color(0xFFE0F2FE);
        break;
      case WalletTransactionType.reservedHold:
        icon = Icons.lock_clock_rounded;
        iconColor = const Color(0xFFD97706);
        iconBg = const Color(0xFFFEF3C7);
        break;
    }

    final dateStr =
        '${txn.timestamp.day.toString().padLeft(2, '0')} ${_getMonthName(txn.timestamp.month)}, ${txn.timestamp.hour.toString().padLeft(2, '0')}:${txn.timestamp.minute.toString().padLeft(2, '0')}';

    final isPositive = txn.isCredit;
    final prefix = isPositive ? '+₹' : '-₹';
    final amountColor = isPositive ? const Color(0xFF059669) : AppColors.pineDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pineDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr • ${txn.paymentMethod}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix${txn.amount.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _showInvoiceSheet(txn),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_outlined, size: 12, color: AppColors.seafoamTeal),
                      const SizedBox(width: 3),
                      Text(
                        'Invoice',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.seafoamTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

// ----------------------------------------------------------------------
// Add Funds Bottom Sheet (Razorpay, UPI, Card, NetBanking & Limits)
// ----------------------------------------------------------------------

class _AddFundsBottomSheet extends StatefulWidget {
  const _AddFundsBottomSheet();

  @override
  State<_AddFundsBottomSheet> createState() => _AddFundsBottomSheetState();
}

class _AddFundsBottomSheetState extends State<_AddFundsBottomSheet> {
  final TextEditingController _amountController = TextEditingController(text: '500');
  String _selectedMethod = 'UPI - PhonePe';
  bool _isProcessing = false;

  final List<double> _presetAmounts = const [100.0, 500.0, 1000.0, 2000.0];

  final List<Map<String, dynamic>> _paymentOptions = const [
    {
      'id': 'UPI - PhonePe',
      'title': 'PhonePe UPI',
      'subtitle': 'Fastest via installed app',
      'icon': Icons.flash_on_rounded,
    },
    {
      'id': 'UPI - Google Pay',
      'title': 'Google Pay (GPay)',
      'subtitle': 'One-tap UPI payment',
      'icon': Icons.account_balance_rounded,
    },
    {
      'id': 'UPI - Paytm',
      'title': 'Paytm UPI',
      'subtitle': 'Instant bank debit',
      'icon': Icons.qr_code_rounded,
    },
    {
      'id': 'Debit / Credit Card',
      'title': 'Cards (Visa, Mastercard, RuPay)',
      'subtitle': 'Domestic and international cards',
      'icon': Icons.credit_card_rounded,
    },
    {
      'id': 'Net Banking',
      'title': 'Net Banking (SBI, HDFC, ICICI, Axis)',
      'subtitle': 'All Indian scheduled banks',
      'icon': Icons.apartment_rounded,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleDeposit() async {
    final rawAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (rawAmount < WalletService.minDepositAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum deposit amount is ₹${WalletService.minDepositAmount.toInt()}',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (WalletService.instance.totalBalance + rawAmount > WalletService.maxWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deposit exceeds the RBI PPI wallet balance limit of ₹${WalletService.maxWalletBalance.toInt()} without full KYC.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate Razorpay Gateway authorization
    await Future.delayed(const Duration(milliseconds: 1200));

    final result = await WalletService.instance.depositFunds(
      amount: rawAmount,
      paymentMethod: _selectedMethod,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '₹${rawAmount.toInt()} deposited successfully via $_selectedMethod!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.seafoamTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] as String? ?? 'Payment failed',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        20,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Gateway branding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Money to Wallet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pineDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.iceMint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Razorpay Gateway',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pineDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount Input with currency prefix
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFDFD),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.seafoamTeal, width: 1.5),
            ),
            child: Row(
              children: [
                Text(
                  '₹',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.pineDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.pineDark,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter amount',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Preset Quick Add Buttons
          Row(
            children: _presetAmounts.map((preset) {
              final isSelected = _amountController.text == preset.toInt().toString();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _amountController.text = preset.toInt().toString();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor:
                          isSelected ? AppColors.pineDark : const Color(0xFFF4FAF8),
                      side: BorderSide(
                        color: isSelected ? AppColors.pineDark : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '+₹${preset.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.pineDark,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Payment Methods Section
          Text(
            'Select Payment Method',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.pineDark,
            ),
          ),
          const SizedBox(height: 8),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _paymentOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final method = _paymentOptions[index];
                final isSelected = _selectedMethod == method['id'];
                return InkWell(
                  onTap: () => setState(() => _selectedMethod = method['id'] as String),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8F6F4) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.seafoamTeal : AppColors.borderLight,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          method['icon'] as IconData,
                          size: 20,
                          color: isSelected ? AppColors.pineDark : AppColors.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['title'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pineDark,
                                ),
                              ),
                              Text(
                                method['subtitle'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              size: 18, color: AppColors.seafoamTeal),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Proceed Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleDeposit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pineDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Pay & Deposit ₹${_amountController.text.trim().isEmpty ? '0' : _amountController.text.trim()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Invoice Bottom Sheet (Itemized GST Tax Receipt)
// ----------------------------------------------------------------------

class _InvoiceBottomSheet extends StatelessWidget {
  final WalletTransactionModel txn;

  const _InvoiceBottomSheet({required this.txn});

  @override
  Widget build(BuildContext context) {
    final userName = UserProfileService.instance.profile.name.isNotEmpty
        ? UserProfileService.instance.profile.name
        : 'Trylo Member';

    final dateStr =
        '${txn.timestamp.day.toString().padLeft(2, '0')} ${_getMonthName(txn.timestamp.month)} ${txn.timestamp.year}, ${txn.timestamp.hour.toString().padLeft(2, '0')}:${txn.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRYLO DATING',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.pineDark,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Tax Invoice / Receipt',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  txn.statusLabel.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 16),

          // Invoice Meta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaItem('Invoice No.', txn.invoiceId),
              _buildMetaItem('Date & Time', dateStr),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaItem('Billed To', userName),
              _buildMetaItem('Payment Mode', txn.paymentMethod),
            ],
          ),
          if (txn.razorpayPaymentId != null) ...[
            const SizedBox(height: 12),
            _buildMetaItem('Razorpay Ref', txn.razorpayPaymentId!),
          ],

          const SizedBox(height: 18),

          // Itemized Breakdown Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFDFD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      txn.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pineDark,
                      ),
                    ),
                    Text(
                      '₹${txn.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pineDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 10),

                // Base Amount
                _buildPriceRow('Base Service Amount', '₹${txn.baseAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 6),

                // GST Breakdown
                _buildPriceRow(
                  'CGST (9%)',
                  '₹${(txn.gstAmount / 2).toStringAsFixed(2)}',
                ),
                const SizedBox(height: 4),
                _buildPriceRow(
                  'SGST (9%)',
                  '₹${(txn.gstAmount / 2).toStringAsFixed(2)}',
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 10),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount Paid',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pineDark,
                      ),
                    ),
                    Text(
                      '₹${txn.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pineDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Download PDF Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invoice ${txn.invoiceId} downloaded successfully (PDF format).',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppColors.seafoamTeal,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pineDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(
                'Download Invoice PDF',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.pineDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.pineDark,
          ),
        ),
      ],
    );
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
