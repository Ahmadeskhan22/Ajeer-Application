// lib/widgets/Seeker_BottomNavi.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../Theme/app_theme.dart';
import '../provider/app_provider.dart';

class SeekerBottomNav extends StatelessWidget {
  final int index;
  const SeekerBottomNav({super.key, required this.index});

  // Index → route mapping (must match bottomNavigationBar index: N in every screen)
  // 0 = Jobs        → /browse-jobs
  // 1 = AI Match    → /ai-matcher
  // 2 = Alerts      → /notifications
  // 3 = Applied     → /applications
  // 4 = Profile     → /profile
  static const _routes = [
    '/browse-jobs',
    '/ai-matcher',
    '/notifications',
    '/applications',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final unread =
        context.select<AppProvider, int>((p) => p.unreadNotificationsCount);

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        if (i != index) context.go(_routes[i]);
      },
      indicatorColor: AppTheme.primary.withOpacity(0.12),
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: Colors.black12,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.work_outline_rounded),
          selectedIcon: Icon(Icons.work_rounded, color: AppTheme.primary),
          label: 'Jobs',
        ),
        const NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon:
              Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
          label: ' Match',
        ),
        NavigationDestination(
          icon: _BadgeIcon(icon: Icons.notifications_outlined, count: unread),
          selectedIcon: _BadgeIcon(
              icon: Icons.notifications_rounded,
              color: AppTheme.primary,
              count: unread),
          label: 'Alerts',
        ),
        const NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded, color: AppTheme.primary),
          label: 'Applied',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _BadgeIcon({
    required this.icon,
    required this.count,
    this.color = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: color),
        if (count > 0)
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
