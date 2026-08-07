class Property {
  final int id;
  final String name;
  final String address;
  final String type;
  final int totalUnits;
  final int occupiedUnits;

  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.totalUnits,
    required this.occupiedUnits,
  });

  int get vacantUnits => totalUnits - occupiedUnits;
}