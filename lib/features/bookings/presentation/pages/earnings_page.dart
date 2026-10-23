import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../../../core/widgets/text/text_widgets.dart';
import '../../domain/models/wallet_models.dart';
import '../providers/wallet_provider.dart';

class EarningsPage extends ConsumerStatefulWidget {
  const EarningsPage({super.key});

  @override
  ConsumerState<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends ConsumerState<EarningsPage> {
  @override
  Widget build(BuildContext context) {
    final balanceState = ref.watch(walletBalanceProvider);
    final activityState = ref.watch(walletActivityProvider);
    final statsState = ref.watch(walletStatsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshWallet,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 34.h),
              balanceState.when(
                data: (balance) => _buildBalanceCard(balance),
                loading: () => _buildLoadingBlock(height: 190.h),
                error: (error, _) => _buildErrorBlock(
                  message: error.toString(),
                  onRetry: _refreshWallet,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F4F2),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: BodyText(
                  'Workchop deducts a 10% service fee from each completed job before funds become available to you.',
                  size: BodySize.small,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              balanceState.when(
                data: (balance) => Row(
                  children: [
                    _buildSmallStatCard(
                      'Total Earnings (All)',
                      _money(balance.totalEarned + balance.pendingRelease),
                    ),
                    SizedBox(width: 16.w),
                    _buildSmallStatCard(
                      'Withdrawn',
                      _money(balance.totalEarned),
                    ),
                  ],
                ),
                loading: () => Row(
                  children: [
                    Expanded(child: _buildLoadingBlock(height: 100.h)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildLoadingBlock(height: 100.h)),
                  ],
                ),
                error: (error, _) => Row(
                  children: [
                    _buildSmallStatCard('Total Earnings (All)', '--'),
                    SizedBox(width: 16.w),
                    _buildSmallStatCard('Withdrawn', '--'),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              statsState.when(
                data: (stats) => BodyText(
                  'Transactions: ${stats.totalTransactions} | Avg job value: ${_money(stats.averageJobValue)}',
                  size: BodySize.small,
                  color: AppColors.textSecondary,
                ),
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),
              SizedBox(height: 24.h),
              _buildPayoutMethodCard(),
              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyText(
                    'Recent Activity',
                    size: BodySize.medium,
                    fontWeight: FontWeight.w500,
                  ),
                  GestureDetector(
                    onTap: _refreshWallet,
                    child: BodyText(
                      'Refresh',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              activityState.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _buildEmptyActivity();
                  }

                  return Column(
                    children: items
                        .take(10)
                        .map((item) => _buildActivityItem(item))
                        .toList(),
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, _) => _buildErrorBlock(
                  message: error.toString(),
                  onRetry: _refreshWallet,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletBalanceSummary balance) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          BodyText(
            'Available for Payout',
            size: BodySize.medium,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12.h),
          BodyText(
            _money(balance.pendingRelease),
            size: BodySize.large,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 6.h),
          BodyText(
            'Total Earnings (All): ${_money(balance.totalEarned + balance.pendingRelease)}',
            size: BodySize.small,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: 220.w,
            height: 44.h,
            child: ElevatedButton(
              onPressed: balance.pendingRelease >= 5000
                  ? () =>
                        _openPayoutDialog(defaultAmount: balance.pendingRelease)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFBCCBCB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: BodyText(
                'Request Payout',
                size: BodySize.medium,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (balance.pendingRelease < 5000) ...[
            SizedBox(height: 8.h),
            BodyText(
              'Minimum payout is ₦ 5,000.00',
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayoutMethodCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyText(
                'Payout Method',
                size: BodySize.medium,
                fontWeight: FontWeight.w500,
              ),
              GestureDetector(
                onTap: _openPayoutDialog,
                child: BodyText(
                  'Manage',
                  size: BodySize.small,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFBCCBCB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance,
                  size: 20.r,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(
                      'Bank transfer via Paystack',
                      size: BodySize.medium,
                      fontWeight: FontWeight.w500,
                    ),
                    BodyText(
                      'Provide bank details during payout request',
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(Icons.verified, color: const Color(0xFFE2725B), size: 20.r),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 14.r,
                color: const Color(0xFFE2725B),
              ),
              SizedBox(width: 8.w),
              BodyText(
                'Transfers are encrypted and secured',
                size: BodySize.small,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyText(
              label,
              size: BodySize.small,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            BodyText(
              value,
              size: BodySize.medium,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(WalletActivityItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFFBCCBCB),
                child: Icon(
                  item.isCredit ? Icons.south_west : Icons.north_east,
                  color: item.isCredit
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  size: 16.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(
                      item.title,
                      size: BodySize.medium,
                      fontWeight: FontWeight.w500,
                    ),
                    BodyText(
                      item.subtitle,
                      size: BodySize.small,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BodyText(
                    '${item.isCredit ? '+' : '-'} ${_money(item.amount)}',
                    size: BodySize.small,
                    color: item.isCredit
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: item.isCredit
                          ? const Color(0xFFE0F2F1)
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: BodyText(
                      item.type,
                      size: BodySize.small,
                      color: item.isCredit
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: BodyText(
        'No wallet activity yet.',
        size: BodySize.small,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLoadingBlock({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildErrorBlock({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyText(message, size: BodySize.small, color: AppColors.error),
          SizedBox(height: 8.h),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Future<void> _refreshWallet() async {
    ref.invalidate(walletBalanceProvider);
    ref.invalidate(walletEarningsProvider);
    ref.invalidate(walletPayoutsProvider);
    ref.invalidate(walletStatsProvider);
    ref.invalidate(walletActivityProvider);

    await ref.read(walletBalanceProvider.future);
  }

  Future<void> _openPayoutDialog({double? defaultAmount}) async {
    final formData = await showDialog<_PayoutFormData>(
      context: context,
      builder: (_) => _PayoutDialog(defaultAmount: defaultAmount),
    );

    if (formData == null) {
      return;
    }
    final amount = formData.amount;
    final accountNumber = formData.accountNumber;
    final bankCode = formData.bankCode;
    final accountName = formData.accountName;

    if (amount <= 0 ||
        accountNumber.isEmpty ||
        bankCode.isEmpty ||
        accountName.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    try {
      final result = await ref
          .read(walletActionsProvider.notifier)
          .requestPayout(
            amount: amount,
            accountNumber: accountNumber,
            bankCode: bankCode,
            accountName: accountName,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _money(double value) => '₦ ${value.toStringAsFixed(2)}';
}

class _PayoutFormData {
  final double amount;
  final String accountNumber;
  final String bankCode;
  final String accountName;

  const _PayoutFormData({
    required this.amount,
    required this.accountNumber,
    required this.bankCode,
    required this.accountName,
  });
}

class _PayoutDialog extends ConsumerStatefulWidget {
  final double? defaultAmount;

  const _PayoutDialog({this.defaultAmount});

  @override
  ConsumerState<_PayoutDialog> createState() => _PayoutDialogState();
}

class _PayoutDialogState extends ConsumerState<_PayoutDialog> {
  late final TextEditingController _amountController;
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  String? _selectedBankCode;
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _verificationMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.defaultAmount != null
          ? widget.defaultAmount!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banksState = ref.watch(walletBanksProvider);

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      title: const Text('Request Payout'),
      content: SizedBox(
        width: 420.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₦ ',
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  if (_isVerified) {
                    setState(() {
                      _isVerified = false;
                      _verificationMessage = null;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Account Number'),
              ),
              SizedBox(height: 10.h),
              banksState.when(
                data: (banks) {
                  if (banks.isEmpty) {
                    return const Text('No banks available');
                  }

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedBankCode,
                    decoration: const InputDecoration(labelText: 'Bank'),
                    items: banks
                        .map(
                          (bank) => DropdownMenuItem<String>(
                            value: bank.code,
                            child: Text(
                              bank.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBankCode = value;
                        _isVerified = false;
                        _verificationMessage = null;
                        _accountNameController.clear();
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (error, stackTrace) => Text(
                  'Failed to load banks',
                  style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _accountNameController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  hintText: 'Use Verify to resolve account name',
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isVerifying ? null : _verifyAccount,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify Account'),
                ),
              ),
              if (_verificationMessage != null) ...[
                SizedBox(height: 6.h),
                Text(
                  _verificationMessage!,
                  style: TextStyle(
                    color: _isVerified ? AppColors.primary : AppColors.error,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isVerified
              ? () {
                  final amount =
                      double.tryParse(_amountController.text.trim()) ?? 0;
                  final accountNumber = _accountNumberController.text.trim();
                  final bankCode = _selectedBankCode ?? '';
                  final accountName = _accountNameController.text.trim();

                  Navigator.pop(
                    context,
                    _PayoutFormData(
                      amount: amount,
                      accountNumber: accountNumber,
                      bankCode: bankCode,
                      accountName: accountName,
                    ),
                  );
                }
              : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _verifyAccount() async {
    final accountNumber = _accountNumberController.text.trim();
    final bankCode = _selectedBankCode;

    if (accountNumber.length != 10 || bankCode == null || bankCode.isEmpty) {
      setState(() {
        _isVerified = false;
        _verificationMessage =
            'Enter a valid 10-digit account number and select a bank.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationMessage = null;
    });

    try {
      final result = await ref
          .read(walletActionsProvider.notifier)
          .verifyAccount(accountNumber: accountNumber, bankCode: bankCode);

      setState(() {
        _accountNameController.text = result.accountName;
        _isVerified = result.verified;
        _verificationMessage = result.verified
            ? 'Account verified successfully.'
            : 'Unable to verify account.';
      });
    } catch (e) {
      setState(() {
        _isVerified = false;
        _verificationMessage = _friendlyErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  String _friendlyErrorMessage(Object error) {
    if (error is ApiException && error.message.trim().isNotEmpty) {
      return error.message.trim();
    }
    final raw = error.toString();
    const exceptionPrefix = 'Exception: ';
    if (raw.startsWith(exceptionPrefix)) {
      return raw.substring(exceptionPrefix.length);
    }
    return raw;
  }
}
