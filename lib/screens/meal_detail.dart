import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/meal.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;
  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meal.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meal.thumbnail.isNotEmpty)
              Image.network(meal.thumbnail, width: double.infinity, height: 220, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 220, color: Colors.grey[200], child: const Icon(Icons.broken_image))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [Text(meal.category, style: const TextStyle(color: Colors.black54)), const SizedBox(width: 8), const Text('•', style: TextStyle(color: Colors.black26)), const SizedBox(width: 8), Text(meal.area, style: const TextStyle(color: Colors.black54))]),
                  const SizedBox(height: 12),
                  const Text('Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(meal.instructions, style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
