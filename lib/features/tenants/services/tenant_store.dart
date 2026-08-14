import '../models/tenant.dart';

class TenantStore {
  TenantStore._();

  static final TenantStore instance = TenantStore._();

  final List<Tenant> _tenants = [];

  List<Tenant> get tenants => List.unmodifiable(_tenants);

  void addTenant(Tenant tenant) {
    _tenants.add(tenant);
  }

  Tenant? getTenantForUnit(String unitId) {
    for (final tenant in _tenants) {
      if (tenant.unitId == unitId) {
        return tenant;
      }
    }

    return null;
  }
}