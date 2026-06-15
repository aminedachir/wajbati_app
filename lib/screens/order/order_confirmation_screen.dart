import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/providers.dart';
import '../../models/models.dart';
import '../order/track_order_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String paymentMethod;
  final bool isGroupOrder;
  const OrderConfirmationScreen({
    super.key,
    required this.paymentMethod,
    this.isGroupOrder = false,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late Animation<double> _scaleAnim;
  bool _saving = true;
  bool _success = false;
  AppOrder? _confirmedOrder;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _checkCtrl,
      curve: Curves.elasticOut,
    );
    // Start saving immediately
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveOrder());
  }

  Future<void> _saveOrder() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();

    AppOrder? order;
    if (auth.isLoggedIn && auth.user != null) {
      order = await orders.placeOrder(
        userId: auth.user!.uid,
        customerName: auth.user!.name,
        cart: cart,
        paymentMethod: widget.paymentMethod,
        isGroupOrder: widget.isGroupOrder,
      );
    }

    await cart.clear();

    if (mounted) {
      setState(() {
        _confirmedOrder = order;
        _saving = false;
        _success = order != null;
      });
      // Play check animation after state update
      _checkCtrl.forward();
    }
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = AppTheme.textMuted(context);

    return PopScope(
      // Prevent back navigation during saving
      canPop: !_saving,
      child: Scaffold(
        body: SafeArea(
          child: _saving
              ? _buildLoading(mutedColor)
              : _success
                  ? _buildSuccess(isDark, mutedColor)
                  : _buildError(context),
        ),
      ),
    );
  }

  Widget _buildLoading(Color mutedColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري إتمام طلبك...',
            style: GoogleFonts.cairo(fontSize: 16, color: mutedColor),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى الانتظار لحظة',
            style: GoogleFonts.cairo(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 44, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text('فشل في إتمام الطلب',
                style: GoogleFonts.cairo(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
              style: GoogleFonts.cairo(
                  fontSize: 14, color: AppTheme.textMuted(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('العودة للرئيسية',
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(bool isDark, Color mutedColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Animated check icon ──────────────────────────────
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 60,
                color: AppTheme.success,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'تم تأكيد طلبك! 🎉',
            style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDark : AppTheme.textLight),
          ),

          const SizedBox(height: 6),
          Text(
            'وجبتك في طور التحضير الآن',
            style: GoogleFonts.cairo(fontSize: 14, color: mutedColor),
          ),

          // ── Order number badge ───────────────────────────────
          if (_confirmedOrder != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_rounded,
                      size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'رقم الطلب ${_confirmedOrder!.orderNumber}',
                    style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Order summary card ───────────────────────────────
          if (_confirmedOrder != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color:
                        isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: AppTheme.secondary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _confirmedOrder!.restaurantName,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // Items
                  ..._confirmedOrder!.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                  '${item.quantity}× ${item.nameAr.isNotEmpty ? item.nameAr : item.name}',
                                  style: GoogleFonts.cairo(
                                      fontSize: 13, color: mutedColor),
                                  overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${(item.price * item.quantity).toInt()} د.ج',
                                style: GoogleFonts.cairo(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي',
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('${_confirmedOrder!.total.toInt()} د.ج',
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppTheme.primary)),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // ── Delivery estimate ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.secondary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delivery_dining_rounded,
                    size: 32, color: AppTheme.secondary),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الوقت المتوقع للوصول',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mutedColor)),
                    Text('30 – 45 دقيقة',
                        style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondary)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Track button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _confirmedOrder == null
                  ? null
                  : () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TrackOrderScreen(order: _confirmedOrder!),
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('تتبع طلبي',
                  style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),

          const SizedBox(height: 12),

          // ── Back to home ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('العودة للرئيسية',
                  style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
