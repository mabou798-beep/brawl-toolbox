import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/ads/banner_ad_widget.dart';
import '../core/ads/tracking_consent.dart';
import 'brawlers/brawlers_screen.dart';
import 'home/home_screen.dart';
import 'maps/maps_screen.dart';
import 'more/more_screen.dart';
import 'stats/stats_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _open(int i) => setState(() => _index = i);

  @override
  void initState() {
    super.initState();
    _askForTrackingConsent();
  }

  /// Apple only shows the tracking prompt while the app is actually on screen
  /// and active, so it is requested after the first frame rather than during
  /// startup — and after a short pause, so the player sees the app they just
  /// opened before a system dialog lands on top of it.
  Future<void> _askForTrackingConsent() async {
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await requestTrackingConsent();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onOpenTab: _open),
      const BrawlersScreen(),
      const MapsScreen(),
      const StatsScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _open,
            destinations: const [
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.house, size: 18),
                label: 'Home',
              ),
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.userNinja, size: 18),
                label: 'Brawlers',
              ),
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.mapLocationDot, size: 18),
                label: 'Maps',
              ),
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.trophy, size: 18),
                label: 'My stats',
              ),
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.ellipsis, size: 18),
                label: 'More',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
