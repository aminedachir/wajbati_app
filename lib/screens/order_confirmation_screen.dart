import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/providers.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _saving = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    _saveOrder();
  }

  Future<void> _saveOrder() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();

    if (auth.isLoggedIn) {
      await orders.placeOrder(userId: auth.user!.uid, cart: cart);
    }

    cart.clear();

    if (mounted) {
      setState(() {
        _saving = false;
        _saved = true;
      });
      Future.delayed(const Duration(milliseconds: 300), () => _ctrl.forward());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _saving
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primary),
                      const SizedBox(height: 20),
                      Text('Confirming your order...',
                          style: GoogleFonts.cairo(
                              fontSize: 15, color: AppTheme.textMuted)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scale,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded,
                              size: 60, color: AppTheme.success),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Order Confirmed!',
                          style: GoogleFonts.cairo(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 8),
                      Text('Your order is being prepared',
                          style: GoogleFonts.cairo(
                              fontSize: 15, color: AppTheme.textMuted)),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.secondary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delivery_dining_rounded,
                                size: 28, color: AppTheme.secondary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Estimated arrival',
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: AppTheme.textMuted)),
                                Text('30 - 45 minutes',
                                    style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.secondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                          child: const Text('Back to Home'),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}