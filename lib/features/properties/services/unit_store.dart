import '../models/unit.dart';

class UnitStore {
  UnitStore._();

  static final UnitStore instance = UnitStore._();

  final List<Unit> _units = [];

  List<Unit> getUnits(String propertyId) {
    return _units
        .where((unit) => unit.propertyId == propertyId)
        .toList();
  }

  void addUnit(Unit unit) {
    _units.add(unit);
  }

  void occupyUnit(
    String unitId,
    double advanceCollected,
    DateTime advanceCollectedDate,
  ) {
    final index = _units.indexWhere(
      (unit) => unit.id == unitId,
    );

    if (index == -1) return;

    final unit = _units[index];

    _units[index] = Unit(
      id: unit.id,
      propertyId: unit.propertyId,
      name: unit.name,
      type: unit.type,
      rent: unit.rent,
      defaultAdvance: unit.defaultAdvance,
      occupied: true,
      advanceCollected: advanceCollected,
      advanceCollectedDate: advanceCollectedDate,
    );
  }

  void vacateUnit(String unitId) {
    final index = _units.indexWhere(
      (unit) => unit.id == unitId,
    );

    if (index == -1) return;

    final unit = _units[index];

    _units[index] = Unit(
      id: unit.id,
      propertyId: unit.propertyId,
      name: unit.name,
      type: unit.type,
      rent: unit.rent,
      defaultAdvance: unit.defaultAdvance,
      occupied: false,
    );
  }
}