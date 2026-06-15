import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import 'restaurant_order_model.dart';

class DashboardOrdersTab extends StatefulWidget {
  final List<DashOrder> orders;
  final Color accentColor;
  final void Function(String orderId, OrderStatus newStatus,
      {MockLivreur? livreur}) onUpdateStatus;

  const DashboardOrdersTab({
    super.key,
    required this.orders,
    required this.accentColor,
    required this.onUpdateStatus,
  });

  @override
  State<DashboardOrdersTab> createState() => _DashboardOrdersTabState();
}

class _DashboardOrdersTabState extends State<DashboardOrdersTab> {
  OrderStatus? _filter; // null = all

  List<DashOrder> get _filtered {
    if (_filter == null) return widget.orders;
    return widget.orders.where((o) => o.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FilterChip(
                  label: 'الكل',
                  selected: _filter == null,
                  color: widget.accentColor,
                  onTap: () => setState(() => _filter = null)),
              _FilterChip(
                  label: '🔔 جديد',
                  selected: _filter == OrderStatus.pending,
                  color: Colors.orangeAccent,
                  onTap: () => setState(() => _filter = OrderStatus.pending)),
              _FilterChip(
                  label: '👨‍🍳 تحضير',
                  selected: _filter == OrderStatus.preparing,
                  color: widget.accentColor,
                  onTap: () => setState(() => _filter = OrderStatus.preparing)),
              _FilterChip(
                  label: '📦 جاهز',
                  selected: _filter == OrderStatus.readyForPickup,
                  color: Colors.blueAccent,
                  onTap: () =>
                      setState(() => _filter = OrderStatus.readyForPickup)),
              _FilterChip(
                  label: '🛵 في الطريق',
                  selected: _filter == OrderStatus.outForDelivery,
                  color: Colors.purpleAccent,
                  onTap: () =>
                      setState(() => _filter = OrderStatus.outForDelivery)),
              _FilterChip(
                  label: '✅ منجز',
                  selected: _filter == OrderStatus.delivered,
                  color: AppTheme.success,
                  onTap: () => setState(() => _filter = OrderStatus.delivered)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Orders list
        Expanded(
          child: _filtered.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) => TweenAnimationBuilder<double>(
                    key: ValueKey(_filtered[i].id),
                    duration:
                        Duration(milliseconds: 300 + (i * 50).clamp(0, 400)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 40 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _OrderCard(
                      order: _filtered[i],
                      accentColor: widget.accentColor,
                      onUpdateStatus: widget.onUpdateStatus,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final DashOrder order;
  final Color accentColor;
  final void Function(String, OrderStatus, {MockLivreur? livreur})
      onUpdateStatus;

  const _OrderCard(
      {required this.order,
      required this.accentColor,
      required this.onUpdateStatus});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    // Auto-expand pending orders
    if (widget.order.status == OrderStatus.pending) {
      _expanded = true;
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _statusColor => switch (widget.order.status) {
        OrderStatus.pending => Colors.orangeAccent,
        OrderStatus.accepted => Colors.blueAccent,
        OrderStatus.preparing => widget.accentColor,
        OrderStatus.readyForPickup => Colors.cyan,
        OrderStatus.outForDelivery => Colors.purpleAccent,
        OrderStatus.delivered => AppTheme.success,
        OrderStatus.cancelled => Colors.redAccent,
      };

  String get _timeAgo {
    final diff = DateTime.now().difference(widget.order.createdAt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    return 'منذ ${diff.inHours} ساعة';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isPending = order.status == OrderStatus.pending;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      transform: Matrix4.identity()..scale(isPending ? 1.02 : 1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
              decoration: BoxDecoration(
                color: isPending
                    ? Colors.orangeAccent.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPending
                      ? Colors.orangeAccent.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.1),
                  width: isPending ? 1.5 : 1,
                ),
                boxShadow: isPending
                    ? [
                        BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 4))
                      ]
                    : [],
              ),
              child: Column(children: [
                // ── Header row ─────────────────────────────────────
                GestureDetector(
                  onTap: () {
                    setState(() => _expanded = !_expanded);
                    _expanded ? _ctrl.forward() : _ctrl.reverse();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(order.status.emoji,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(order.status.labelAr,
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _statusColor)),
                          ]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.orderNumber,
                                  style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              Text('${order.customerName} • $_timeAgo',
                                  style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color:
                                          Colors.white.withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${order.total.toStringAsFixed(0)} د.ج',
                                style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Text(order.paymentMethod,
                                style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    color:
                                        Colors.white.withValues(alpha: 0.45))),
                          ],
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withValues(alpha: 0.4),
                              size: 20),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Expanded content ───────────────────────────────
                SizeTransition(
                  sizeFactor: CurvedAnimation(
                      parent: _ctrl, curve: Curves.easeOutCubic),
                  child: Column(
                    children: [
                      Divider(
                          color: Colors.white.withValues(alpha: 0.07),
                          height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Items list
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget.accentColor
                                              .withValues(alpha: 0.15),
                                        ),
                                        child: Center(
                                          child: Text('${item.quantity}',
                                              style: GoogleFonts.cairo(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: widget.accentColor)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Text(item.nameAr.isNotEmpty ? item.nameAr : item.name,
                                              style: GoogleFonts.cairo(
                                                  fontSize: 13,
                                                  color: Colors.white))),
                                      Text(
                                          '${item.total.toStringAsFixed(0)} د.ج',
                                          style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: Colors.white
                                                  .withValues(alpha: 0.6))),
                                    ],
                                  ),
                                )),

                            const SizedBox(height: 10),
                            Divider(
                                color: Colors.white.withValues(alpha: 0.07)),
                            const SizedBox(height: 8),

                            // Address
                            Row(children: [
                              Icon(Icons.location_on_rounded,
                                  size: 14,
                                  color:
                                      Colors.redAccent.withValues(alpha: 0.8)),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(order.address,
                                      style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: Colors.white
                                              .withValues(alpha: 0.6)))),
                            ]),
                            const SizedBox(height: 6),

                            // Phone
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('${order.customerPhone}',
                                      style: GoogleFonts.cairo()),
                                  backgroundColor: const Color(0xFF1A1A2E),
                                ));
                              },
                              child: Row(children: [
                                Icon(Icons.phone_rounded,
                                    size: 14,
                                    color: AppTheme.success
                                        .withValues(alpha: 0.8)),
                                const SizedBox(width: 6),
                                Text(order.customerPhone,
                                    style: GoogleFonts.cairo(
                                        fontSize: 12, color: AppTheme.success)),
                              ]),
                            ),

