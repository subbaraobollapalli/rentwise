import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 40),
          Padding(
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
          Divider(color: Colors.white24),
          _MenuItem('Dashboard'),
          _MenuItem('Properties'),
          _MenuItem('Units'),
          _MenuItem('Tenants'),
          _MenuItem('Billing'),
          _MenuItem('Reports'),
          _MenuItem('Settings'),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;

  const _MenuItem(this.title);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.circle_outlined, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}