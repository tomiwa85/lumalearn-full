import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  /// The "child" is the screen currently being viewed (Home, Progress, etc.)
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNavBar'));

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          indicatorColor: AppTheme.neonGreen.withOpacity(0.2),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: AppTheme.neonGreen);
            }
            return const IconThemeData(color: AppTheme.textGrey);
          }),
        ),
        child: NavigationBar(
          backgroundColor: AppTheme.surfaceGrey,
          height: 65,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}