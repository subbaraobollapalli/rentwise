import 'package:flutter/material.dart';

import '../../../core/models/property.dart';
import '../../../widgets/property/add_property_dialog.dart';
import '../../../widgets/property/property_card.dart';
import 'property_workspace_page.dart';
import '../services/property_store.dart';

class PropertyPage extends StatefulWidget {
  const PropertyPage({super.key});

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  List<Property> get _properties {
    return PropertyStore.instance.properties;
  }

  Future<void> _addProperty() async {
    final Property? property = await showDialog<Property>(
      context: context,
      builder: (_) => const AddPropertyDialog(),
    );

    if (property != null) {
      PropertyStore.instance.addProperty(property);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${property.name} added successfully'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6FA),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Properties',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addProperty,
                icon: const Icon(Icons.add),
                label: const Text('Add Property'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (_properties.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No properties available',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          else
            ..._properties.map(
              (property) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PropertyWorkspacePage(
                        property: property,
                      ),
                    ),
                  );
                },
                child: PropertyCard(
                  property: property,
                ),
              ),
            ),
        ],
      ),
    );
  }
}