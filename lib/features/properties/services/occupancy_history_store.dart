import '../models/occupancy_history.dart';

class OccupancyHistoryStore {
  OccupancyHistoryStore._();

  static final OccupancyHistoryStore instance =
      OccupancyHistoryStore._();

  final List<OccupancyHistory> _history = [];

  void addHistory(OccupancyHistory history) {
    _history.add(history);
  }

  List<OccupancyHistory> getHistoryForUnit(String unitId) {
    return _history
        .where((item) => item.unitId == unitId)
        .toList();
  }

  List<OccupancyHistory> getHistoryForProperty(
    String propertyId,
  ) {
    return _history
        .where((item) => item.propertyId == propertyId)
        .toList();
  }

  List<OccupancyHistory> get history =>
      List.unmodifiable(_history);
}