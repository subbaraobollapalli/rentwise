import 'package:flutter/material.dart';

import '../../core/models/property.dart';

class AddPropertyDialog extends StatefulWidget {
  const AddPropertyDialog({super.key});

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<AddPropertyDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  
  

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
   
   
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final property = Property(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
     
    );

    Navigator.pop(context, property);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Property"),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Property Name",
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? "Enter property name"
                          : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? "Enter address"
                          : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: "City",
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? "Enter city"
                          : null,
                ),

                const SizedBox(height: 16),

                

                const SizedBox(height: 16),

                
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text("Save"),
        ),
      ],
    );
  }
}