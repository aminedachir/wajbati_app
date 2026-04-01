import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/providers.dart';
import '../order/checkout_address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoCtrl = TextEditingController();

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final cart = context.read<CartProvider>();
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;

    final valid = cart.applyPromoCode(code);
    if (valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Promo code applied! -${cart.promoDiscount.toInt()} DA',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Invalid promo code', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Pre-fill promo controller if already applied
    if (cart.promoApplied && _promoCtrl.text != cart.promoCode) {
      _promoCtrl.text = cart.promoCode;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (cart.itemCount > 0)
            TextButton(
              onPressed: () => cart.clear(),
              child: Text('Clear',
                  style: GoogleFonts.cairo(
                      color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmpty(context)
          : Column(
              children: [
                // Restaurant info banner
                if (cart.restaurant != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.secondary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant_rounded,
                            size: 16, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cart.restaurant!.name,
                            style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final ci = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isLight
                                  ? AppTheme.lightDivider
                                  : AppTheme.darkDivider),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                ci.item.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: Icon(Icons.fastfood,
                                      color: isLight
                                          ? AppTheme.textMutedLight
                                          : AppTheme.textMutedDark),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ci.item.name,
                                    style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isLight
                                            ? AppTheme.textLight
                                            : AppTheme.textDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${ci.item.price.toInt()} DA each',
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: isLight
                                            ? AppTheme.textMutedLight
                                            : AppTheme.textMutedDark),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quantity controls
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => cart.decreaseItem(ci.item.id),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppTheme.primary),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.remove,
                                        size: 14, color: AppTheme.primary),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    '${ci.quantity}',
                                    style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      cart.addItem(ci.item, cart.restaurant!),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Summary + promo + checkout
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 20,
                            offset: const Offset(0, -4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SummaryRow(
                            label: 'Subtotal',
                            value: '${cart.subtotal.toInt()} DA'),
                        const SizedBox(height: 8),
                        _SummaryRow(
                            label: 'Delivery',
                            value: '${cart.deliveryFee.toInt()} DA'),

                        // ── Promo Code Section ──────────────────
                        const SizedBox(height: 12),
                        if (!cart.promoApplied)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoCtrl,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: GoogleFonts.cairo(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Promo code (e.g. WAJBATI)',
                                    hintStyle: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: isLight
                                            ? AppTheme.textMutedLight
                                            : AppTheme.textMutedDark),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: isLight
                                              ? AppTheme.lightDivider
                                              : AppTheme.darkDivider),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: isLight
                                              ? AppTheme.lightDivider
                                              : AppTheme.darkDivider),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _applyPromo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  elevation: 0,
                                ),
                                child: Text('Apply',
                                    style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          )
                        else
                          // Promo applied row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.success.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer_rounded,
                                    color: AppTheme.success, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${cart.promoCode} — -${cart.promoDiscount.toInt()} DA',
                                    style: GoogleFonts.cairo(
                                        color: AppTheme.success,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    cart.removePromo();
                                    _promoCtrl.clear();
                                  },
                                  child: const Icon(Icons.close,
                                      size: 16, color: AppTheme.success),
                                ),
                              ],
                            ),
                          ),

                        if (cart.promoApplied) ...[
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Discount',
                            value: '-${cart.promoDiscount.toInt()} DA',
                            valueColor: AppTheme.success,
                          ),
                        ],

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                              color: isLight
                                  ? AppTheme.lightDivider
                                  : AppTheme.darkDivider),
                        ),
                        _SummaryRow(
                          label: 'Total',
                          value: '${cart.total.toInt()} DA',
                          isBold: true,
                        ),
                        const SizedBox(height: 16),

                        // Checkout button or closed warning
                        if (cart.restaurant?.isOpen != true)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.restaurant_outlined,
                                    color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Restaurant closed — cannot checkout',
                                    style: GoogleFonts.cairo(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const CheckoutAddressScreen())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(
                                'Continue to Checkout',
                                style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 80,
                color:
                    (isLight ? AppTheme.textMutedLight : AppTheme.textMutedDark)
                        .withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('Your cart is empty',
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isLight
                        ? AppTheme.textMutedLight
                        : AppTheme.textMutedDark)),
            const SizedBox(height: 8),
            Text(
              'Add items from a restaurant to get started',
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isLight
                      ? AppTheme.textMutedLight
                      : AppTheme.textMutedDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Browse Restaurants',
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
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: isBold
                    ? (isLight ? AppTheme.textLight : AppTheme.textDark)
                    : (isLight
                        ? AppTheme.textMutedLight
                        : AppTheme.textMutedDark))),
        Text(value,
            style: GoogleFonts.cairo(
                fontSize: isBold ? 18 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ??
                    (isBold
                        ? AppTheme.primary
                        : (isLight ? AppTheme.textLight : AppTheme.textDark)))),
      ],
    );
  }
}
