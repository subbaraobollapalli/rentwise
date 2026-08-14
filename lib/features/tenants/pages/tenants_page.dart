import 'package:flutter/material.dart';

import '../models/tenant.dart';
import '../services/tenant_store.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage({super.key});

  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  @override
  Widget build(BuildContext context) {
    final tenants = TenantStore.instance.tenants;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tenants',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage and view tenant information',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: tenants.isEmpty
                  ? _EmptyTenantsState()
                  : Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            color: const Color(0xFFF0F2F6),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Tenant ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Tenant',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Phone',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Alternative Phone',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Check-in',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 40),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: tenants.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final tenant = tenants[index];

                                return InkWell(
                                  onTap: () {
                                    _showTenantDetails(
                                      context,
                                      tenant,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            tenant.id,
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            tenant.name,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            tenant.phone,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            tenant.alternativePhone
                                                    .trim()
                                                    .isEmpty
                                                ? '—'
                                                : tenant.alternativePhone,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _formatDate(
                                              tenant.checkInDate,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 40,
                                          child: Icon(
                                            Icons.keyboard_arrow_right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTenantDetails(
    BuildContext context,
    Tenant tenant,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _TenantDetailsDialog(
        tenant: tenant,
      ),
    );
  }
}

class _EmptyTenantsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No tenants yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tenants will appear here after a unit is checked in.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TenantDetailsDialog extends StatelessWidget {
  final Tenant tenant;

  const _TenantDetailsDialog({
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tenant Details'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: 'Tenant ID',
                value: tenant.id,
              ),
              _DetailRow(
                label: 'Name',
                value: tenant.name,
              ),
              _DetailRow(
                label: 'Phone',
                value: tenant.phone,
              ),
              _DetailRow(
                label: 'Alternative Phone',
                value: tenant.alternativePhone.trim().isEmpty
                    ? '—'
                    : tenant.alternativePhone,
              ),
              _DetailRow(
                label: 'Unit ID',
                value: tenant.unitId,
              ),
              _DetailRow(
                label: 'Property ID',
                value: tenant.propertyId,
              ),
              _DetailRow(
                label: 'Check-in Date',
                value: _formatDate(
                  tenant.checkInDate,
                ),
              ),
              _DetailRow(
                label: 'Rent Start Date',
                value: _formatDate(
                  tenant.rentStartDate,
                ),
              ),
              _DetailRow(
                label: 'Advance Collected',
                value:
                    '₹${tenant.advanceCollected.toStringAsFixed(0)}',
              ),
              _DetailRow(
                label: 'Advance Date',
                value: _formatDate(
                  tenant.advanceDate,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}