import '../../../core/models/property.dart';

class PropertyStore {
  PropertyStore._();

  static final PropertyStore instance = PropertyStore._();

  final List<Property> _properties = [
    const Property(
      id: 'P001',
      name: 'Sunrise Residency',
      address: 'Madhapur',
      city: 'Hyderabad',
    ),
    const Property(
      id: 'P002',
      name: 'Green Valley Apartments',
      address: 'Kondapur',
      city: 'Hyderabad',
    ),
    const Property(
      id: 'P003',
      name: 'Lake View Homes',
      address: 'Gachibowli',
      city: 'Hyderabad',
    ),
  ];

  List<Property> get properties => List.unmodifiable(_properties);

  void addProperty(Property property) {
    _properties.add(property);
  }
}