import 'package:flutter/material.dart';

import '../core/models/app_page.dart';

class AppSidebar extends StatelessWidget {
  final AppPage selectedPage;
  final ValueChanged<AppPage> onPageSelected;

  const AppSidebar({
    super.key,
    required this.selectedPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'RentWise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(color: Colors.white24),

          _MenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard,
            selected: selectedPage == AppPage.dashboard,
            onTap: () => onPageSelected(AppPage.dashboard),
          ),

          _MenuItem(
            title: 'Properties',
            icon: Icons.home_work,
            selected: selectedPage == AppPage.properties,
            onTap: () => onPageSelected(AppPage.properties),
          ),

          _MenuItem(
            title: 'Units',
            icon: Icons.meeting_room,
            selected: selectedPage == AppPage.units,
            onTap: () => onPageSelected(AppPage.units),
          ),

          _MenuItem(
            title: 'Tenants',
            icon: Icons.people,
            selected: selectedPage == AppPage.tenants,
            onTap: () => onPageSelected(AppPage.tenants),
          ),

          _MenuItem(
            title: 'Billing',
            icon: Icons.receipt_long,
            selected: selectedPage == AppPage.billing,
            onTap: () => onPageSelected(AppPage.billing),
          ),

          _MenuItem(
            title: 'Reports',
            icon: Icons.bar_chart,
            selected: selectedPage == AppPage.reports,
            onTap: () => onPageSelected(AppPage.reports),
          ),

          _MenuItem(
            title: 'Settings',
            icon: Icons.settings,
            selected: selectedPage == AppPage.settings,
            onTap: () => onPageSelected(AppPage.settings),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
  return Material(
  color: selected
      ? Colors.white.withValues(alpha: 0.15)
      : Colors.transparent,
  child: ListTile(
    leading: Icon(
      icon,
      color: Colors.white,
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: onTap,
  ),
);
  }
}