import 'package:flutter/material.dart';
import '../discover/discover_videos_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/home_tab.dart' show HomeTab;

class HomeTabs {
  static List<Widget> tabs = [
    const HomeTab(),
    const DiscoverVideosScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  static const List<BottomNavData> navData = [
    BottomNavData(Icons.home_rounded, 'الرئيسية', 0),
    BottomNavData(Icons.video_library_rounded, 'الفيديوهات', 1),
    BottomNavData(Icons.receipt_long_rounded, 'طلباتي', 2),
    BottomNavData(Icons.person_rounded, 'حسابي', 3),
  ];
}

class BottomNavData {
  final IconData icon;
  final String label;
  final int index;

  const BottomNavData(this.icon, this.label, this.index);
}
