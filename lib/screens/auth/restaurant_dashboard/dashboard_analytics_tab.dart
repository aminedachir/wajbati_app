import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import 'restaurant_order_model.dart';

class DashboardAnalyticsTab extends StatefulWidget {
  final List<DashOrder> orders;
  final String restaurantId;
  final Color accentColor;

  const DashboardAnalyticsTab({
    super.key,
    required this.orders,
    required this.restaurantId,
    required this.accentColor,
  });

  @override
  State<DashboardAnalyticsTab> createState() => _DashboardAnalyticsTabState();
}

class _DashboardAnalyticsTabState extends State<DashboardAnalyticsTab>
    with TickerProviderStateMixin {
  late AnimationController _barCtrl;
  late AnimationController _pieCtrl;
  late List<double> _weeklyRevenue;
  late List<int> _hourlyCounts;

  @override
  void initState() {
    super.initState();
    _weeklyRevenue = generateWeeklyRevenue(widget.restaurantId);
    _hourlyCounts = generateHourlyCounts(widget.restaurantId);
    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _pieCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  }

  @override
  void dispose() { _barCtrl.dispose(); _pieCtrl.dispose(); super.dispose(); }

  double get _totalRevenue => widget.orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (s, o) => s + o.total);

  Map<String, int> get _statusBreakdown {
    final map = <String, int>{};
    for (final o in widget.orders) {
      final key = o.status.labelAr;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    final hours = ['9ص', '10ص', '11ص', '12م', '1م', '2م', '3م', '4م', '5م', '6م', '7م', '8م'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        // ── KPI Cards ──────────────────────────────────────
        Row(children: [
          _KpiCard(label: 'إيراد اليوم', value: '${_totalRevenue.toStringAsFixed(0)} د.ج',
            icon: '💰', color: AppTheme.success),
          const SizedBox(width: 10),
          _KpiCard(label: 'إجمالي الطلبات', value: '${widget.orders.length}',
            icon: '📦', color: widget.accentColor),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _KpiCard(
            label: 'معدل الإنجاز',
            value: '${widget.orders.isEmpty ? 0 : (widget.orders.where((o) => o.status == OrderStatus.delivered).length / widget.orders.length * 100).round()}%',
            icon: '✅', color: Colors.blueAccent,
          ),
          const SizedBox(width: 10),
          _KpiCard(
            label: 'متوسط الطلب',
            value: widget.orders.isEmpty ? '0 د.ج' : '${(widget.orders.fold(0.0, (s, o) => s + o.total) / widget.orders.length).toStringAsFixed(0)} د.ج',
            icon: '📊', color: Colors.purpleAccent,
          ),
        ]),

        const SizedBox(height: 20),

        // ── Weekly Revenue Bar Chart ───────────────────────
        _ChartCard(
          title: 'إيرادات الأسبوع',
          subtitle: 'آخر 7 أيام',
          child: AnimatedBuilder(
            animation: _barCtrl,
            builder: (_, __) => _BarChart(
              values: _weeklyRevenue,
              labels: days,
              color: widget.accentColor,
              progress: CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic).value,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Hourly orders chart ────────────────────────────
        _ChartCard(
          title: 'الطلبات حسب الساعة',
          subtitle: 'اليوم',
          child: AnimatedBuilder(
            animation: _barCtrl,
            builder: (_, __) => _BarChart(
              values: _hourlyCounts.map((v) => v.toDouble()).toList(),
              labels: hours,
              color: Colors.purpleAccent,
              progress: CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic).value,
              smallLabels: true,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Status Pie chart ──────────────────────────────
        _ChartCard(
          title: 'توزيع حالات الطلبات',
          subtitle: 'نظرة عامة',
          child: AnimatedBuilder(
            animation: _pieCtrl,
            builder: (_, __) => _PieChart(
              data: _statusBreakdown,
              progress: CurvedAnimation(parent: _pieCtrl, curve: Curves.easeOutCubic).value,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Top items ─────────────────────────────────────
        _TopItemsCard(orders: widget.orders, accentColor: widget.accentColor),
      ],
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value,
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(label,
            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }
}

// ── Chart card wrapper ────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _ChartCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title,
            style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white))),
          Text(subtitle,
            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.35))),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

// ── Bar Chart (CustomPainter) ─────────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double progress;
  final bool smallLabels;
  const _BarChart({required this.values, required this.labels, required this.color, required this.progress, this.smallLabels = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _BarChartPainter(values: values, labels: labels, color: color, progress: progress, smallLabels: smallLabels),
        size: const Size(double.infinity, 160),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double progress;
  final bool smallLabels;
  _BarChartPainter({required this.values, required this.labels, required this.color, required this.progress, required this.smallLabels});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce(max);
    if (maxVal == 0) return;

    final barWidth = (size.width / values.length) * 0.55;
    final gap = size.width / values.length;
    final chartHeight = size.height - 28;
    final labelStyle = TextStyle(
      color: Colors.white.withOpacity(0.45),
      fontSize: smallLabels ? 8 : 9,
      fontFamily: 'Cairo',
    );

    for (int i = 0; i < values.length; i++) {
      final x = gap * i + gap / 2;
      final barH = (values[i] / maxVal) * chartHeight * progress;
      final y = chartHeight - barH;

      // Bar background
      final bgPaint = Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.fill;
      final bgRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x - barWidth / 2, 0, barWidth, chartHeight),
        topLeft: const Radius.circular(6), topRight: const Radius.circular(6),
      );
      canvas.drawRRect(bgRRect, bgPaint);

      // Bar fill
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [color, color.withOpacity(0.5)],
        ).createShader(Rect.fromLTWH(x - barWidth / 2, y, barWidth, barH))
        ..style = PaintingStyle.fill;
      if (barH > 0) {
        final barRRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x - barWidth / 2, y, barWidth, barH),
          topLeft: const Radius.circular(6), topRight: const Radius.circular(6),
        );
        canvas.drawRRect(barRRect, barPaint);
      }

      // Label
      if (i < labels.length) {
        final tp = TextPainter(
          text: TextSpan(text: labels[i], style: labelStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout(maxWidth: gap);
        tp.paint(canvas, Offset(x - tp.width / 2, chartHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.progress != progress;
}

// ── Pie chart ─────────────────────────────────────────────────────────────────
class _PieChart extends StatelessWidget {
  final Map<String, int> data;
  final double progress;
  const _PieChart({required this.data, required this.progress});

  @override
  Widget build(BuildContext context) {
    final colors = [AppTheme.success, Colors.orangeAccent, Colors.purpleAccent, Colors.blueAccent, Colors.redAccent, Colors.cyan];
    final entries = data.entries.toList();
    final total = data.values.fold(0, (s, v) => s + v);

    return Row(
      children: [
        SizedBox(
          width: 130, height: 130,
          child: CustomPaint(
            painter: _PieChartPainter(
              values: entries.map((e) => e.value.toDouble()).toList(),
              colors: List.generate(entries.length, (i) => colors[i % colors.length]),
              progress: progress,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              final pct = total == 0 ? 0 : (entries[i].value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 10, height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors[i % colors.length])),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entries[i].key,
                    style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)))),
                  Text('$pct%',
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                ]),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double progress;
  _PieChartPainter({required this.values, required this.colors, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (s, v) => s + v);
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    double startAngle = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi * progress;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, false, paint);
      startAngle += (values[i] / total) * 2 * pi;
    }

    // Center hole label
    final tp = TextPainter(
      text: TextSpan(
        text: '${values.fold(0.0, (s, v) => s + v).round()}',
        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => old.progress != progress;
}

// ── Top Items ─────────────────────────────────────────────────────────────────
class _TopItemsCard extends StatelessWidget {
  final List<DashOrder> orders;
  final Color accentColor;
  const _TopItemsCard({required this.orders, required this.accentColor});

  Map<String, int> get _topItems {
    final counts = <String, int>{};
    for (final o in orders) {
      for (final item in o.items) {
        counts[item.name] = (counts[item.name] ?? 0) + item.quantity;
      }
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  @override
  Widget build(BuildContext context) {
    final items = _topItems;
    final maxCount = items.isEmpty ? 1 : items.values.first;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('الأصناف الأكثر طلباً',
          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 16),
        ...items.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(e.key,
                style: GoogleFonts.cairo(fontSize: 13, color: Colors.white))),
              Text('${e.value} طلب',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700,
                  color: accentColor)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: e.value / maxCount,
                backgroundColor: Colors.white.withValues(alpha: 0.07),
                valueColor: AlwaysStoppedAnimation(accentColor),
                minHeight: 6,
              ),
            ),
          ]),
        )),
      ]),
    );
  }
}
