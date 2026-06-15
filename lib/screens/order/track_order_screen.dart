import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

import '../../screens/home/home_screen.dart';

class TrackOrderScreen extends StatelessWidget {
  final AppOrder order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = AppTheme.textMuted(context);

    final items = order.items;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('تتبع الطلب',
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700, fontSize: 18)),
                Text('طلب رقم #${order.orderNumber}',
                    style: GoogleFonts.cairo(fontSize: 12, color: mutedColor)),
              ],
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Success Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.secondary.withValues(alpha: 0.2),
                          width: 2),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('تم استلام طلبك!',
                    style: GoogleFonts.cairo(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(
                  'جاري تحضير أشهى المأكولات الأصيلة من\nمطبخنا إليك مباشرة.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(color: mutedColor, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Horizontal Timeline
                _buildHorizontalTimeline(isDark, mutedColor),
                const SizedBox(height: 32),

                // Map Card with Animation
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Stack(
                    children: [
                      // Lottie animation as Map Placeholder
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Lottie.asset(
                            'assets/photos/animations/order-complete-car-delivery-animation.json',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.map,
                                    size: 50, color: Colors.grey)),
                          ),
                        ),
                      ),
                      // Driver Info Card
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.phone_in_talk,
                                      color: Colors.white, size: 20),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('أحمد محمود',
                                        style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('4.9 (توصيل سريع)',
                                            style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                color: mutedColor)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 14),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.secondary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ETA Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primary
                        .withValues(alpha: 0.9), // Primary color matching app
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الوقت المتوقع للوصول',
                                style: GoogleFonts.cairo(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('25-35',
                                    style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1)),
                                const SizedBox(width: 4),
                                Text('دقيقة',
                                    style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Address and Payment row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        isDark: isDark,
                        title: 'طريقة الدفع',
                        subtitle: order.paymentMethod == 'Cash'
                            ? 'الدفع عند الاستلام'
                            : 'دفع إلكتروني',
                        icon: Icons.money_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        isDark: isDark,
                        title: 'عنوان التوصيل',
                        subtitle: 'الشارع الرئيسي\nالمدينة',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Order Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ملخص الطلب',
                          style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary)),
                      const SizedBox(height: 16),
                      ...items.map((item) {
                        final q = item.quantity;
                        final price = item.price;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('${item.name} × $q',
                                    style: GoogleFonts.cairo()),
                              ),
                              Text('${(price * q).toStringAsFixed(0)} د.ج',
                                  style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الإجمالي',
                              style: GoogleFonts.cairo(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${order.total.toStringAsFixed(0)} د.ج',
                              style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildInfoCard(
      {required bool isDark,
      required String title,
      required String subtitle,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCard
            : AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.secondary, size: 24),
          const SizedBox(height: 8),
          Text(title,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.grey : Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style:
                  GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHorizontalTimeline(bool isDark, Color mutedColor) {
    final steps = [
      {'title': 'تم استلام الطلب', 'icon': Icons.check, 'active': true},
      {'title': 'جاري الطهي', 'icon': Icons.soup_kitchen, 'active': true},
      {'title': 'في الطريق', 'icon': Icons.two_wheeler, 'active': false},
      {'title': 'تم التوصيل', 'icon': Icons.home, 'active': false},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 == 1) {
          final active = steps[index ~/ 2 + 1]['active'] as bool;
          return Expanded(
            child: Container(
              height: 2,
              color: active
                  ? AppTheme.secondary
                  : (isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
            ),
          );
        }
        final step = steps[index ~/ 2];
        final active = step['active'] as bool;
        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.secondary
                    : (isDark ? AppTheme.darkCard : Colors.grey.shade200),
                shape: BoxShape.circle,
              ),
              child: Icon(step['icon'] as IconData,
                  size: 18, color: active ? Colors.white : Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              step['title'] as String,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active
                    ? (isDark ? Colors.white : AppTheme.secondary)
                    : mutedColor,
              ),
            ),
          ],
        );
      }),
    );
  }
}
