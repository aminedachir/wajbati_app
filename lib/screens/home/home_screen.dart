import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/home_provider.dart';
import 'home_tabs.dart';
import 'widgets/home_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  int _currentTab = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _currentTab) {
      final homeProvider = context.read<HomeProvider>();
      if (index == 0) {
        homeProvider.refresh();
      }
      return;
    }
    setState(() => _currentTab = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: _currentTab == 0,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: HomeTabs.tabs
              .map((tab) => AutomaticKeepAlive(child: tab))
              .toList(),
        ),
        bottomNavigationBar: HomeBottomNavBar(
          currentTab: _currentTab,
          onTabChanged: _onTabChanged,
        ),
      ),
    );
  }
}

class AutomaticKeepAlive extends StatefulWidget {
  final Widget child;

  const AutomaticKeepAlive({super.key, required this.child});

  @override
  State<AutomaticKeepAlive> createState() => _AutomaticKeepAliveState();
}

class _AutomaticKeepAliveState extends State<AutomaticKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
