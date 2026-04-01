import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class TrackOrderScreen extends StatelessWidget {
  final AppOrder order;
  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    // Derive steps from the order status
    final steps = _buildSteps(order.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order ${order.orderNumber}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Animation Header ─────────────────────────────
            Container(
              height: 220,
              width: double.infinity,
              color: AppTheme.secondary.withOpacity(0.05),
              child: Center(
                child: Lottie.network(
                  'https://assets5.lottiefiles.com/packages/lf20_m60yqnps.json',
                  width: 200,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.delivery_dining_rounded,
                    size: 100,
                    color: AppTheme.secondary,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Estimated Delivery ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated Delivery',
                              style: GoogleFonts.cairo(
                                  fontSize: 14, color: mutedColor)),
                          Text(
                            _estimatedTime(),
                            style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.timer_outlined,
                            color: AppTheme.primary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Order Summary Card ─────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? AppTheme.darkDivider
                              : AppTheme.lightDivider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.restaurant_rounded,
                                  color: AppTheme.secondary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(order.restaurantName,
                                  style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ),
                            Text(order.orderNumber,
                                style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Items list
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item.quantity}× ${item.name}',
                                    style: GoogleFonts.cairo(
                                        fontSize: 13, color: mutedColor),
                                  ),
                                  Text(
                                    '${(item.price * item.quantity).toInt()} DA',
                                    style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppTheme.textDark
                                            : AppTheme.textLight),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            Text('${order.total.toInt()} DA',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppTheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Tracking Steps ─────────────────────────
                  Text('Order Status',
                      style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppTheme.textDark : AppTheme.textLight)),
                  const SizedBox(height: 16),

                  ...List.generate(steps.length, (index) {
                    final step = steps[index];
                    final isLast = index == steps.length - 1;
                    final isDone = step['isDone'] as bool;
                    final isActive = step['isActive'] as bool;

                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppTheme.success
                                      : isActive
                                          ? AppTheme.primary
                                          : (isDark
                                              ? AppTheme.darkDivider
                                              : AppTheme.lightDivider),
                                  shape: BoxShape.circle,
                                ),
                                child: isDone
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : isActive
                                        ? const Icon(Icons.circle,
                                            size: 10, color: Colors.white)
                                        : null,
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: isDone
                                        ? AppTheme.success
                                        : (isDark
                                            ? AppTheme.darkDivider
                                            : AppTheme.lightDivider),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['title'] as String,
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: isDone || isActive
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isDone
                                          ? AppTheme.success
                                          : isActive
                                              ? AppTheme.primary
                                              : mutedColor,
                                    ),
                                  ),
                                  Text(
                                    step['subtitle'] as String,
                                    style: GoogleFonts.cairo(
                                        fontSize: 12, color: mutedColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 32),

                  // ── Delivery Driver ────────────────────────
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.secondary.withOpacity(0.1),
                        child: const Icon(Icons.person,
                            color: AppTheme.secondary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ahmed Mohamed',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            Text('Your Delivery Courier',
                                style: GoogleFonts.cairo(
                                    fontSize: 13, color: mutedColor)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone_in_talk_rounded,
                            color: AppTheme.success),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.success.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Order placed time ──────────────────────
                  Center(
                    child: Text(
                      'Ordered ${order.formattedDate}',
                      style: GoogleFonts.cairo(fontSize: 12, color: mutedColor),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build tracking steps based on the real order status
  List<Map<String, dynamic>> _buildSteps(String status) {
    const allStatuses = [
      'Preparing',
      'Ready',
      'Out for Delivery',
      'Delivered',
    ];
    final currentIndex = allStatuses.indexOf(status);

    return [
      {
        'title': 'Order Placed',
        'subtitle': 'We received your order',
        'isDone': true,
        'isActive': false,
      },
      {
        'title': 'Preparing',
        'subtitle': 'Restaurant is preparing your food',
        'isDone': currentIndex > 0,
        'isActive': currentIndex == 0,
      },
      {
        'title': 'Ready for Pickup',
        'subtitle': 'Food ready, waiting for courier',
        'isDone': currentIndex > 1,
        'isActive': currentIndex == 1,
      },
      {
        'title': 'Out for Delivery',
        'subtitle': 'Courier is on the way',
        'isDone': currentIndex > 2,
        'isActive': currentIndex == 2,
      },
      {
        'title': 'Delivered',
        'subtitle': 'Enjoy your meal! 🎉',
        'isDone': currentIndex >= 3,
        'isActive': false,
      },
    ];
  }

  String _estimatedTime() {
    final eta = order.createdAt.add(const Duration(minutes: 35));
    final h = eta.hour.toString().padLeft(2, '0');
    final m = eta.minute.toString().padLeft(2, '0');
    return '$h:$m (≈35 min)';
  }
}
