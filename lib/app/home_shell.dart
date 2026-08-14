import 'package:flutter/material.dart';

import '../core/models/app_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/properties/pages/property_page.dart';
import '../widgets/app_header.dart';
import '../widgets/app_sidebar.dart';
import '../features/properties/pages/unit_property_selection_page.dart';
import '../features/tenants/pages/tenants_page.dart';

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
         return const UnitPropertySelectionPage();

      case AppPage.tenants:
        return const TenantsPage();
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
      body: Row(
        children: [
          AppSidebar(
            selectedPage: _currentPage,
            onPageSelected: changePage,
          ),

          Expanded(
            child: Column(
              children: [
                const AppHeader(),

                Expanded(
                  child: currentPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}