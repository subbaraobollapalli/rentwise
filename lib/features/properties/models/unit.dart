class Unit {
  final String id;
  final String propertyId;
  final String name;
  final String type;
  final double rent;
  final double defaultAdvance;
  final bool occupied;
  final double advanceCollected;
  final DateTime? advanceCollectedDate;

  const Unit({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.type,
    required this.rent,
    required this.defaultAdvance,
    this.occupied = false,
    this.advanceCollected = 0,
    this.advanceCollectedDate,
  });
}