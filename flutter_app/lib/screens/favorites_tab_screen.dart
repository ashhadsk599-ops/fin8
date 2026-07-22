import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';
import 'package:cura_meal/screens/cart_and_checkout_screen.dart';
import 'package:cura_meal/screens/meal_detail_customizer_screen.dart';

class FavoritesTabScreen extends StatelessWidget {
  const FavoritesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final favMeals = STAT_MEALS.where((m) => state.favorites.contains(m.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
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
      body: favMeals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite_outline, size: 48, color: const Color(0xFF2E7D32).withOpacity(0.5)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Saved Favorites',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the heart icon on any meal card to build a custom shortlist of your favorite recovery foods.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favMeals.length,
              itemBuilder: (ctx, idx) {
                final meal = favMeals[idx];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(meal.image, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('₹${meal.price.toStringAsFixed(0)} | ${meal.category}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => state.toggleFavorite(meal.id),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MealDetailCustomizerScreen(meal: meal)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
