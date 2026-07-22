import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';
import 'package:cura_meal/screens/meal_detail_customizer_screen.dart';
import 'package:cura_meal/screens/cart_and_checkout_screen.dart';

class SearchTabScreen extends StatefulWidget {
  const SearchTabScreen({super.key});

  @override
  State<SearchTabScreen> createState() => _SearchTabScreenState();
}

class _SearchTabScreenState extends State<SearchTabScreen> {
  String _query = '';
  String _selectedCategory = 'All';

  final List<Map<String, String>> _categories = [
    {'id': 'All', 'label': 'All', 'icon': '🍽️'},
    {'id': 'Breakfast', 'label': 'Breakfast', 'icon': '🥣'},
    {'id': 'Soup', 'label': 'Soup', 'icon': '🍵'},
    {'id': 'Lunch', 'label': 'Lunch', 'icon': '🍛'},
    {'id': 'Juice', 'label': 'Juice', 'icon': '🥤'},
    {'id': 'Snacks', 'label': 'Snacks', 'icon': '🍎'},
    {'id': 'Grocery', 'label': 'Essentials', 'icon': '📦'},
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    final filteredMeals = STAT_MEALS.where((meal) {
      final matchesQuery = meal.name.toLowerCase().contains(_query.toLowerCase()) ||
          meal.description.toLowerCase().contains(_query.toLowerCase());
          
      if (!matchesQuery) return false;
      
      if (_selectedCategory != 'All' && meal.category != _selectedCategory) {
        return false;
      }
      
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7), // Brand Cream Background
      appBar: AppBar(
        title: const Text('Instant Search', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${state.cart.length}'),
              isLabelVisible: state.cart.isNotEmpty,
              child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2E7D32)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartAndCheckoutScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search nutritious soups, khichdi, idli, upma...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                fillColor: const Color(0xFFFFFDF7),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Side Categories
                Container(
                  width: 115,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        color: const Color(0xFFF8FAFC),
                        child: const Text(
                          'CATEGORIES',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _categories.length,
                          itemBuilder: (ctx, idx) {
                            final cat = _categories[idx];
                            final isSelected = _selectedCategory == cat['id'];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat['id']!;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey.shade100, width: 0.8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(cat['icon']!, style: const TextStyle(fontSize: 13)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        state.translate(cat['label']!),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : const Color(0xFF334155),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                // Right Side Results List (Image, Name, Price ONLY)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Showing ${filteredMeals.length} dishes',
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: filteredMeals.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    const Text('No matching meals.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                itemCount: filteredMeals.length,
                                itemBuilder: (ctx, idx) {
                                  final meal = filteredMeals[idx];
                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.15)),
                                    ),
                                    elevation: 0.5,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => MealDetailCustomizerScreen(meal: meal)),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                meal.image,
                                                width: 54,
                                                height: 54,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                meal.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Color(0xFF1E293B),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '₹${meal.price.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E7D32),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
