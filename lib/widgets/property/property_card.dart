import 'package:flutter/material.dart';

import '../../core/models/property.dart';

class PropertyCard extends StatelessWidget {
final Property property;

const PropertyCard({
super.key,
required this.property,
});

@override
Widget build(BuildContext context) {
return Card(
elevation: 2,
child: Padding(
padding: const EdgeInsets.all(20),
child: Row(
children: [
const CircleAvatar(
radius: 28,
child: Icon(Icons.home_work),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
property.name,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 6),
Text(
'${property.address}, ${property.city}',
style: const TextStyle(
color: Colors.grey,
),
),
],
),
),
],
),
),
);
}
}
