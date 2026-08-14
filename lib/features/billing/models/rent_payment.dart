class RentPayment {
  final String id;
  final String propertyId;
  final String unitId;
  final String tenantId;

  final DateTime rentMonth;
  final double rentDue;
  final double amountCollected;
  final DateTime? paymentDate;

  final String status;
  final String? remarks;

  const RentPayment({
    required this.id,
    required this.propertyId,
    required this.unitId,
    required this.tenantId,
    required this.rentMonth,
    required this.rentDue,
    required this.amountCollected,
    required this.paymentDate,
    required this.status,
    this.remarks,
  });
}