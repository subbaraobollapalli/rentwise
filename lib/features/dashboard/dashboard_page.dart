import 'package:flutter/material.dart';

import '../../core/models/dashboard_item.dart';
import '../../widgets/dashboard/dashboard_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const List<DashboardItem> dashboardItems = [
    DashboardItem(
      title: 'Properties',
      value: '12',
      icon: Icons.home_work,
      color: Colors.blue,
    ),
    DashboardItem(
      title: 'Occupied Units',
      value: '48',
      icon: Icons.meeting_room,
      color: Colors.green,
    ),
    DashboardItem(
      title: 'Vacant Units',
      value: '3',
      icon: Icons.key,
      color: Colors.orange,
    ),
    DashboardItem(
      title: 'Monthly Rent',
      value: '₹1.25L',
      icon: Icons.currency_rupee,
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: dashboardItems
              .map(
                (item) => DashboardCard(
                  title: item.title,
                  value: item.value,
                  icon: item.icon,
                  color: item.color,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}