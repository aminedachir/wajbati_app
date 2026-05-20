import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Mock notification data - replace with real data from Appwrite later
  final List<_NotifItem> _notifications = [
    _NotifItem(
      icon: Icons.check_circle_rounded,
      iconColor: AppTheme.success,
      bgColor: AppTheme.success,
      title: 'تم تأكيد الطلب',
      subtitle: 'تم تأكيد طلبك من مطعم دار المدينة.',
      time: 'منذ دقيقتين',
      isRead: false,
    ),
    _NotifItem(
      icon: Icons.delivery_dining_rounded,
      iconColor: AppTheme.secondary,
      bgColor: AppTheme.secondary,
      title: 'جاري التوصيل',
      subtitle: 'طلبك من برجر هاوس في الطريق إليك!',
      time: 'منذ 15 دقيقة',
      isRead: false,
    ),
    _NotifItem(
      icon: Icons.local_offer_rounded,
      iconColor: AppTheme.primary,
      bgColor: AppTheme.primary,
      title: 'عرض خاص 🎉',
      subtitle: 'توصيل مجاني اليوم! استخدم كود WAJBATI عند الدفع.',
      time: 'منذ ساعة',
      isRead: true,
    ),
    _NotifItem(
      icon: Icons.star_rounded,
      iconColor: const Color(0xFFFFA726),
      bgColor: const Color(0xFFFFA726),
      title: 'قيم طلبك',
      subtitle: 'كيف كانت وجبتك من لا بيازا؟ اترك تقييمك الآن.',
      time: 'منذ ساعتين',
      isRead: true,
    ),
    _NotifItem(
      icon: Icons.restaurant_rounded,
      iconColor: AppTheme.primary,
      bgColor: AppTheme.primary,
      title: 'مطعم جديد',
      subtitle: 'سوشي بايا متاح الآن في منطقتك!',
      time: 'أمس',
      isRead: true,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'تحديد الكل كمقروء',
                style: GoogleFonts.cairo(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: mutedColor.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('لا توجد إشعارات بعد',
                      style:
                          GoogleFonts.cairo(fontSize: 15, color: mutedColor)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => notif.isRead = true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: notif.isRead
                          ? (isDark ? AppTheme.darkCard : Colors.white)
                          : (isDark
                              ? AppTheme.primary.withValues(alpha: 0.08)
                              : AppTheme.primary.withValues(alpha: 0.04)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notif.isRead
                            ? (isDark
                                ? AppTheme.darkDivider
                                : AppTheme.lightDivider)
                            : AppTheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: notif.bgColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(notif.icon,
                              color: notif.iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: GoogleFonts.cairo(
                                        fontWeight: notif.isRead
                                            ? FontWeight.w600
                                            : FontWeight.w700,
                                        fontSize: 14,
                                        color: isDark
                                            ? AppTheme.textDark
                                            : AppTheme.textLight,
                                      ),
                                    ),
                                  ),
                                  if (!notif.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.subtitle,
                                style: GoogleFonts.cairo(
                                    fontSize: 12, color: mutedColor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif.time,
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: mutedColor.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;
  bool isRead;

  _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
  });
}
