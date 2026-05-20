import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/providers.dart';
import 'order_confirmation_screen.dart';

class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  String _paymentMethod = 'Cash'; // 'Cash' | 'E-Payment' | 'Combined'
  bool _isGroupOrder = false;

  void _handleConfirm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          paymentMethod: _paymentMethod,
          isGroupOrder: _isGroupOrder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = AppTheme.textMuted(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طريقة الدفع',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodTile(
              title: 'دفع نقدي عند الاستلام',
              method: 'Cash',
              icon: Icons.money_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              title: 'دفع إلكتروني (CIB / الذهبية)',
              method: 'E-Payment',
              icon: Icons.credit_card_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              title: 'دفع مشترك (نقدي + إلكتروني)',
              method: 'Combined',
              icon: Icons.account_balance_wallet_rounded,
              isDark: isDark,
            ),

            if (_paymentMethod != 'Cash') _buildCreditCardForm(isDark),

            const SizedBox(height: 32),
            Text(
              'توفير التوصيل',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text('طلب جماعي / مشاركة التوصيل',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(
                  'انضم لمستخدمين في منطقتك لتقليل تكلفة التوصيل',
                  style: GoogleFonts.cairo(fontSize: 12, color: mutedColor)),
              value: _isGroupOrder,
              onChanged: (v) => setState(() => _isGroupOrder = v),
              secondary: const Icon(Icons.people_outline_rounded,
                  color: AppTheme.secondary),
              activeColor: AppTheme.primary,
            ),

            const SizedBox(height: 32),
            // Promo Code Field
            TextFormField(
              decoration: InputDecoration(
                labelText: 'رمز الخصم (اختياري)',
                prefixIcon: const Icon(Icons.local_offer_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),

            const SizedBox(height: 32),
            // Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملخص الطلب',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('قيمة المشتريات', cart.subtotal, mutedColor),
                  const SizedBox(height: 8),
                  _buildSummaryRow('رسوم التوصيل', cart.deliveryFee, mutedColor),
                  const SizedBox(height: 8),
                  if (cart.promoDiscount > 0)
                    _buildSummaryRow('خصم الرمز الترويجي', -cart.promoDiscount, Colors.green),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        '${cart.total.toStringAsFixed(0)} د.ج',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleConfirm,
                child: Text(
                  'تأكيد الطلب',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(color: textColor)),
        Text(
          '${value.toStringAsFixed(0)} د.ج',
          style: GoogleFonts.cairo(color: textColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCreditCardForm(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard.withValues(alpha: 0.5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بيانات البطاقة البنكية',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'رقم البطاقة (الذهبية أو CIB)',
              hintText: '0000 0000 0000 0000',
              prefixIcon: const Icon(Icons.credit_card),
              labelStyle: GoogleFonts.cairo(fontSize: 13),
              hintStyle: const TextStyle(fontSize: 13),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'تاريخ الانتهاء',
                    hintText: 'MM/YY',
                    labelStyle: GoogleFonts.cairo(fontSize: 13),
                    hintStyle: const TextStyle(fontSize: 13),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'رمز CVV',
                    hintText: '123',
                    labelStyle: GoogleFonts.cairo(fontSize: 13),
                    hintStyle: const TextStyle(fontSize: 13),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required String method,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.05)
              : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.cairo(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  )),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
            if (!isSelected)
              Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
