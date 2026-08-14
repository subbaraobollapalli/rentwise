import 'package:flutter/material.dart';

class Property {
  final String id;
  final String name;
  final String address;
  final String city;

 

  final IconData icon;

  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    

   
    this.icon = Icons.apartment,
  });

 
}