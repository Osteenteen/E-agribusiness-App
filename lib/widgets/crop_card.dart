import 'package:flutter/material.dart';

class CropCard extends StatelessWidget {
  final String name;
  final String description;

  const CropCard({super.key, required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(name),
        subtitle: Text(description),
      ),
    );
  }
}
