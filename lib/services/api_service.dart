import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/meal.dart';

class ApiService {
  // Using TheMealDB public API to fetch meals (menu)
  static const _base = 'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  /// Fetches meals matching [query]. Returns empty list when no results.
  static Future<List<Meal>> fetchMeals([String query = '']) async {
    final url = '$_base${Uri.encodeComponent(query)}';
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) {
        throw Exception('Server responded ${resp.statusCode}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final meals = data['meals'];
      if (meals == null) return [];
      return (meals as List).map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // rethrow to let UI show error & retry
      throw Exception('Failed to load meals: $e');
    }
  }
}
