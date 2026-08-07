import 'package:flutter/material.dart';

import '../core/models/app_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/properties/pages/property_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  AppPage _currentPage = AppPage.dashboard;

  void changePage(AppPage page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget get currentPage {
    switch (_currentPage) {
      case AppPage.dashboard:
        return const DashboardPage();

      case AppPage.properties:
        return const PropertyPage();

      case AppPage.units:
      case AppPage.tenants:
      case AppPage.billing:
      case AppPage.reports:
      case AppPage.settings:
        return const Center(
          child: Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPage,
    );
  }
}