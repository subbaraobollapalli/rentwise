import 'package:flutter/material.dart';

import '../../../core/models/property.dart';
import '../../tenants/models/tenant.dart';
import '../../tenants/services/tenant_store.dart';
import '../models/unit.dart';
import '../services/unit_store.dart';

import '../../../features/billing/models/rent_payment.dart';
import '../../../features/billing/services/rent_due_service.dart';
import '../../../features/billing/services/rent_payment_store.dart';
import '../../../features/billing/widgets/rent_collection_dialog.dart';
import '../../../features/billing/widgets/rent_status_section.dart';
import '../models/occupancy_history.dart';
import '../services/occupancy_history_store.dart';
import '../services/unit_type_store.dart';

class PropertyWorkspacePage extends StatefulWidget {
  final Property property;

  const PropertyWorkspacePage({
    super.key,
    required this.property,
  });

  @override
  State<PropertyWorkspacePage> createState() =>
      _PropertyWorkspacePageState();
}

class _PropertyWorkspacePageState
    extends State<PropertyWorkspacePage> {
  String? _expandedUnitId;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _unitsSectionKey = GlobalKey();

  List<Unit> get _units {
    return UnitStore.instance.getUnits(widget.property.id);
  }

  Future<void> _addUnit() async {
    final unit = await showDialog<Unit>(
      context: context,
      builder: (_) => _AddUnitDialog(
        propertyId: widget.property.id,
      ),
    );

    if (unit == null) return;

    UnitStore.instance.addUnit(unit);

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _checkIn(Unit unit) async {
    final tenant = await showDialog<Tenant>(
      context: context,
      builder: (_) => _CheckInDialog(
        propertyId: widget.property.id,
        unitId: unit.id,
        defaultAdvance: unit.defaultAdvance,
        defaultRent: unit.rent,
      ),
    );

    if (tenant == null) return;

    TenantStore.instance.addTenant(tenant);

    UnitStore.instance.occupyUnit(
      unit.id,
      tenant.advanceCollected,
      tenant.advanceDate,
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _collectRent(Unit unit) async {
    if (!unit.occupied) {
      return;
    }

    final tenant =
        TenantStore.instance.getTenantForUnit(unit.id);

    if (tenant == null) {
      return;
    }

    final rentMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );

    final dueService = RentDueService.instance;

    final rentDue = dueService.getRentDue(
      tenant: tenant,
      currentRent: unit.rent,
      month: rentMonth,
    );

    if (rentDue <= 0) {
      return;
    }

    final alreadyCollected =
        dueService.getAmountCollected(
      unitId: unit.id,
      month: rentMonth,
    );

    final outstanding =
        dueService.getOutstandingAmount(
      tenant: tenant,
      currentRent: unit.rent,
      month: rentMonth,
    );

    if (outstanding <= 0) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rent for this month is already fully paid.',
          ),
        ),
      );

      return;
    }

    final result =
        await showDialog<RentCollectionResult>(
      context: context,
      builder: (_) => RentCollectionDialog(
        rentDue: rentDue,
        alreadyCollected: alreadyCollected,
        rentMonth: rentMonth,
      ),
    );

    if (result == null) {
      return;
    }

    final payment = RentPayment(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      propertyId: unit.propertyId,
      unitId: unit.id,
      tenantId: tenant.id,
      rentMonth: rentMonth,
      rentDue: rentDue,
      amountCollected: result.amount,
      paymentDate: result.paymentDate,
      status:
          result.amount >= outstanding
              ? 'Paid'
              : 'Partial',
      remarks: result.remarks,
    );

    RentPaymentStore.instance.addPayment(payment);

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rent payment of ₹${result.amount.toStringAsFixed(0)} recorded.',
        ),
      ),
    );
  }

  Future<void> _vacateUnit(Unit unit) async {
    if (!unit.occupied) {
      return;
    }

    final tenant =
        TenantStore.instance.getTenantForUnit(unit.id);

    if (tenant == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vacate Unit'),
        content: Text(
          'Are you sure you want to vacate ${unit.name} '
          'from tenant ${tenant.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text('Vacate'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final history = OccupancyHistory(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      propertyId: unit.propertyId,
      unitId: unit.id,
      tenantId: tenant.id,
      tenantName: tenant.name,
      tenantPhone: tenant.phone,
      checkInDate: tenant.checkInDate,
      rentStartDate: tenant.rentStartDate,
      vacateDate: DateTime.now(),
      rent: unit.rent,
      advanceCollected: tenant.advanceCollected,
      advanceDate: tenant.advanceDate,
    );

    OccupancyHistoryStore.instance.addHistory(history);

    UnitStore.instance.vacateUnit(unit.id);

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tenant.name} vacated ${unit.name}.',
        ),
      ),
    );
  }

  void _showTenantDetails(Tenant? tenant) {
    if (tenant == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (_) => _TenantDetailsDialog(
        tenant: tenant,
      ),
    );
  }

  void _toggleUnit(Unit unit) {
    setState(() {
      if (_expandedUnitId == unit.id) {
        _expandedUnitId = null;
      } else {
        _expandedUnitId = unit.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final units = _units;

    final double advanceExpected = units.fold(
      0,
      (total, unit) =>
          total + unit.defaultAdvance,
    );

    final double rentExpected = units
        .where((unit) => unit.occupied)
        .fold(
          0,
          (total, unit) =>
              total + unit.rent,
        );

    final now = DateTime.now();

    final double rentCollected =
        RentPaymentStore.instance
            .getPaymentsForProperty(
              widget.property.id,
            )
            .where(
              (payment) =>
                  payment.rentMonth.year ==
                      now.year &&
                  payment.rentMonth.month ==
                      now.month,
            )
            .fold(
              0,
              (total, payment) =>
                  total + payment.amountCollected,
            );

    final int occupiedUnits =
        units.where(
          (unit) => unit.occupied,
        ).length;

    final int vacantUnits =
        units.length - occupiedUnits;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(widget.property.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: _scrollController,
          children: [
            Text(
              widget.property.name,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${widget.property.address}, ${widget.property.city}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Property Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: InkWell(
                      onTap: () {
                        final context =
                            _unitsSectionKey
                                .currentContext;

                        if (context == null) {
                          return;
                        }

                        Scrollable.ensureVisible(
                          context,
                          duration:
                              const Duration(
                            milliseconds: 500,
                          ),
                          curve:
                              Curves.easeInOut,
                        );
                      },
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      child: _SummaryCard(
                        title: 'Units',
                        value:
                            '${units.length}',
                        subtitle:
                            '$occupiedUnits occupied • '
                            '$vacantUnits vacant',
                        icon:
                            Icons.apartment,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  SizedBox(
                    width: 220,
                    child: _SummaryCard(
                      title:
                          'Advance Expected',
                      value:
                          '₹${advanceExpected.toStringAsFixed(0)}',
                      subtitle:
                          'Defined for all units',
                      icon: Icons
                          .account_balance_wallet,
                    ),
                  ),

                  const SizedBox(width: 16),

                  SizedBox(
                    width: 220,
                    child: _SummaryCard(
                      title: 'Rent Expected',
                      value:
                          '₹${rentExpected.toStringAsFixed(0)}',
                      subtitle:
                          'Current month',
                      icon:
                          Icons.receipt_long,
                    ),
                  ),

                  const SizedBox(width: 16),

                  SizedBox(
                    width: 220,
                    child: _SummaryCard(
                      title: 'Rent Collected',
                      value:
                          '₹${rentCollected.toStringAsFixed(0)}',
                      subtitle:
                          'Current month',
                      icon: Icons.payments,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              key: _unitsSectionKey,
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                const Text(
                  'Units',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _addUnit,
                  icon:
                      const Icon(Icons.add),
                  label:
                      const Text('Add Unit'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (units.isEmpty)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.apartment,
                        size: 48,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'No units defined for this property.',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                clipBehavior:
                    Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      color:
                          const Color(0xFFF0F2F6),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Unit',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Type',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Tenant',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Rent',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                        ],
                      ),
                    ),

                    ...units.map(
                      (unit) {
                        final tenant =
                            TenantStore
                                .instance
                                .getTenantForUnit(
                                  unit.id,
                                );

                        final bool expanded =
                            _expandedUnitId ==
                                unit.id;

                        return _UnitSection(
                          unit: unit,
                          tenant: tenant,
                          expanded: expanded,
                          onTap: () =>
                              _toggleUnit(
                            unit,
                          ),
                          onCheckIn: () =>
                              _checkIn(unit),
                          onCollectRent: () =>
                              _collectRent(
                            unit,
                          ),
                          onVacate: () =>
                              _vacateUnit(
                            unit,
                          ),
                          onTenant: () =>
                              _showTenantDetails(
                            tenant,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _UnitSection
    extends StatelessWidget {
  final Unit unit;
  final Tenant? tenant;
  final bool expanded;

  final VoidCallback onTap;
  final VoidCallback onCheckIn;
  final VoidCallback onCollectRent;
  final VoidCallback onVacate;
  final VoidCallback onTenant;

  const _UnitSection({
    required this.unit,
    required this.tenant,
    required this.expanded,
    required this.onTap,
    required this.onCheckIn,
    required this.onCollectRent,
    required this.onVacate,
    required this.onTenant,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            decoration:
                const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    unit.name,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(unit.type),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    tenant?.name ?? '—',
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${unit.rent.toStringAsFixed(0)}',
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Icon(
                        unit.occupied
                            ? Icons.person
                            : Icons
                                .check_circle_outline,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 6,
                      ),

                      Text(
                        unit.occupied
                            ? 'Occupied'
                            : 'Vacant',
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 30,
                  child: Icon(
                    expanded
                        ? Icons
                            .keyboard_arrow_up
                        : Icons
                            .keyboard_arrow_down,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (expanded)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              22,
            ),
            decoration:
                const BoxDecoration(
              color: Color(0xFFF8F9FB),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: _ExpandedUnitDetails(
              unit: unit,
              tenant: tenant,
              onCheckIn: onCheckIn,
              onCollectRent:
                  onCollectRent,
              onVacate: onVacate,
              onTenant: onTenant,
            ),
          ),
      ],
    );
  }
}

class _ExpandedUnitDetails
    extends StatelessWidget {
  final Unit unit;
  final Tenant? tenant;

  final VoidCallback onCheckIn;
  final VoidCallback onCollectRent;
  final VoidCallback onVacate;
  final VoidCallback onTenant;

  const _ExpandedUnitDetails({
    required this.unit,
    required this.tenant,
    required this.onCheckIn,
    required this.onCollectRent,
    required this.onVacate,
    required this.onTenant,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoSection(
                title: 'Unit',
                children: [
                  _InfoLine(
                    label: 'Type',
                    value: unit.type,
                  ),
                  _InfoLine(
                    label: 'Monthly Rent',
                    value:
                        '₹${unit.rent.toStringAsFixed(0)}',
                  ),
                  _InfoLine(
                    label:
                        'Advance to be collected',
                    value:
                        '₹${unit.defaultAdvance.toStringAsFixed(0)}',
                  ),
                  _InfoLine(
                    label: 'Status',
                    value: unit.occupied
                        ? 'Occupied'
                        : 'Vacant',
                  ),
                ],
              ),
            ),

            const SizedBox(width: 40),

            Expanded(
              child: _InfoSection(
                title: 'Tenant',
                children: tenant == null
                    ? const [
                        _InfoLine(
                          label: 'Tenant',
                          value: 'No tenant',
                        ),
                      ]
                    : [
                        _InfoLine(
                          label: 'Name',
                          value:
                              tenant!.name,
                        ),
                        _InfoLine(
                          label: 'Phone',
                          value:
                              tenant!.phone,
                        ),
                        _InfoLine(
                          label:
                              'Check-in Date',
                          value:
                              _formatDate(
                            tenant!
                                .checkInDate,
                          ),
                        ),
                        _InfoLine(
                          label:
                              'Advance Collected',
                          value:
                              '₹${tenant!.advanceCollected.toStringAsFixed(0)}',
                        ),
                        _InfoLine(
                          label:
                              'Advance Date',
                          value:
                              _formatDate(
                            tenant!
                                .advanceDate,
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (unit.occupied &&
            tenant != null) ...[
          RentStatusSection(
            contextData: UnitRentContext(
              unitId: unit.id,
              currentRent: unit.rent,
              tenant: tenant!,
            ),
          ),

          const SizedBox(height: 24),
        ],

        Row(
          children: [
            if (!unit.occupied)
              ElevatedButton.icon(
                onPressed: onCheckIn,
                icon:
                    const Icon(Icons.login),
                label: const Text(
                  'Check In Tenant',
                ),
              ),

            if (unit.occupied) ...[
              ElevatedButton.icon(
                onPressed:
                    onCollectRent,
                icon: const Icon(
                  Icons.currency_rupee,
                ),
                label: const Text(
                  'Collect Rent',
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton.icon(
                onPressed: onTenant,
                icon: const Icon(
                  Icons.person,
                ),
                label:
                    const Text('Tenant'),
              ),

              const SizedBox(width: 10),

              OutlinedButton.icon(
                onPressed: onVacate,
                icon: const Icon(
                  Icons.logout,
                ),
                label:
                    const Text('Vacate'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TenantDetailsDialog
    extends StatelessWidget {
  final Tenant tenant;

  const _TenantDetailsDialog({
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Tenant Details',
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoLine(
              label: 'Name',
              value: tenant.name,
            ),
            _InfoLine(
              label: 'Phone',
              value: tenant.phone,
            ),
            _InfoLine(
              label: 'Check-in Date',
              value:
                  _formatDate(
                tenant.checkInDate,
              ),
            ),
            _InfoLine(
              label: 'Rent Start Date',
              value:
                  _formatDate(
                tenant.rentStartDate,
              ),
            ),
            _InfoLine(
              label: 'Advance Collected',
              value:
                  '₹${tenant.advanceCollected.toStringAsFixed(0)}',
            ),
            _InfoLine(
              label: 'Advance Date',
              value:
                  _formatDate(
                tenant.advanceDate,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _InfoSection
    extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...children,
      ],
    );
  }
}

class _InfoLine
    extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard
    extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style:
                  const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddUnitDialog
    extends StatefulWidget {
  final String propertyId;

  const _AddUnitDialog({
    required this.propertyId,
  });

  @override
  State<_AddUnitDialog> createState() =>
      _AddUnitDialogState();
}

class _AddUnitDialogState
    extends State<_AddUnitDialog> {
  final _formKey =
      GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _rentController =
      TextEditingController();

  final _advanceController =
      TextEditingController();

  String? _selectedTypeId;

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    _advanceController.dispose();

    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final selectedType =
        UnitTypeStore.instance
            .getAll()
            .firstWhere(
              (type) =>
                  type.id == _selectedTypeId,
            );

    final unit = Unit(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      propertyId:
          widget.propertyId,
      name:
          _nameController.text.trim(),
      type: selectedType.name,
      rent: double.parse(
        _rentController.text.trim(),
      ),
      defaultAdvance:
          double.parse(
        _advanceController.text.trim(),
      ),
    );

    Navigator.pop(context, unit);
  }

  @override
  Widget build(BuildContext context) {
    final unitTypes =
        UnitTypeStore.instance.getAll();

    return AlertDialog(
      title:
          const Text('Add Unit'),
      content: SizedBox(
        width: 420,
        child:
            SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextFormField(
                  controller:
                      _nameController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Unit / Portion Name',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Enter unit name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                    height: 16),

                DropdownButtonFormField<
                    String>(
                  initialValue: _selectedTypeId,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Unit Type',
                  ),
                  items: unitTypes
                      .map(
                        (type) =>
                            DropdownMenuItem<
                                String>(
                          value: type.id,
                          child: Text(
                            '${type.name} (${type.category})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTypeId =
                          value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Select unit type';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                    height: 16),

                TextFormField(
                  controller:
                      _rentController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Monthly Rent',
                    prefixText: '₹ ',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Enter monthly rent';
                    }

                    final rent =
                        double.tryParse(
                      value.trim(),
                    );

                    if (rent == null ||
                        rent <= 0) {
                      return 'Enter a valid rent';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                    height: 16),

                TextFormField(
                  controller:
                      _advanceController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Default Advance',
                    prefixText: '₹ ',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Enter default advance';
                    }

                    final advance =
                        double.tryParse(
                      value.trim(),
                    );

                    if (advance == null ||
                        advance < 0) {
                      return 'Enter a valid advance';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child:
              const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child:
              const Text('Save'),
        ),
      ],
    );
  }
}

class _CheckInDialog
    extends StatefulWidget {
  final String propertyId;
  final String unitId;
  final double defaultAdvance;
  final double defaultRent;

  const _CheckInDialog({
    required this.propertyId,
    required this.unitId,
    required this.defaultAdvance,
    required this.defaultRent,
  });

  @override
  State<_CheckInDialog> createState() =>
      _CheckInDialogState();
}

class _CheckInDialogState
    extends State<_CheckInDialog> {
  final _formKey =
      GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _phoneController =
    TextEditingController();

final _alternativePhoneController =
    TextEditingController();

final _advanceController =
    TextEditingController();

  DateTime _checkInDate =
      DateTime.now();

  DateTime _rentStartDate =
      DateTime.now();

  DateTime _advanceDate =
      DateTime.now();

  @override
  void initState() {
    super.initState();

    _advanceController.text =
        widget.defaultAdvance
            .toStringAsFixed(0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _advanceController.dispose();
    _alternativePhoneController.dispose();

    super.dispose();
  }

  Future<void>
      _selectCheckInDate() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          _checkInDate,
      firstDate:
          DateTime(2000),
      lastDate:
          DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _checkInDate =
          selected;

      if (_rentStartDate
          .isBefore(
        _checkInDate,
      )) {
        _rentStartDate =
            _checkInDate;
      }
    });
  }

  Future<void>
      _selectRentStartDate() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          _rentStartDate,
      firstDate:
          _checkInDate,
      lastDate:
          DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _rentStartDate =
          selected;
    });
  }

  Future<void>
      _selectAdvanceDate() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          _advanceDate,
      firstDate:
          DateTime(2000),
      lastDate:
          DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      _advanceDate =
          selected;
    });
  }

  void _save() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_rentStartDate
        .isBefore(
      _checkInDate,
    )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Rent Start Date cannot be before Check-in Date.',
          ),
        ),
      );

      return;
    }

   final tenant = Tenant(
  id: DateTime.now()
      .millisecondsSinceEpoch
      .toString(),
  name: _nameController.text.trim(),
  phone: _phoneController.text.trim(),
  alternativePhone:
      _alternativePhoneController.text.trim(),
  unitId: widget.unitId,
  propertyId: widget.propertyId,
  advanceCollected:
      double.parse(
    _advanceController.text.trim(),
  ),
  advanceDate: _advanceDate,
  checkInDate: _checkInDate,
  rentStartDate: _rentStartDate,
);

    Navigator.pop(
      context,
      tenant,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          const Text('Tenant Check-in'),
      content: SizedBox(
        width: 420,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxHeight: 520,
          ),
          child:
              SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextFormField(
                    controller:
                        _nameController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Tenant Name',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Enter tenant name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                      height: 16),

                  TextFormField(
                    controller:
                        _phoneController,
                    keyboardType:
                        TextInputType.phone,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Phone Number',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Enter phone number';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                      height: 16),

                  TextFormField(
                    controller:
                        _alternativePhoneController,
                    keyboardType:
                        TextInputType.phone,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Alternative Contact',
                    ),
                  ),
                  const SizedBox(
                      height: 16),

                  _DateField(
                    label:
                        'Check-in Date',
                    date:
                        _checkInDate,
                    onTap:
                        _selectCheckInDate,
                  ),

                  const SizedBox(
                      height: 8),

                  _DateField(
                    label:
                        'Rent Start Date',
                    date:
                        _rentStartDate,
                    onTap:
                        _selectRentStartDate,
                  ),

                  const SizedBox(
                      height: 16),

                  TextFormField(
                    controller:
                        _advanceController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Advance Collected',
                      prefixText: '₹ ',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Enter advance amount';
                      }

                      final advance =
                          double.tryParse(
                        value.trim(),
                      );

                      if (advance == null ||
                          advance < 0) {
                        return 'Enter a valid amount';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                      height: 8),

                  _DateField(
                    label:
                        'Advance Collection Date',
                    date:
                        _advanceDate,
                    onTap:
                        _selectAdvanceDate,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child:
              const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child:
              const Text('Check-in'),
        ),
      ],
    );
  }
}

class _DateField
    extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  String _formatDate(
    DateTime value,
  ) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,
      title: Text(label),
      subtitle:
          Text(_formatDate(date)),
      trailing:
          const Icon(
        Icons.calendar_today,
      ),
      onTap: onTap,
    );
  }
}

String _formatDate(
  DateTime? date,
) {
  if (date == null) {
    return '-';
  }

  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}