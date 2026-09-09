import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/services/wallet_service.dart';

class AddFundsBottomSheet extends StatefulWidget {
  final double? initialAmount;
  final VoidCallback? onDepositSuccess;

  const AddFundsBottomSheet({
    super.key,
    this.initialAmount,
    this.onDepositSuccess,
  });

  static Future<bool?> show(
    BuildContext context, {
    double? initialAmount,
    VoidCallback? onDepositSuccess,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFundsBottomSheet(
        initialAmount: initialAmount,
        onDepositSuccess: onDepositSuccess,
      ),
    );
  }

  @override
  State<AddFundsBottomSheet> createState() => _AddFundsBottomSheetState();
}

class _AddFundsBottomSheetState extends State<AddFundsBottomSheet> {
  late final TextEditingController _amountController;
  String _selectedMethod = 'UPI - PhonePe';
  bool _isProcessing = false;

  final List<double> _presetAmounts = const [100.0, 300.0, 500.0, 1000.0, 2000.0];

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
  void initState() {
    super.initState();
    final startAmt = widget.initialAmount != null && widget.initialAmount! > 0
        ? widget.initialAmount!.ceil().toString()
        : '500';
    _amountController = TextEditingController(text: startAmt);
  }

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

    if (WalletService.instance.totalBalance + rawAmount >
        WalletService.maxWalletBalance) {
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
    await Future.delayed(const Duration(milliseconds: 900));

    final result = await WalletService.instance.depositFunds(
      amount: rawAmount,
      paymentMethod: _selectedMethod,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result['success'] == true) {
      widget.onDepositSuccess?.call();
      Navigator.pop(context, true);
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F6F4), AppColors.iceMint],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.paleMint),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 13, color: AppColors.pineDark),
                    const SizedBox(width: 4),
                    Text(
                      'Razorpay Gateway',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pineDark,
                      ),
                    ),
                  ],
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
                    fontSize: 24,
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
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pineDark,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter amount',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Preset Amount Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _presetAmounts.map((amt) {
                final isSelected =
                    _amountController.text.trim() == amt.toInt().toString();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text('+₹${amt.toInt()}'),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.pineDark,
                    ),
                    backgroundColor:
                        isSelected ? AppColors.pineDark : AppColors.cardTint,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.pineDark
                          : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: () {
                      setState(() {
                        _amountController.text = amt.toInt().toString();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Select Payment Mode',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.pineDark,
            ),
          ),
          const SizedBox(height: 10),

          // Payment Options List
          ..._paymentOptions.map((opt) {
            final isSelected = _selectedMethod == opt['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedMethod = opt['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0F8F6) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.seafoamTeal
                        : AppColors.borderLight,
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.seafoamTeal.withValues(alpha: 0.15)
                            : const Color(0xFFF7FCFA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        opt['icon'] as IconData,
                        size: 20,
                        color: isSelected
                            ? AppColors.seafoamTeal
                            : AppColors.pineDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pineDark,
                            ),
                          ),
                          Text(
                            opt['subtitle'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 18,
                      color: isSelected
                          ? AppColors.seafoamTeal
                          : AppColors.borderLight,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 14),

          // Pay Button with Brand Gradient
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24374442),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_rounded,
                              size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Pay Securely via Razorpay',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
