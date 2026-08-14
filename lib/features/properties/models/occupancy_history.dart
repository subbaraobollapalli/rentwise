class OccupancyHistory {
  final String id;
  final String propertyId;
  final String unitId;
  final String tenantId;
  final String tenantName;
  final String tenantPhone;
  final DateTime checkInDate;
  final DateTime rentStartDate;
  final DateTime vacateDate;
  final double rent;
  final double advanceCollected;
  final DateTime advanceDate;

  const OccupancyHistory({
    required this.id,
    required this.propertyId,
    required this.unitId,
    required this.tenantId,
    required this.tenantName,
    required this.tenantPhone,
    required this.checkInDate,
    required this.rentStartDate,
    required this.vacateDate,
    required this.rent,
    required this.advanceCollected,
    required this.advanceDate,
  });
}
