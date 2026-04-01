import 'package:flutter/material.dart';
import '../favorites/favorites_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/home_tab.dart' show HomeTab;

class HomeTabs {
  static List<Widget> tabs = [
    const HomeTab(),
    const FavoritesScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  static const List<BottomNavData> navData = [
    BottomNavData(Icons.home_rounded, 'Home', 0),
    BottomNavData(Icons.favorite_rounded, 'Favorites', 1),
    BottomNavData(Icons.receipt_long_rounded, 'Orders', 2),
    BottomNavData(Icons.person_rounded, 'Profile', 3),
  ];
}

class BottomNavData {
  final IconData icon;
  final String label;
  final int index;

  const BottomNavData(this.icon, this.label, this.index);
}
