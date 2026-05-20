import 'package:flutter/material.dart';

class RestaurantFrame extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final List<BoxShadow>? shadow;

  const RestaurantFrame({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );
  }
}
