import 'package:flutter/material.dart';

import '../../../core/models/property.dart';
import '../services/property_store.dart';
import 'property_workspace_page.dart';

class UnitPropertySelectionPage extends StatelessWidget {
  const UnitPropertySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Property> properties =
        PropertyStore.instance.properties;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Select Property'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Select a property',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Choose the property whose units you want to manage.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          if (properties.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No properties available.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...properties.map(
              (property) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

                  leading: const CircleAvatar(
                    child: Icon(Icons.apartment),
                  ),

                  title: Text(
                    property.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  subtitle: Text(
                    '${property.address}, ${property.city}',
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),

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
                ),
              ),
            ),
        ],
      ),
    );
  }
}