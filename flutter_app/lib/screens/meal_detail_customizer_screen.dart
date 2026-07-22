import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class MealDetailCustomizerScreen extends StatefulWidget {
  final Meal meal;
  const MealDetailCustomizerScreen({super.key, required this.meal});

  @override
  State<MealDetailCustomizerScreen> createState() => _MealDetailCustomizerScreenState();
}

class _MealDetailCustomizerScreenState extends State<MealDetailCustomizerScreen> {
  late MealCustomization _customization;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _customization = MealCustomization();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meal = widget.meal;
    final state = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(meal.image, height: 220, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${meal.price.toStringAsFixed(0)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('${meal.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    meal.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  if (meal.category != 'Juice' && meal.category != 'Snacks' && meal.category != 'Grocery') ...[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🍳', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                state.translate('Clinician-Recommended Recovery Booster'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                const Text('🥚', style: TextStyle(fontSize: 18)),
                                Text(meal.category == 'Lunch' ? ' 🍎' : ' 🍌', style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    meal.category == 'Lunch'
                                        ? state.translate('Add Boiled Egg & Organic Apple (+₹20)')
                                        : state.translate('Add Boiled Egg & Organic Banana (+₹20)'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B1B1B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              state.translate('Delivers clean amino acids and potassium for rapid clinical recovery.'),
                              style: const TextStyle(fontSize: 10, color: Color(0xFF777777)),
                            ),
                            value: _customization.addonEggBanana,
                            activeColor: Colors.orange,
                            onChanged: (val) => setState(() => _customization.addonEggBanana = val ?? false),
                          ),
                          const Divider(height: 16, color: Color(0xFFE0E0E0)),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                const Text('🥛', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.translate('Add Fresh Low-Fat Yogurt (Curd) (+₹15)'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B1B1B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              state.translate('High in gut-friendly probiotics, soothing for recovering digestion.'),
                              style: const TextStyle(fontSize: 10, color: Color(0xFF777777)),
                            ),
                            value: _customization.extraCurd,
                            activeColor: Colors.orange,
                            onChanged: (val) => setState(() => _customization.extraCurd = val ?? false),
                          ),
                        ],
                      ),
                    ),
                    _buildJuicePairingRecommendation(context, state),
                    const SizedBox(height: 12),
                  ],

                  // CLINICAL DIRECTIVES SECTION
                  const Divider(),
                  // Salt preference dropdown
                  DropdownButtonFormField<String>(
                    value: _customization.saltPreference,
                    decoration: const InputDecoration(labelText: 'Salt Level Directive', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Normal', child: Text('Normal Salt')),
                      DropdownMenuItem(value: 'Less Salt', child: Text('Less Salt (Cardiac Safe)')),
                      DropdownMenuItem(value: 'No Salt', child: Text('No Salt (Strict Clinical)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _customization.saltPreference = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Spice preference dropdown
                  DropdownButtonFormField<String>(
                    value: _customization.spicePreference,
                    decoration: const InputDecoration(labelText: 'Spice Level Directive', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Normal', child: Text('Standard Mild')),
                      DropdownMenuItem(value: 'Less Spice', child: Text('Extremely Mild (Ulcer Safe)')),
                      DropdownMenuItem(value: 'More Spice', child: Text('Normal Spicy')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _customization.spicePreference = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildClinicalRecommendations(context, state),

                  // Reviews List
                  if (meal.reviews.isNotEmpty) ...[
                    const Divider(),
                    const Text('Bedside Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    ...meal.reviews.map((r) {
                      return ListTile(
                        title: Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(r.comment, style: const TextStyle(fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            Text('${r.rating}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _addToCartAndClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Add to Tray', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalRecommendations(BuildContext context, AppState state) {
    final diagnosis = state.currentUser?.patientDetails?.diagnosis;
    final isPatient = state.currentUser?.role == UserRole.Patient;

    final recommendedMeals = STAT_MEALS.where((meal) {
      if (meal.isDoctorRecommended != true) return false;
      if (meal.id == widget.meal.id) return false;
      if (isPatient && diagnosis != null && diagnosis.isNotEmpty) {
        final userDiag = diagnosis.toLowerCase();
        if (meal.clinicalTags != null) {
          return meal.clinicalTags!.any((tag) {
            final cleanTag = tag.toLowerCase();
            return cleanTag.contains(userDiag) || userDiag.contains(cleanTag) ||
                   cleanTag.split(' ')[0].contains(userDiag.split(' ')[0]);
          });
        }
      }
      return true;
    }).toList();

    if (recommendedMeals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 16),
            const SizedBox(width: 6),
            Text(
              isPatient && diagnosis != null && diagnosis.isNotEmpty
                  ? '🩺 ${state.translate('Recovery Diet for')} ${state.translate(diagnosis)}'
                  : '🩺 ${state.translate('Clinical Choice Diets')}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          state.translate('Tailored clean nutrition designed for quick recovery.'),
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF777777)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedMeals.length,
            itemBuilder: (context, idx) {
              final recMeal = recommendedMeals[idx];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8F5E9).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        recMeal.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.translate(recMeal.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${recMeal.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 22,
                            child: ElevatedButton(
                              onPressed: () {
                                state.addToCart(
                                  recMeal,
                                  MealCustomization(
                                    saltPreference: 'Normal',
                                    spicePreference: 'Normal',
                                    doubleSealedHeated: true,
                                    clinicalApprovedOnly: false,
                                  ),
                                  1,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${state.translate(recMeal.name)} ${state.translate('added to tray!')}'),
                                    backgroundColor: const Color(0xFF2E7D32),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Text(
                                state.translate('+ Add'),
                                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildJuicePairingRecommendation(BuildContext context, AppState state) {
    final meal = widget.meal;
    if (meal.category == 'Juice' || meal.category == 'Snacks' || meal.category == 'Grocery') {
      return const SizedBox.shrink();
    }

    final juiceId = meal.isVeg ? "jc-coconut" : "jc-beetroot";
    // Find the juice meal from STAT_MEALS
    final juiceMeal = STAT_MEALS.firstWhere(
      (m) => m.id == juiceId,
      orElse: () => STAT_MEALS.firstWhere((m) => m.category == 'Juice', orElse: () => STAT_MEALS[0]),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.apple, color: Color(0xFFFF9800), size: 16),
              const SizedBox(width: 6),
              Text(
                state.translate('Recommended Juice Pairing'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    juiceMeal.image,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.translate(juiceMeal.name),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        juiceMeal.id == 'jc-coconut'
                            ? state.translate('Fresh tender coconut water rich in organic potassium & rehydrating electrolytes to soothe digestive walls.')
                            : state.translate('Enriched with Vitamin C to double natural iron absorption from non-veg proteins.'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF777777),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      state.addToCart(
                        juiceMeal,
                        MealCustomization(
                          saltPreference: 'Normal',
                          spicePreference: 'Normal',
                          doubleSealedHeated: true,
                          clinicalApprovedOnly: false,
                        ),
                        1,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${state.translate(juiceMeal.name)} ${state.translate('added to your tray!')}'),
                          backgroundColor: const Color(0xFF2E7D32),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      state.translate('+ Add'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCartAndClose() {
    Provider.of<AppState>(context, listen: false).addToCart(widget.meal, _customization, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.meal.name} added to your clinical meal tray!'),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 1),
      ),
    );
    Navigator.pop(context);
  }
}
