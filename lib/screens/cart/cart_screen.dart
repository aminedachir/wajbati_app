import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/providers.dart';
import '../../models/models.dart';
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
            '🎉 تم تطبيق الرمز! -${cart.promoDiscount.toInt()} د.ج',
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
          content: Text('❌ رمز خصم غير صالح', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showDiabeticNoteDialog(
      BuildContext context, CartProvider cart, CartItem ci) {
    final TextEditingController noteCtrl =
        TextEditingController(text: ci.diabeticNote);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_outlined,
                    color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text('تعديل الطلب لمرضى السكري',
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            Text('اكتب أي تفاصيل تهم حالتك الصحية (مثل: قليل الدسم، بدون سكر...)',
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: noteCtrl,
              autofocus: true,
              maxLines: 4,
              style: GoogleFonts.cairo(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'مثال: يرجى تحضير الوجبة بدون إضافة سكر أو دهون مشبعة.',
                hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (noteCtrl.text.trim().isNotEmpty) {
                    cart.updateDiabeticNote(ci.item.id, noteCtrl.text.trim());
                  } else {
                    // If empty, just toggle off
                    cart.toggleDiabeticRequest(ci.item.id);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('تأكيد التعديل',
                    style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
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
        title: const Text('سلة المشتريات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (cart.itemCount > 0)
            TextButton(
              onPressed: () => cart.clear(),
              child: Text('مسح',
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
                                    ci.item.nameAr.isNotEmpty ? ci.item.nameAr : ci.item.name,
                                    style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isLight
                                            ? AppTheme.textLight
                                            : AppTheme.textDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${ci.item.price.toInt()} د.ج للواحدة',
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
                            // Diabetic Request Checkbox
                            InkWell(
                              onTap: () {
                                if (!ci.isDiabeticRequest) {
                                  _showDiabeticNoteDialog(context, cart, ci);
                                } else {
                                  cart.toggleDiabeticRequest(ci.item.id);
                                }
                              },
                              child: Column(
                                children: [
                                  Checkbox(
                                    value: ci.isDiabeticRequest,
                                    onChanged: (v) {
                                      if (v == true) {
                                        _showDiabeticNoteDialog(context, cart, ci);
                                      } else {
                                        cart.toggleDiabeticRequest(ci.item.id);
                                      }
                                    },
                                    activeColor: Colors.green,
                                  ),
                                  Text(
                                    'لمرضى السكري',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      color: ci.isDiabeticRequest
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
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
              ],
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
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
                        label: 'المجموع الفرعي',
                        value: '${cart.subtotal.toInt()} د.ج'),
                    const SizedBox(height: 8),
                    _SummaryRow(
                        label: 'التوصيل',
                        value: '${cart.deliveryFee.toInt()} د.ج'),

                    const SizedBox(height: 12),
                    // Special Instructions Field
                    TextField(
                      onChanged: (v) => cart.setSpecialInstructions(v),
                      style: GoogleFonts.cairo(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'ملاحظات إضافية (مثل طلبات السكري)',
                        labelStyle: GoogleFonts.cairo(fontSize: 12),
                        prefixIcon:
                            const Icon(Icons.note_alt_outlined, size: 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),

                    // ── Promo Code Section ──────────────────
                    const SizedBox(height: 12),
                    if (!cart.promoApplied)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoCtrl,
                              textCapitalization: TextCapitalization.characters,
                              style: GoogleFonts.cairo(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'رمز الخصم (مثال: WAJBATI)',
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
                            child: Text('تطبيق',
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
                                '${cart.promoCode} — -${cart.promoDiscount.toInt()} د.ج',
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
                        label: 'الخصم',
                        value: '-${cart.promoDiscount.toInt()} د.ج',
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
                      label: 'الإجمالي',
                      value: '${cart.total.toInt()} د.ج',
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
                                'المطعم مغلق حالياً - لا يمكن إتمام الطلب',
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
                          onPressed: () {
                            final auth = context.read<AuthProvider>();
                            if (auth.isGuest || !auth.isLoggedIn) {
                              _showAuthRequiredDialog(context);
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const CheckoutAddressScreen()));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            'المتابعة لإتمام الطلب',
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
    );
  }

  void _showAuthRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Theme.of(context).cardColor,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    size: 40, color: AppTheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'تسجيل الدخول مطلوب',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'عذراً، يجب عليك تسجيل الدخول أولاً لتتمكن من إتمام الطلب وتتبع وجبتك الشهية.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppTheme.textMutedLight
                      : AppTheme.textMutedDark,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'لاحقاً',
                        style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'تسجيل الدخول',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            Text('سلة المشتريات فارغة',
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isLight
                        ? AppTheme.textMutedLight
                        : AppTheme.textMutedDark)),
            const SizedBox(height: 8),
            Text(
              'أضف بعض الوجبات الشهية من المطاعم للبدء',
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
                child: Text('تصفح المطاعم',
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
