import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';
import 'package:cura_meal/screens/clinical_checkin_sheet.dart';

class CartAndCheckoutScreen extends StatefulWidget {
  const CartAndCheckoutScreen({super.key});

  @override
  State<CartAndCheckoutScreen> createState() => _CartAndCheckoutScreenState();
}

class _CartAndCheckoutScreenState extends State<CartAndCheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wardController = TextEditingController();
  final _roomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _dropOffPoint = 'NurseStation'; // 'NurseStation', 'WardDoor', 'Lobby'
  bool _isPriceStructureExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      if (state.currentUser != null && state.currentUser!.phone == 'Guest') {
        _nameController.text = state.currentUser!.patientDetails?.patientName ?? 'Guest Patient';
        _phoneController.text = '';
        _wardController.text = state.currentUser!.patientDetails?.ward ?? 'General';
        _roomController.text = state.currentUser!.patientDetails?.roomNumber ?? 'G-10';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wardController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Widget _buildGuestBedsideForm(BuildContext context, AppState state) {
    return Form(
      key: _formKey,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shadowColor: const Color(0xFF2E7D32).withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.room_service, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Bedside Delivery Details (Guest)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Please enter your bedside coordinates to route the sterile delivery directly to your ward.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              
              // Recovery Guest Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Recovery Guest Full Name',
                  labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter guest name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Mobile Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 10) {
                    return 'Please enter 10-digit mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Ward & Room/Bed Number Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _wardController,
                      decoration: InputDecoration(
                        labelText: 'Ward/Unit (e.g. General)',
                        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _roomController,
                      decoration: InputDecoration(
                        labelText: 'Room/Bed No (e.g. G-10)',
                        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Hospital Tray', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: state.cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 72, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Your nutrition tray is empty.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Browse NutriMenu to add healthy items.', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ...state.cart.map((item) {
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(item.meal.image, width: 60, height: 60, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(
                                            '₹${item.meal.price.toStringAsFixed(0)} each',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => state.removeFromCart(item.id),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    'Custom: ${item.customization.summary}',
                                    style: TextStyle(fontSize: 11, color: Colors.teal[800], fontStyle: FontStyle.italic),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () => state.updateCartItemQuantity(item.id, item.quantity - 1),
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      onPressed: () => state.updateCartItemQuantity(item.id, item.quantity + 1),
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      _buildJuiceSuggestions(context, state),
                      const SizedBox(height: 8),
                      _buildFamilyAttendantSuggestions(context, state),
                      const SizedBox(height: 8),
                      _buildDropOffPointSelector(),
                    ],
                  ),
                ),

                // Applied Coupon Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: state.currentCoupon.isNotEmpty
                            ? Text(
                                'Applied: ${state.currentCoupon} (Discount Active)',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              )
                            : const Text('Do you have an admission coupon?'),
                      ),
                      state.currentCoupon.isNotEmpty
                          ? TextButton(
                              onPressed: () => state.removeCoupon(),
                              child: const Text('REMOVE'),
                            )
                          : TextButton(
                              onPressed: () => _showCouponModal(context, state),
                              child: const Text('APPLY'),
                            )
                    ],
                  ),
                ),

                // Summary Bills Panel
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isPriceStructureExpanded = !_isPriceStructureExpanded;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isPriceStructureExpanded) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal'),
                                  Text('₹${state.cartSubtotal.toStringAsFixed(2)}'),
                                ],
                              ),
                              if (state.couponDiscountAmount > 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Coupon Discount', style: TextStyle(color: Colors.green)),
                                    Text('-₹${state.couponDiscountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                                  ],
                                ),
                              if (state.scheduleDiscountAmount > 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Clinical Schedule Savings', style: TextStyle(color: Colors.green)),
                                    Text('-₹${state.scheduleDiscountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                                  ],
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Bedside CGST (5%)'),
                                  Text('₹${state.gstCharge.toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Special Ward Delivery Fee'),
                                  Text('₹${state.deliveryCharge.toStringAsFixed(2)}'),
                                ],
                              ),
                              const Divider(),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isPriceStructureExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${state.cartGrandTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          final isGuest = state.currentUser == null || state.currentUser!.phone == 'Guest';
                          if (isGuest) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => ClinicalCheckInSheet(
                                onComplete: () {
                                  // Short delay to allow the bottom sheet animation to close smoothly
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    state.checkoutOrder();
                                    Navigator.pop(context); // Go back to Home
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Clinical details linked & nourishment request locked! Delivery started to your bedside.'),
                                        backgroundColor: Color(0xFF2E7D32),
                                      ),
                                    );
                                  });
                                },
                              ),
                            );
                          } else {
                            state.checkoutOrder();
                            Navigator.pop(context); // Go back to Home
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nourishment request locked! Delivery started to your bedside.'),
                                backgroundColor: Color(0xFF2E7D32),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Confirm & Dispatch Bedside Delivery',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildJuiceSuggestions(BuildContext context, AppState state) {
    final List<String> cartItemMealIds = state.cart.map((item) => item.meal.id).toList();
    final List<Meal> juiceSuggestions = STAT_MEALS.where((meal) {
      return (meal.category == 'Juice' || meal.category == 'Liquid Diets' || meal.id.contains('juice') || meal.id.contains('coconut')) && !cartItemMealIds.contains(meal.id);
    }).toList();

    if (juiceSuggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_cafe_outlined, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              const Text(
                'Hydrating Beverages & Pure Juices',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '100% Sterile',
                  style: TextStyle(fontSize: 9, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep hydrated with fresh juices and clinical liquid nutrition options:',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: juiceSuggestions.length,
              itemBuilder: (ctx, index) {
                final meal = juiceSuggestions[index];
                return Container(
                  width: 175,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFBF7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(meal.image, width: 45, height: 45, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              meal.name,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₹${meal.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 9, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                state.addToCart(
                                  meal,
                                  MealCustomization(
                                    saltPreference: 'Normal',
                                    spicePreference: 'Normal',
                                    extraRice: false,
                                    extraCurry: false,
                                    doubleSealedHeated: true,
                                    clinicalApprovedOnly: false,
                                  ),
                                  1,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${meal.name} added to your tray!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(
                                  child: Text(
                                    '+ ADD',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFamilyAttendantSuggestions(BuildContext context, AppState state) {
    final List<String> cartItemMealIds = state.cart.map((item) => item.meal.id).toList();
    final List<Meal> suggestions = STAT_MEALS.where((meal) {
      return (meal.category == 'Grocery' || meal.id == 'sd-khichdi') && !cartItemMealIds.contains(meal.id);
    }).toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.family_restroom, size: 16, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              const Text(
                'Attendant & Family Meal Suggestions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Bedside Guest Stay',
                  style: TextStyle(fontSize: 9, color: Color(0xFF0F766E), fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Family attendants staying overnight? Add hydrating drinks or healthy recovery snacks:',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.take(3).length,
              itemBuilder: (ctx, index) {
                final meal = suggestions[index];
                return Container(
                  width: 175,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(meal.image, width: 45, height: 45, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              meal.name,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₹${meal.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                state.addToCart(
                                  meal,
                                  MealCustomization(
                                    saltPreference: 'Standard',
                                    spicePreference: 'Mild',
                                    extraRice: false,
                                    extraCurry: false,
                                    doubleSealedHeated: true,
                                    clinicalApprovedOnly: false,
                                  ),
                                  1,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${meal.name} added to your tray!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(
                                  child: Text(
                                    '+ ADD',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showCouponModal(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Enter Promo Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Try HEAL100, RECOVER50, or NUTRIFIT', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter Coupon Code'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final succ = state.applyCoupon(controller.text);
                  Navigator.pop(ctx);
                  if (!succ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid coupon code.'), backgroundColor: Colors.red),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                child: const Text('Apply Coupon', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropOffPointSelector() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.delivery_dining, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Drop-off Point Choice',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDropOffOptionTile('NurseStation', 'Leave at Nurse’s Station Desk', 'Recommended for quiet rest'),
            const Divider(height: 1),
            _buildDropOffOptionTile('WardDoor', 'Hand over silently at Ward Door', 'Safe contact-free handoff'),
            const Divider(height: 1),
            _buildDropOffOptionTile('Lobby', 'Meet outside Main Lobby', 'For patient relatives & guests'),
          ],
        ),
      ),
    );
  }

  Widget _buildDropOffOptionTile(String val, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<String>(
        value: val,
        groupValue: _dropOffPoint,
        activeColor: const Color(0xFF2E7D32),
        onChanged: (newVal) {
          if (newVal != null) {
            setState(() => _dropOffPoint = newVal);
          }
        },
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      onTap: () {
        setState(() => _dropOffPoint = val);
      },
    );
  }
}
