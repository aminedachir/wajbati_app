import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/providers.dart';
import 'nav_item.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentTab;
  final void Function(int) onTabChanged;

  const HomeBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    current: currentTab,
                    onTap: onTabChanged,
                  ),
                  NavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    index: 1,
                    current: currentTab,
                    onTap: onTabChanged,
                  ),
                  // Cart FAB
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/cart'),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            (constraints.maxWidth * 0.15).clamp(40.0, 56.0);
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, Color(0xFFBF1A12)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: size * 0.45,
                              ),
                              if (cart.itemCount > 0)
                                Positioned(
                                  top: size * 0.15,
                                  right: size * 0.15,
                                  child: Container(
                                    width: size * 0.3,
                                    height: size * 0.3,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${cart.itemCount}',
                                        style: TextStyle(
                                          fontSize: size * 0.16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  NavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Orders',
                    index: 2,
                    current: currentTab,
                    onTap: onTabChanged,
                  ),
                  NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 3,
                    current: currentTab,
                    onTap: onTabChanged,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
