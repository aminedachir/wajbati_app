import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import 'restaurant_order_model.dart';

class DashboardDeliveryTab extends StatelessWidget {
  final List<DashOrder> orders;
  final Color accentColor;
  final void Function(String, OrderStatus, {MockLivreur? livreur}) onUpdateStatus;

  const DashboardDeliveryTab({
    super.key,
    required this.orders,
    required this.accentColor,
    required this.onUpdateStatus,
  });

  List<DashOrder> get _activeDeliveries => orders
      .where((o) => o.status == OrderStatus.outForDelivery || o.status == OrderStatus.readyForPickup)
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // ── Livreurs Status ──────────────────────────────────
        Text('السائقون', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: mockLivreurs.map((l) => _LivreurCard(livreur: l, accentColor: accentColor)).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // ── Active Deliveries ────────────────────────────────
        Row(children: [
          Text('التوصيلات النشطة', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.purpleAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: Text('${_activeDeliveries.length}',
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.purpleAccent)),
          ),
        ]),
        const SizedBox(height: 10),

        if (_activeDeliveries.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(children: [
              const Text('🛵', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 12),
              Text('لا توجد توصيلات نشطة',
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.white60)),
            ]),
          )
        else
          ...(_activeDeliveries.map((o) => _DeliveryCard(order: o, onUpdateStatus: onUpdateStatus))),

        const SizedBox(height: 20),

        // ── Stats row ────────────────────────────────────────
        Text('إحصائيات التوصيل اليوم',
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 10),
        Row(children: [
          _StatCard(label: 'منجز', value: '${orders.where((o) => o.status == OrderStatus.delivered).length}', color: AppTheme.success, icon: '✅'),
          const SizedBox(width: 10),
          _StatCard(label: 'في الطريق', value: '${orders.where((o) => o.status == OrderStatus.outForDelivery).length}', color: Colors.purpleAccent, icon: '🛵'),
          const SizedBox(width: 10),
          _StatCard(label: 'ملغى', value: '${orders.where((o) => o.status == OrderStatus.cancelled).length}', color: Colors.redAccent, icon: '❌'),
        ]),
      ],
    );
  }
}

class _LivreurCard extends StatelessWidget {
  final MockLivreur livreur;
  final Color accentColor;
  const _LivreurCard({required this.livreur, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: livreur.available
          ? Colors.purple.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: livreur.available ? Colors.purpleAccent.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(livreur.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(livreur.name.split(' ').first,
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: livreur.available ? AppTheme.success.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(livreur.available ? 'متاح' : 'مشغول',
            style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700,
              color: livreur.available ? AppTheme.success : Colors.grey)),
        ),
      ]),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final DashOrder order;
  final void Function(String, OrderStatus, {MockLivreur? livreur}) onUpdateStatus;
  const _DeliveryCard({required this.order, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final isOut = order.status == OrderStatus.outForDelivery;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(isOut ? '🛵' : '📦', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order.orderNumber,
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(order.customerName,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
          ])),
          Text('${order.total.toStringAsFixed(0)} د.ج',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.location_on_rounded, size: 13, color: Colors.redAccent),
          const SizedBox(width: 6),
          Expanded(child: Text(order.address,
            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)))),
        ]),
        if (order.livreurName != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            Text(order.livreurEmoji ?? '🛵', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('${order.livreurName} • ${order.estimatedMinutes ?? 15} دقيقة',
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.purpleAccent)),
          ]),
        ],
        if (isOut) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => onUpdateStatus(order.id, OrderStatus.delivered),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.success,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppTheme.success.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Center(child: Text('تأكيد التسليم ✅',
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
          ),
        ],
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(label, style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }
}
