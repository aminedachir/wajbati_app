import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/providers.dart';
import '../../utils/theme_utils.dart';
import '../order/track_order_screen.dart';
import '../orders/orders_screen.dart';
import '../favorites/favorites_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ordersProvider = context.watch<OrdersProvider>();
    final themeNotifier = context.read<ThemeNotifier>();
    final isDark = ThemeNotifier.isDarkMode(context);
    final mutedColor = AppTheme.textMuted(context);

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('حسابي',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      size: 44, color: AppTheme.primary),
                ),
                const SizedBox(height: 20),
                Text('سجل دخولك إلى حسابك',
                    style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppTheme.textDark : AppTheme.textLight)),
                const SizedBox(height: 8),
                Text(
                  'الوصول إلى طلباتك والمفضلة والإعدادات',
                  style: GoogleFonts.cairo(fontSize: 14, color: mutedColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text('تسجيل الدخول',
                        style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Guest user ────────────────────────────────────────────
    if (auth.isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: Text('حسابي',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Guest header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        size: 30, color: AppTheme.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.displayName,
                            style: GoogleFonts.cairo(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('حساب ضيف',
                            style: GoogleFonts.cairo(
                                fontSize: 13, color: mutedColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Upgrade prompt
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.1),
                    AppTheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إنشاء حساب جديد',
                      style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                  const SizedBox(height: 4),
                  Text(
                    'احفظ طلباتك والمفضلة واحصل على عروض حصرية!',
                    style: GoogleFonts.cairo(fontSize: 13, color: mutedColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            auth.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (r) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('تسجيل الدخول',
                              style: GoogleFonts.cairo(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            auth.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (r) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('إنشاء حساب',
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Theme toggle (available for guests too)
            _ThemeToggle(
                isDark: isDark,
                mutedColor: mutedColor,
                themeNotifier: themeNotifier),
          ],
        ),
      );
    }

    // ── Logged in user ────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: Text('حسابي',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    auth.initials,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.displayName,
                          style: GoogleFonts.cairo(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(auth.email,
                          style: GoogleFonts.cairo(
                              fontSize: 13, color: mutedColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _SectionLabel(label: 'حسابي', isDark: isDark),
          const SizedBox(height: 10),

          // Track Order
          _ProfileTile(
            icon: Icons.local_shipping_outlined,
            iconColor: AppTheme.secondary,
            title: 'تتبع طلبي',
            subtitle: ordersProvider.orders.isNotEmpty
                ? 'آخر طلب: ${ordersProvider.orders.first.orderNumber}'
                : 'لا توجد طلبات نشطة',
            isDark: isDark,
            onTap: () {
              if (ordersProvider.orders.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TrackOrderScreen(order: ordersProvider.orders.first),
                  ),
                );
              } else {
                // Load orders first then navigate
                final userId = auth.user?.uid;
                if (userId != null) {
                  ordersProvider.loadOrders(userId).then((_) {
                    if (ordersProvider.orders.isNotEmpty && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackOrderScreen(
                              order: ordersProvider.orders.first),
                        ),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('لا توجد طلبات لتتبعها حالياً',
                              style: GoogleFonts.cairo()),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  });
                }
              }
            },
          ),

          _ProfileTile(
            icon: Icons.receipt_long_rounded,
            iconColor: AppTheme.primary,
            title: 'سجل الطلبات',
            subtitle: '${ordersProvider.orders.length} طلب',
            isDark: isDark,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrdersScreen())),
          ),

          _ProfileTile(
            icon: Icons.location_on_outlined,
            iconColor: Colors.green,
            title: 'العناوين المحفوظة',
            subtitle: 'إدارة مواقع التوصيل الخاصة بك',
            isDark: isDark,
            onTap: () {},
          ),

          _ProfileTile(
            icon: Icons.favorite_border_rounded,
            iconColor: Colors.pink,
            title: 'المفضلة',
            subtitle: 'المطاعم والوجبات المفضلة لديك',
            isDark: isDark,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),

          const SizedBox(height: 20),
          _SectionLabel(label: 'التفضيلات', isDark: isDark),
          const SizedBox(height: 10),

          _ThemeToggle(
              isDark: isDark,
              mutedColor: mutedColor,
              themeNotifier: themeNotifier),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),

          // Logout
          _ProfileTile(
            icon: Icons.logout_rounded,
            iconColor: Colors.red,
            title: 'تسجيل الخروج',
            subtitle: 'تسجيل الخروج من حسابك',
            isDark: isDark,
            titleColor: Colors.red,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('تسجيل الخروج',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟',
                      style: GoogleFonts.cairo()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('إلغاء',
                          style: GoogleFonts.cairo(color: mutedColor)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('خروج',
                          style: GoogleFonts.cairo(
                              color: Colors.red, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            letterSpacing: 0.5));
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;
  final Color? titleColor;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700, fontSize: 14, color: titleColor)),
        subtitle: Text(subtitle,
            style: GoogleFonts.cairo(
                fontSize: 12,
                color:
                    isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final Color mutedColor;
  final ThemeNotifier themeNotifier;

  const _ThemeToggle({
    required this.isDark,
    required this.mutedColor,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Text('الوضع الليلي',
            style:
                GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(
          isDark ? 'تفعيل الوضع المظلم المريح للعين' : 'تفعيل الوضع الفاتح',
          style: GoogleFonts.cairo(fontSize: 12, color: mutedColor),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isDark ? Colors.amber : Colors.blueGrey)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: isDark ? Colors.amber : Colors.blueGrey,
            size: 20,
          ),
        ),
        value: isDark,
        onChanged: (v) => themeNotifier.toggleTheme(v),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