                            // Livreur info if assigned
                            if (order.livreurName != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.purple
                                          .withValues(alpha: 0.25)),
                                ),
                                child: Row(children: [
                                  Text(order.livreurEmoji ?? '🛵',
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(order.livreurName!,
                                            style: GoogleFonts.cairo(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white)),
                                        Text(
                                            'سائق التوصيل • ${order.estimatedMinutes ?? 15} دقيقة',
                                            style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: Colors.white
                                                    .withValues(alpha: 0.5))),
                                      ])),
                                  Text(order.livreurPhone ?? '',
                                      style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: Colors.purpleAccent)),
                                ]),
                              ),
                            ],

                            const SizedBox(height: 14),

                            // Action buttons
                            _buildActionButtons(context, order),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ])),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DashOrder order) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(children: [
          Expanded(
            child: _ActionBtn(
              label: 'رفض',
              icon: Icons.close_rounded,
              color: Colors.redAccent,
              outline: true,
              onTap: () =>
                  widget.onUpdateStatus(order.id, OrderStatus.cancelled),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _ActionBtn(
              label: 'قبول الطلب ✅',
              icon: Icons.check_rounded,
              color: AppTheme.success,
              onTap: () =>
                  widget.onUpdateStatus(order.id, OrderStatus.preparing),
            ),
          ),
        ]);

      case OrderStatus.preparing:
        return _ActionBtn(
          label: 'الطلب جاهز للاستلام 📦',
          icon: Icons.inventory_2_rounded,
          color: Colors.blueAccent,
          onTap: () =>
              widget.onUpdateStatus(order.id, OrderStatus.readyForPickup),
        );

      case OrderStatus.readyForPickup:
        return _ActionBtn(
          label: 'تعيين سائق توصيل 🛵',
          icon: Icons.delivery_dining_rounded,
          color: Colors.purpleAccent,
          onTap: () => _showLivreurPicker(context, order),
        );

      case OrderStatus.outForDelivery:
        return _ActionBtn(
          label: 'تأكيد التسليم ✅',
          icon: Icons.check_circle_rounded,
          color: AppTheme.success,
          onTap: () => widget.onUpdateStatus(order.id, OrderStatus.delivered),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _showLivreurPicker(BuildContext context, DashOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LivreurPickerSheet(
        onSelect: (livreur) {
          widget.onUpdateStatus(order.id, OrderStatus.outForDelivery,
              livreur: livreur);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('تم تعيين ${livreur.name} للتوصيل!',
                style: GoogleFonts.cairo()),
            backgroundColor: Colors.purpleAccent.shade700,
          ));
        },
      ),
    );
  }
}

// ── Livreur Picker Bottom Sheet ───────────────────────────────────────────────
class _LivreurPickerSheet extends StatelessWidget {
  final void Function(MockLivreur) onSelect;
  const _LivreurPickerSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('اختر سائق التوصيل',
              style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text('السائقون المتاحون الآن',
              style: GoogleFonts.cairo(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 20),
          ...mockLivreurs.map((l) => GestureDetector(
                onTap: l.available ? () => onSelect(l) : null,
                child: AnimatedOpacity(
                  opacity: l.available ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: l.available
                          ? Colors.purple.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: l.available
                            ? Colors.purpleAccent.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(children: [
                      Text(l.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(l.name,
                                style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text(l.phone,
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color:
                                        Colors.white.withValues(alpha: 0.5))),
                          ])),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(children: [
                              const Icon(Icons.star_rounded,
                                  size: 12, color: Colors.amber),
                              const SizedBox(width: 3),
                              Text('${l.rating}',
                                  style: GoogleFonts.cairo(
                                      fontSize: 12, color: Colors.white)),
                            ]),
                            const SizedBox(height: 2),
                            Text(l.available ? 'متاح' : 'مشغول',
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: l.available
                                        ? AppTheme.success
                                        : Colors.grey)),
                          ]),
                    ]),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        transform: Matrix4.identity()..scale(selected ? 1.05 : 1.0),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Text(label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? color : Colors.white.withValues(alpha: 0.6),
            )),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool outline;
  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap,
      this.outline = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: outline ? 1.5 : 0),
          boxShadow: outline
              ? []
              : [
                  BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: outline ? color : Colors.white,
              )),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('لا توجد طلبات',
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60)),
          Text('ستظهر الطلبات الجديدة هنا',
              style: GoogleFonts.cairo(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.3))),
        ],
      ),
    );
  }
}
