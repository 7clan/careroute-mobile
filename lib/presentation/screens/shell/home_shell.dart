import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-navigation shell. Uses a [StatefulShellRoute.indexedStack] so
/// each tab keeps its own navigation state and scroll position.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (
      icon: Icons.travel_explore,
      selectedIcon: Icons.travel_explore,
      label: 'Discover',
    ),
    (icon: Icons.favorite_border, selectedIcon: Icons.favorite, label: 'Saved'),
    (
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_available,
      label: 'Appointments',
    ),
    (icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Return to the root of the branch when re-tapping its tab.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final (:icon, :selectedIcon, :label) in _destinations)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selectedIcon),
              label: label,
            ),
        ],
      ),
    );
  }
}
