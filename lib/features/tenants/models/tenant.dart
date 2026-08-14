class Tenant {
  final String id;
  final String name;
  final String phone;
  final String alternativePhone;
  final String unitId;
  final String propertyId;
  final double advanceCollected;
  final DateTime advanceDate;
  final DateTime checkInDate;
  final DateTime rentStartDate;

  const Tenant({
    required this.id,
    required this.name,
    required this.phone,
    required this.alternativePhone,
    required this.unitId,
    required this.propertyId,
    required this.advanceCollected,
    required this.advanceDate,
    required this.checkInDate,
    required this.rentStartDate,
  });
}