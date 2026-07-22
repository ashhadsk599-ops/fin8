import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';
import 'package:cura_meal/screens/meal_detail_customizer_screen.dart';
import 'package:cura_meal/screens/cart_and_checkout_screen.dart';
import 'package:cura_meal/screens/notifications_log_screen.dart';
import 'package:cura_meal/screens/hospital_portal_screen.dart';

class MealDashboardScreen extends StatefulWidget {
  const MealDashboardScreen({super.key});

  @override
  State<MealDashboardScreen> createState() => _MealDashboardScreenState();
}

class _MealDashboardScreenState extends State<MealDashboardScreen> {
  String _selectedCategory = 'Breakfast';
  String _selectedRoleMenu = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['Breakfast', 'Soup', 'Lunch', 'Juice', 'Snacks', 'Grocery'];

  late PageController _carouselController;
  int _carouselIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(initialPage: 0);
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _carouselController.hasClients) {
        final nextPage = (_carouselIndex + 1) % 4;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  String _greetingText() {
    final hr = DateTime.now().hour;
    if (hr < 12) return 'Good Morning ☀️';
    if (hr < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final hospital = state.selectedHospital;
    final userName = state.currentUser?.role == UserRole.Patient
        ? state.currentUser?.patientDetails?.patientName
        : state.currentUser?.employeeDetails?.employeeName;

    // Filter meals based on selected category, role menu selection, and search query
    final filteredMeals = STAT_MEALS.where((m) {
      // 1. Role Menu Filter
      if (_selectedRoleMenu == 'Light & Healing') {
        if (m.category == 'Grocery') return false;
        final match = m.isDoctorRecommended || m.category == 'Soup' || (m.isVeg && m.category == 'Breakfast') || m.id == 'jc-coconut';
        if (!match) return false;
      } else if (_selectedRoleMenu == 'High Energy') {
        if (m.category == 'Grocery') return false;
        final match = m.nutrition.calories >= 250 || m.nutrition.protein >= 12 || !m.isVeg || m.id == 'bf-doc-nonveg' || m.id == 'lh-doc-nonveg' || m.id == 'sp-chicken' || m.id == 'sn-sprouts';
        if (!match) return false;
      } else if (_selectedRoleMenu == 'For the Family') {
        if (m.category == 'Grocery') return false;
        final match = m.category == 'Lunch' || m.category == 'Snacks' || m.id == 'jc-watermelon' || m.id == 'jc-lime' || m.id == 'jc-orange';
        if (!match) return false;
      } else if (_selectedRoleMenu == 'Bedside Essentials') {
        if (m.category != 'Grocery') return false;
      } else {
        // 'All': exclude grocery by default unless category is selected as Grocery
        if (_selectedCategory != 'Grocery' && m.category == 'Grocery') return false;
      }

      // 2. Category Filter (skip if Bedside Essentials, which displays groceries only)
      if (_selectedRoleMenu != 'Bedside Essentials' && _selectedCategory != 'All') {
        if (m.category != _selectedCategory) return false;
      }

      // 3. Search Query Filter
      final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7), // Brand cream background
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2E7D32).withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              state.translate('Cura Meal'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E7D32),
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${state.cart.length}'),
              isLabelVisible: state.cart.isNotEmpty,
              child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2E7D32), size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartAndCheckoutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF2E7D32), size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsLogScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopGreetingBanner(context, state, hospital, userName),
            _buildSendCarePackBanner(context),
            _buildDishesCarousel(context),
            _buildDoctorRecommendedSection(context, state),
            _buildCategoriesSection(context),
            _buildMenuTitleSection(),
            _buildMealsList(context, state, filteredMeals, theme),
            _buildSupportingLists(context, state),
            _buildOffersCarousel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDishesCarousel(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    
    // Find the 4 carousel meals by ID
    final carouselMeals = STAT_MEALS.where((meal) => 
      meal.id == 'bf-doc-veg' || 
      meal.id == 'lh-doc-veg' || 
      meal.id == 'sp-chicken' || 
      meal.id == 'sn-fruit-bowl'
    ).toList();

    if (carouselMeals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            state.translate('Featured Healing Dishes'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E7D32),
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() {
                _carouselIndex = index;
              });
            },
            itemCount: carouselMeals.length,
            itemBuilder: (ctx, idx) {
              final meal = carouselMeals[idx];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailCustomizerScreen(meal: meal),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          meal.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.65),
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            state.translate(meal.category.toUpperCase()),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.translate(meal.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.translate(meal.description),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _carouselIndex == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _carouselIndex == index ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTopGreetingBanner(BuildContext context, AppState state, Hospital? hospital, String? userName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFFFFDF7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.translate(_greetingText())} • ${state.currentUser != null ? (state.currentUser!.role == UserRole.Patient ? state.translate('Recovery Guest') : state.translate('Hospital Staff')) : state.translate('Guest')}',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.translate('Hello')}, ${userName ?? state.translate('Admitted Guest')}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.translate('What clean nutrition do you need today?'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  if (!state.isLoadingLocation) {
                    state.fetchLiveLocation();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  constraints: const BoxConstraints(maxWidth: 155),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8F5E9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isLoadingLocation)
                            const SizedBox(
                              width: 8,
                              height: 8,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Color(0xFFFF9800),
                              ),
                            )
                          else
                            const Icon(
                              Icons.location_on,
                              size: 10,
                              color: Color(0xFFFF9800),
                            ),
                          const SizedBox(width: 4),
                          Text(
                            state.translate('YOUR LOCATION'),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.isLoadingLocation ? state.translate('Locating...') : state.userLiveLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: state.isLoadingLocation ? Colors.grey : const Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        state.translate('Tap to refresh GPS'),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffersCarousel(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final offers = [
      {
        'code': 'HEAL100',
        'title': 'First Order Special',
        'description': 'Get ₹100 flat discount on your first healthy order.',
        'min': '250',
      },
      {
        'code': 'RECOVER50',
        'title': 'Get Well Soon Discount',
        'description': 'Enjoy 15% off up to ₹150 for all nutritious meals.',
        'min': '200',
      },
      {
        'code': 'NUTRIFIT',
        'title': 'High Protein Discount',
        'description': 'Flat 10% off for custom high-protein lunches.',
        'min': '150',
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.translate('Healthy Offers & Coupons'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E7D32),
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.translate('Promo codes can be applied in your Tray & Checkout!')),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      state.translate('See all'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF9800)),
                    ),
                    const Icon(Icons.chevron_right, size: 14, color: Color(0xFFFF9800)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: offers.length,
            itemBuilder: (ctx, idx) {
              final offer = offers[idx];
              return Container(
                width: 240,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -12,
                      bottom: -12,
                      child: Icon(
                        Icons.stars_rounded,
                        size: 48,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            offer['code']!,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.translate(offer['title']!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFFDF7),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          state.translate(offer['description']!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: const Color(0xFFFFFDF7).withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${state.translate('Min. order value')} ₹${offer['min']}',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorRecommendedSection(BuildContext context, AppState state) {
    final diagnosis = state.currentUser?.patientDetails?.diagnosis;
    final isPatient = state.currentUser?.role == UserRole.Patient;

    final recommendedMeals = STAT_MEALS.where((meal) {
      if (meal.isDoctorRecommended != true) return false;
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite, size: 14, color: Color(0xFFFF9800)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPatient && diagnosis != null && diagnosis.isNotEmpty
                          ? '🩺 ${state.translate('Recovery Diet for')} ${state.translate(diagnosis)}'
                          : '🩺 ${state.translate('Clinical Choice Diets')}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      state.translate('Tailored clean nutrition designed for quick recovery.'),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...recommendedMeals.take(3).map((meal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(6),
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
                      meal.image,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: meal.isVeg ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              meal.isVeg ? state.translate('VEG') : state.translate('NON-VEG'),
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                color: meal.isVeg ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                state.translate('RECOMMENDED'),
                                style: const TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.translate(meal.name),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          meal.clinicalDiagnosisSuggestion != null ? state.translate(meal.clinicalDiagnosisSuggestion!) : state.translate(meal.description),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${meal.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () {
                          state.addToCart(
                            meal,
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
                              content: Text('${state.translate(meal.name)} ${state.translate('added to tray!')}'),
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          minimumSize: const Size(52, 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          state.translate('+ Add Diet'),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRoleMenuSelectorSection(BuildContext context, AppState state) {
    final menus = [
      {
        'id': 'All',
        'title': 'Full Diet Menu',
        'subtitle': 'All clinical dishes',
        'icon': Icons.menu_book,
        'color': const Color(0xFF2E7D32),
      },
      {
        'id': 'Light & Healing',
        'title': 'Guest Recovery',
        'subtitle': 'Low salt, easy digestion',
        'icon': Icons.healing,
        'color': const Color(0xFFE53935),
      },
      {
        'id': 'High Energy',
        'title': 'Staff & Caregivers',
        'subtitle': 'Protein rich meals',
        'icon': Icons.bolt,
        'color': const Color(0xFFFF9800),
      },
      {
        'id': 'For the Family',
        'title': 'Attendant & Family',
        'subtitle': 'Balanced visitor dining',
        'icon': Icons.family_restroom,
        'color': const Color(0xFF1E88E5),
      },
      {
        'id': 'Bedside Essentials',
        'title': 'Stay Essentials',
        'subtitle': 'Sanitizer, wipes & care',
        'icon': Icons.dry_cleaning,
        'color': const Color(0xFF8E24AA),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            state.translate('Specialized Nutrition Menus'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E7D32),
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: menus.length,
            itemBuilder: (ctx, idx) {
              final m = menus[idx];
              final isSelected = _selectedRoleMenu == m['id'];
              final color = m['color'] as Color;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedRoleMenu = m['id'] as String;
                    if (_selectedRoleMenu == 'Bedside Essentials') {
                      _selectedCategory = 'Grocery';
                    } else if (_selectedCategory == 'Grocery') {
                      _selectedCategory = 'Breakfast';
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 175,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE8F5E9),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          m['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.translate(m['title'] as String),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : const Color(0xFF1B1B1B),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              state.translate(m['subtitle'] as String),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    if (_selectedRoleMenu == 'Bedside Essentials') {
      return const SizedBox.shrink();
    }
    final state = Provider.of<AppState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            state.translate('Dietary & Stay Essentials'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E7D32),
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (ctx, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              
              String displayLabel = cat;
              if (cat == 'Breakfast') displayLabel = '🥣 ${state.translate('Breakfast')}';
              else if (cat == 'Soup') displayLabel = '🍲 ${state.translate('Soup')}';
              else if (cat == 'Lunch') displayLabel = '🍛 ${state.translate('Lunch')}';
              else if (cat == 'Juice') displayLabel = '🥤 ${state.translate('Juice')}';
              else if (cat == 'Snacks') displayLabel = '🍎 ${state.translate('Snacks')}';
              else if (cat == 'Grocery') displayLabel = '📦 ${state.translate('Essentials')}';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    displayLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2E7D32),
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTitleSection() {
    final state = Provider.of<AppState>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${state.translate("Today's Healthy Menu")}: ${state.translate(_selectedCategory)} ${state.translate('Specials')}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            state.translate("Sterilized bedside dining directly to your clinical room."),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(BuildContext context, AppState state, List<Meal> meals, ThemeData theme) {
    if (meals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            state.translate('No matching nutritious dishes found under this selection.'),
            style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF777777)),
          ),
        ),
      );
    }

    return Column(
      children: meals.map((meal) => _buildMealCard(context, state, meal, theme)).toList(),
    );
  }

  Widget _buildMealCard(BuildContext context, AppState state, Meal meal, ThemeData theme) {
    final isFav = state.favorites.contains(meal.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MealDetailCustomizerScreen(meal: meal),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    meal.image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: meal.isVeg ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              meal.isVeg ? state.translate('VEG') : state.translate('NON-VEG'),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B1B1B),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (meal.isDoctorRecommended == true) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Colors.white, size: 9),
                              const SizedBox(width: 3),
                              Text(
                                state.translate('PRESCRIBED'),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () => state.toggleFavorite(meal.id),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 14,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xFFE53935),
                        size: 16,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: const Color(0xFFFFFDF7).withOpacity(0.9),
                      child: meal.category == 'Grocery'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.inventory_2_outlined, color: Colors.orange, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      state.translate('ESSENTIAL'),
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFF9800), size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${meal.rating}',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B1B1B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.flash_on, color: Color(0xFFFF9800), size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${meal.nutrition.calories} kcal',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.fitness_center, color: Color(0xFF4CAF50), size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${meal.nutrition.protein}g ${state.translate('Protein')}',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFF9800), size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${meal.rating}',
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B1B1B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.translate(meal.name),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    state.translate(meal.description),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777777),
                      height: 1.35,
                    ),
                  ),
                  if (meal.isDoctorRecommended == true) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                '${state.translate('Clinical Choice')}:',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meal.clinicalDiagnosisSuggestion != null ? state.translate(meal.clinicalDiagnosisSuggestion!) : '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF1B1B1B),
                              height: 1.3,
                            ),
                          ),
                          if (meal.clinicalTags != null && meal.clinicalTags!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: meal.clinicalTags!.map((tag) {
                                final patientDiag = state.currentUser?.patientDetails?.diagnosis;
                                final matchesPatient = patientDiag != null && tag.toLowerCase().contains(patientDiag.split(' ')[0].toLowerCase());
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: matchesPatient ? const Color(0xFF2E7D32) : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    state.translate(tag),
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: matchesPatient ? Colors.white : const Color(0xFF777777),
                                      fontWeight: matchesPatient ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          ]
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFE8F5E9)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('PRICE'),
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF777777)),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '₹${meal.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MealDetailCustomizerScreen(meal: meal),
                                ),
                              );
                            },
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 12),
                            label: Text(state.translate('Details'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B1B1B),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            onPressed: () {
                              state.addToCart(
                                meal,
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
                                  content: Text('${state.translate(meal.name)} ${state.translate('added to tray!')}'),
                                  backgroundColor: const Color(0xFF2E7D32),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 12),
                            label: Text(state.translate('Add'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSupportingLists(BuildContext context, AppState state) {
    final popularMeals = STAT_MEALS.where((m) => m.isPopular == true).toList();
    final specialMeals = STAT_MEALS.where((m) => m.isHealthySpecial == true).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.translate('⭐ Popular Choices'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 6),
          ...popularMeals.take(2).map((meal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8F5E9)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      meal.image,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.translate(meal.name),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${meal.nutrition.calories} kcal',
                              style: const TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: Color(0xFFFF9800), size: 10),
                            const SizedBox(width: 2),
                            Text(
                              '${meal.rating}',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      state.addToCart(
                        meal,
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
                          content: Text('${state.translate(meal.name)} ${state.translate('added to tray!')}'),
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Color(0xFF2E7D32), size: 16),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      minimumSize: const Size(28, 28),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(
            state.translate('🩺 Clinically Supervised'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 6),
          ...specialMeals.take(2).map((meal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8F5E9)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      meal.image,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.translate(meal.name),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${meal.nutrition.calories} kcal',
                              style: const TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: Color(0xFFFF9800), size: 10),
                            const SizedBox(width: 2),
                            Text(
                              '${meal.rating}',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      state.addToCart(
                        meal,
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
                          content: Text('${state.translate(meal.name)} ${state.translate('added to tray!')}'),
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Color(0xFF2E7D32), size: 16),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      minimumSize: const Size(28, 28),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }



  Widget _buildSendCarePackBanner(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const SendCarePackDialog(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.translate('Send a Care Pack to a Loved One in the Hospital'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class SendCarePackDialog extends StatefulWidget {
  const SendCarePackDialog({super.key});

  @override
  State<SendCarePackDialog> createState() => _SendCarePackDialogState();
}

class _SendCarePackDialogState extends State<SendCarePackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _lovedOneNameController = TextEditingController();
  final _wardController = TextEditingController();
  final _roomController = TextEditingController();
  String _selectedHospitalId = STAT_HOSPITALS[0].id;
  String _errorText = '';

  @override
  void dispose() {
    _lovedOneNameController.dispose();
    _wardController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9800).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    state.translate('HOSPITAL SUPPORT'),
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF9800),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.translate('Send a Care Pack'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  state.translate('Pre-order steaming breakfast, healthy warm lunches, fresh cold-pressed juices, and caregiver overnight comfort bundles for a relative staying overnight in the hospital.'),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 16),
                if (_errorText.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFF59D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.translate(_errorText),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Name Input
                Text(
                  state.translate("Loved One's Full Name (Relative staying)"),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _lovedOneNameController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: state.translate('e.g. Rayan Ahmed'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                  ),
                ),
                const SizedBox(height: 14),
                // Hospital Selection Dropdown
                Text(
                  state.translate('Hospital Location'),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedHospitalId,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedHospitalId = val);
                        }
                      },
                      items: STAT_HOSPITALS.map((h) {
                        return DropdownMenuItem<String>(
                          value: h.id,
                          child: Text('${state.translate(h.name)} (${state.translate(h.location)})'),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Ward & Room (Horizontal Grid)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('Ward Number'),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _wardController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: state.translate('e.g. Ward 4B'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('Room / Bed Number'),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _roomController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: state.translate('e.g. Bed 102'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8F5E9)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFFFF9800), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.translate('We prepare every care pack in sterilized kitchens with non-greasy recipes, then transport them directly inside hospital gates for secure bedside hand-off.'),
                          style: const TextStyle(fontSize: 10, color: Color(0xFF2E7D32), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_lovedOneNameController.text.trim().isEmpty) {
                      setState(() => _errorText = "Please enter your loved one's name");
                      return;
                    }
                    if (_wardController.text.trim().isEmpty) {
                      setState(() => _errorText = "Please enter a ward number");
                      return;
                    }
                    if (_roomController.text.trim().isEmpty) {
                      setState(() => _errorText = "Please enter a room number");
                      return;
                    }

                    setState(() => _errorText = '');
                    state.sendCarePack(
                      lovedOneName: _lovedOneNameController.text.trim(),
                      hospitalId: _selectedHospitalId,
                      ward: _wardController.text.trim(),
                      roomNumber: _roomController.text.trim(),
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${state.translate("Care Pack Enabled! 🎁 Pre-ordering for")} ${_lovedOneNameController.text.trim()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        state.translate('Select Diets & Essentials').toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
