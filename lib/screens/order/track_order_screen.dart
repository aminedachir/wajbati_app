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
    final mutedColor = AppTheme.textMuted(context);

    // Simulated status steps
    final steps = [
      {'title': 'Order Placed', 'time': '12:30 PM', 'isDone': true},
      {'title': 'Preparing Food', 'time': '12:35 PM', 'isDone': true},
      {'title': 'Out for Delivery', 'time': 'Waiting...', 'isDone': false},
      {'title': 'Delivered', 'time': 'Pending', 'isDone': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order ${order.orderNumber}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pushNamed(context,"/home"),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Map / Animation Area
            Container(
              height: 240,
              width: double.infinity,
              color: AppTheme.secondary.withOpacity(0.05),
              child: Center(
                child: Lottie.network(
                  'https://assets5.lottiefiles.com/packages/lf20_m60yqnps.json', // Delivery animation
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Delivery',
                            style: GoogleFonts.cairo(
                                fontSize: 14, color: mutedColor),
                          ),
                          Text(
                            '1:05 PM (35 min)',
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
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Tracking Steps
                  ...List.generate(steps.length, (index) {
                    final step = steps[index];
                    final isLast = index == steps.length - 1;
                    final isDone = step['isDone'] as bool;

                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppTheme.success
                                      : (isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
                                  shape: BoxShape.circle,
                                ),
                                child: isDone
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: isDone
                                        ? AppTheme.success
                                        : (isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step['title'] as String,
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                                          color: isDone 
                                              ? (isDark ? Colors.white : Colors.black)
                                              : mutedColor,
                                        ),
                                      ),
                                      Text(
                                        isDone ? 'Finished' : 'Upcoming',
                                        style: GoogleFonts.cairo(
                                            fontSize: 12, color: mutedColor),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    step['time'] as String,
                                    style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: mutedColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 40),

                  // Delivery Driver Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AppTheme.secondary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppTheme.secondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ahmed Mohamed',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
