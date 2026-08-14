import '../models/unit_type.dart';

class UnitTypeStore {
  UnitTypeStore._();

  static final UnitTypeStore instance = UnitTypeStore._();

  final List<UnitType> _unitTypes = const [
    UnitType(
      id: 'res_1bhk',
      name: '1 BHK',
      category: 'Residential',
    ),
    UnitType(
      id: 'res_2bhk',
      name: '2 BHK',
      category: 'Residential',
    ),
    UnitType(
      id: 'res_3bhk',
      name: '3 BHK',
      category: 'Residential',
    ),
    UnitType(
      id: 'res_4bhk',
      name: '4 BHK',
      category: 'Residential',
    ),
    UnitType(
      id: 'res_5bhk',
      name: '5 BHK',
      category: 'Residential',
    ),
    UnitType(
      id: 'commercial_shop',
      name: 'Shop',
      category: 'Commercial',
    ),
    UnitType(
      id: 'commercial_office',
      name: 'Office',
      category: 'Commercial',
    ),
    UnitType(
      id: 'commercial_godown',
      name: 'Godown',
      category: 'Commercial',
    ),
    UnitType(
      id: 'other',
      name: 'Other',
      category: 'Other',
    ),
  ];

  List<UnitType> getAll() {
    return List.unmodifiable(_unitTypes);
  }

  List<UnitType> getByCategory(String category) {
    return _unitTypes
        .where((type) => type.category == category)
        .toList();
  }
}
