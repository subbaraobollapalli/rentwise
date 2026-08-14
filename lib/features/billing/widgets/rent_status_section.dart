import 'package:flutter/material.dart';

import '../../../features/tenants/models/tenant.dart';
import '../models/rent_payment.dart';
import '../services/rent_due_service.dart';
import '../services/rent_payment_store.dart';

class RentStatusSection extends StatelessWidget {
  final UnitRentContext contextData;

  const RentStatusSection({
    super.key,
    required this.contextData,
  });

  @override
  Widget build(BuildContext context) {
    final tenant = contextData.tenant;
    final unitId = contextData.unitId;
    final currentRent = contextData.currentRent;

    final rentMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );

    final dueService = RentDueService.instance;

    final rentDue = dueService.getRentDue(
      tenant: tenant,
      currentRent: currentRent,
      month: rentMonth,
    );

    final payments =
        RentPaymentStore.instance.getPaymentsForUnit(unitId);

    final currentMonthPayments = payments.where((payment) {
      return payment.rentMonth.year == rentMonth.year &&
          payment.rentMonth.month == rentMonth.month &&
          payment.tenantId == tenant.id;
    }).toList();

    final double collected = currentMonthPayments.fold(
      0,
      (total, payment) => total + payment.amountCollected,
    );

    final double outstanding =
        (rentDue - collected).clamp(0, double.infinity);

    final String status;

    if (rentDue <= 0) {
      status = 'Not Due';
    } else if (outstanding <= 0) {
      status = 'Paid';
    } else if (collected > 0) {
      status = 'Partial';
    } else {
      status = 'Due';
    }

    final history = List<RentPayment>.from(payments)
      ..sort(
        (a, b) => b.rentMonth.compareTo(a.rentMonth),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rent',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _monthName(rentMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _RentAmount(
                        label: 'Rent Due',
                        amount: rentDue,
                      ),
                    ),
                    Expanded(
                      child: _RentAmount(
                        label: 'Collected',
                        amount: collected,
                      ),
                    ),
                    Expanded(
                      child: _RentAmount(
                        label: 'Outstanding',
                        amount: outstanding,
                      ),
                    ),
                    Expanded(
                      child: _RentStatus(
                        status: status,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Payment History',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        if (history.isEmpty)
          const Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'No rent payments recorded yet.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: history.map(
                (payment) {
                  return _PaymentHistoryRow(
                    payment: payment,
                  );
                },
              ).toList(),
            ),
          ),
      ],
    );
  }

  String _monthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}

class UnitRentContext {
  final String unitId;
  final double currentRent;
  final Tenant tenant;

  const UnitRentContext({
    required this.unitId,
    required this.currentRent,
    required this.tenant,
  });
}

class _RentAmount extends StatelessWidget {
  final String label;
  final double amount;

  const _RentAmount({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RentStatus extends StatelessWidget {
  final String status;

  const _RentStatus({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _statusColor(status),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String value) {
    switch (value) {
      case 'Paid':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      case 'Due':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _PaymentHistoryRow extends StatelessWidget {
  final RentPayment payment;

  const _PaymentHistoryRow({
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatMonth(payment.rentMonth),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '₹${payment.rentDue.toStringAsFixed(0)}',
            ),
          ),
          Expanded(
            child: Text(
              '₹${payment.amountCollected.toStringAsFixed(0)}',
            ),
          ),
          Expanded(
            child: Text(
              payment.status,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: payment.status == 'Paid'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}