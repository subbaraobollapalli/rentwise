import '../../tenants/models/tenant.dart';
import '../models/rent_payment.dart';
import '../services/rent_payment_store.dart';

class RentDueService {
  RentDueService._();

  static final RentDueService instance =
      RentDueService._();

  double getRentDue({
    required Tenant tenant,
    required double currentRent,
    required DateTime month,
  }) {
    final rentMonth = DateTime(
      month.year,
      month.month,
    );

    final rentStartMonth = DateTime(
      tenant.rentStartDate.year,
      tenant.rentStartDate.month,
    );

    if (rentMonth.isBefore(rentStartMonth)) {
      return 0;
    }

    return currentRent;
  }

  double getAmountCollected({
    required String unitId,
    required DateTime month,
  }) {
    final payments =
        RentPaymentStore.instance.getPaymentsForUnit(
      unitId,
    );

    final rentMonth = DateTime(
      month.year,
      month.month,
    );

    return payments
        .where(
          (payment) =>
              _sameMonth(
                payment.rentMonth,
                rentMonth,
              ),
        )
        .fold(
          0,
          (total, payment) =>
              total + payment.amountCollected,
        );
  }

  double getOutstandingAmount({
    required Tenant tenant,
    required double currentRent,
    required DateTime month,
  }) {
    final due = getRentDue(
      tenant: tenant,
      currentRent: currentRent,
      month: month,
    );

    if (due == 0) {
      return 0;
    }

    final collected = getAmountCollected(
      unitId: tenant.unitId,
      month: month,
    );

    final outstanding = due - collected;

    return outstanding > 0 ? outstanding : 0;
  }

  String getStatus({
    required Tenant tenant,
    required double currentRent,
    required DateTime month,
  }) {
    final due = getRentDue(
      tenant: tenant,
      currentRent: currentRent,
      month: month,
    );

    if (due == 0) {
      return 'Not Due';
    }

    final collected = getAmountCollected(
      unitId: tenant.unitId,
      month: month,
    );

    if (collected <= 0) {
      return 'Due';
    }

    if (collected < due) {
      return 'Partial';
    }

    return 'Paid';
  }

  bool _sameMonth(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month;
  }

  RentPayment? getPaymentForMonth({
    required String unitId,
    required DateTime month,
  }) {
    final payments =
        RentPaymentStore.instance.getPaymentsForUnit(
      unitId,
    );

    for (final payment in payments) {
      if (_sameMonth(payment.rentMonth, month)) {
        return payment;
      }
    }

    return null;
  }
}