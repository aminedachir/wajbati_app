import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'restaurant_login_screen.dart';

class RolePickerScreen extends StatefulWidget {
  const RolePickerScreen({super.key});
  @override
  State<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends State<RolePickerScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _cardCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;
  int? _hoveredCard;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _cardSlide = Tween<double>(begin: 80, end: 0).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _cardCtrl.forward(); });
  }

  @override
  void dispose() { _bgCtrl.dispose(); _cardCtrl.dispose(); _floatCtrl.dispose(); super.dispose(); }

  void _goClient() {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, anim, __) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: const LoginScreen(),
      ),
      transitionDuration: const Duration(milliseconds: 450),
    ));
  }

  void _goRestaurant() {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, anim, __) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: const RestaurantLoginScreen(),
      ),
      transitionDuration: const Duration(milliseconds: 450),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        AnimatedBuilder(animation: _bgCtrl, builder: (_, __) => Container(
          decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment(-1 + _bgCtrl.value * 0.4, -1),
            end: Alignment(1, 1 - _bgCtrl.value * 0.3),
            colors: const [Color(0xFF0F0F23), Color(0xFF1B1B35), Color(0xFF0F0F23)],
          )),
        )),
        AnimatedBuilder(animation: _floatCtrl, builder: (_, __) {
          final t = _floatCtrl.value;
          return Stack(children: [
            Positioned(top: size.height * 0.08 + sin(t * pi) * 14, left: size.width * 0.62,
              child: _Orb(size: 200, color: AppTheme.primary.withValues(alpha: 0.13))),
            Positioned(top: size.height * 0.55 + cos(t * pi) * 10, left: -50,
              child: _Orb(size: 170, color: AppTheme.secondary.withValues(alpha: 0.12))),
            Positioned(top: size.height * 0.30 + sin(t * pi + 1) * 8, right: -30,
              child: _Orb(size: 130, color: AppTheme.accent.withValues(alpha: 0.08))),
          ]);
        }),
        SafeArea(
          child: AnimatedBuilder(
            animation: _cardCtrl,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _cardSlide.value),
                child: FadeTransition(
                  opacity: _cardFade,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(children: [
                        const SizedBox(height: 48),
                        _LogoSection(floatCtrl: _floatCtrl),
                        const SizedBox(height: 48),
                        Text('من أنت؟', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9))),
                        const SizedBox(height: 6),
                        Text('اختر طريقة الدخول المناسبة لك', style: GoogleFonts.cairo(fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
                        const SizedBox(height: 36),
                        _RoleCard(index: 0, hovered: _hoveredCard == 0, icon: Icons.person_rounded, emoji: '🧑‍💻', title: 'زبون',
                          subtitle: 'اطلب وجبتك المفضلة\nمن أفضل المطاعم',
                          gradientColors: const [Color(0xFF1565C0), Color(0xFF1B4FA8)],
                          glowColor: AppTheme.secondary, onTap: _goClient, onHover: (v) => setState(() => _hoveredCard = v ? 0 : null)),
                        const SizedBox(height: 16),
                        _RoleCard(index: 1, hovered: _hoveredCard == 1, icon: Icons.storefront_rounded, emoji: '🍽️', title: 'مطعم / محل',
                          subtitle: 'أدر طلباتك وتوصيلاتك\nمن لوحة التحكم',
                          gradientColors: const [Color(0xFFB71C1C), Color(0xFFE8231A)],
                          glowColor: AppTheme.primary, onTap: _goRestaurant, onHover: (v) => setState(() => _hoveredCard = v ? 1 : null)),
                        const SizedBox(height: 60),
                        Text('وجبتي — طلبك ساهل، وطعامك واصل',
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withValues(alpha: 0.3))),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _LogoSection extends StatelessWidget {
  final AnimationController floatCtrl;
  const _LogoSection({required this.floatCtrl});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: floatCtrl, builder: (_, __) => Transform.translate(
      offset: Offset(0, sin(floatCtrl.value * pi) * 5),
      child: Column(children: [
        Container(width: 88, height: 88,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFFB71C1C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.45), blurRadius: 32, spreadRadius: 2)]),
          child: Image.asset('assets/logos/logow.jpg', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_menu_rounded, size: 40, color: Colors.white))),
        const SizedBox(height: 14),
        Text('وجبتي', style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white,
          shadows: [Shadow(color: AppTheme.primary.withValues(alpha: 0.6), blurRadius: 18)])),
      ]),
    ));
  }
}

class _RoleCard extends StatefulWidget {
  final int index; final bool hovered; final IconData icon;
  final String emoji, title, subtitle; final List<Color> gradientColors;
  final Color glowColor; final VoidCallback onTap; final ValueChanged<bool> onHover;
  const _RoleCard({required this.index, required this.hovered, required this.icon, required this.emoji,
    required this.title, required this.subtitle, required this.gradientColors, required this.glowColor,
    required this.onTap, required this.onHover});
  @override State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  @override void initState() { super.initState(); _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120)); }
  @override void dispose() { _pressCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return MouseRegion(onEnter: (_) => widget.onHover(true), onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedBuilder(animation: _pressCtrl, builder: (_, __) => Transform.scale(
          scale: 1.0 - _pressCtrl.value * 0.03,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic, height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: widget.glowColor.withValues(alpha: widget.hovered ? 0.55 : 0.28),
                blurRadius: widget.hovered ? 32 : 18, spreadRadius: widget.hovered ? 2 : 0, offset: const Offset(0, 8))],
              border: Border.all(color: Colors.white.withValues(alpha: widget.hovered ? 0.25 : 0.08), width: 1.5),
            ),
            child: Row(children: [
              const SizedBox(width: 24),
              AnimatedContainer(duration: const Duration(milliseconds: 200), width: 62, height: 62,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: widget.hovered ? 0.22 : 0.14)),
                child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 28)))),
              const SizedBox(width: 18),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 3),
                Text(widget.subtitle, style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withValues(alpha: 0.75), height: 1.4)),
              ])),
              AnimatedContainer(duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(widget.hovered ? 4 : 0, 0, 0),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.15)),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.white))),
              const SizedBox(width: 20),
            ]),
          ),
        )),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size; final Color color;
  const _Orb({required this.size, required this.color});
  @override Widget build(BuildContext context) => Container(width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])));
}

