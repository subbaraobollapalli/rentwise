import '../models/rent_payment.dart';

class RentPaymentStore {
  RentPaymentStore._();

  static final RentPaymentStore instance =
      RentPaymentStore._();

  final List<RentPayment> _payments = [];

  List<RentPayment> get payments =>
      List.unmodifiable(_payments);

  void addPayment(RentPayment payment) {
    _payments.add(payment);
  }

  List<RentPayment> getPaymentsForUnit(String unitId) {
    return _payments
        .where((payment) => payment.unitId == unitId)
        .toList();
  }

  List<RentPayment> getPaymentsForTenant(String tenantId) {
    return _payments
        .where((payment) => payment.tenantId == tenantId)
        .toList();
  }

  List<RentPayment> getPaymentsForProperty(
    String propertyId,
  ) {
    return _payments
        .where(
          (payment) =>
              payment.propertyId == propertyId,
        )
        .toList();
  }
}