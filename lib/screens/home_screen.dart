import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/meal.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/widgets/meal_card.dart';
import 'package:flutter_application_1/screens/meal_detail.dart';

enum _LoadState { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _LoadState _state = _LoadState.loading;
  String _error = '';
  List<Meal> _meals = [];

  // Replace with your actual name and student id
  final _studentName = 'Trần Hữu Hậu';
  final _studentId = '2351060443';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals([String q = '']) async {
    setState(() {
      _state = _LoadState.loading;
      _error = '';
    });
    try {
      final meals = await ApiService.fetchMeals(q);
      setState(() {
        _meals = meals;
        _state = _LoadState.success;
      });
    } catch (e) {
      setState(() {
        _state = _LoadState.error;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TH3 - $_studentName - $_studentId'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Builder(builder: (context) {
            if (_state == _LoadState.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_state == _LoadState.error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 72, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('Lỗi khi lấy dữ liệu', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _loadMeals(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // Success
            if (_meals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant_menu, size: 72, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('Không có món ăn nào.'),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => _loadMeals(), child: const Text('Tải lại')),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _loadMeals(),
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                int columns;
                if (width > 1200) {
                  columns = 4;
                } else if (width > 900) {
                  columns = 3;
                } else if (width > 600) {
                  columns = 2;
                } else {
                  columns = 1;
                }

                // Estimate item height (image + paddings + text) and compute aspect ratio
                // Increased from 170 to 220 to avoid bottom overflow when text wraps
                const double estimatedItemHeight = 220.0;
                // compute item width accounting for cross-axis spacing between columns
                const spacing = 12.0;
                final itemWidth = (width - (columns - 1) * spacing) / columns;
                final childAspectRatio = itemWidth / estimatedItemHeight;

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: _meals.length,
                  itemBuilder: (context, index) {
                    final m = _meals[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealDetailScreen(meal: m))),
                      child: MealCard(meal: m),
                    );
                  },
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
