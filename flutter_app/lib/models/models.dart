import 'dart:convert';
import 'package:flutter/material.dart';

enum UserRole { Patient, Employee }

class Hospital {
  final String id;
  final String name;
  final String image;
  final String location;
  final double rating;

  Hospital({
    required this.id,
    required this.name,
    required this.image,
    required this.location,
    required this.rating,
  });
}

class PatientDetails {
  final String roomNumber;
  final String ward;
  final String patientName;
  final String notes;
  final String diagnosis;

  PatientDetails({
    required this.roomNumber,
    required this.ward,
    required this.patientName,
    required this.notes,
    this.diagnosis = 'General Recovery',
  });
}

class EmployeeDetails {
  final String employeeName;
  final String department;
  final String employeeId;

  EmployeeDetails({
    required this.employeeName,
    required this.department,
    required this.employeeId,
  });
}

class UserProfile {
  final String phone;
  final UserRole role;
  final String selectedHospitalId;
  final PatientDetails? patientDetails;
  final EmployeeDetails? employeeDetails;

  UserProfile({
    required this.phone,
    required this.role,
    required this.selectedHospitalId,
    this.patientDetails,
    this.employeeDetails,
  });
}

class Nutrition {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int prepTimeMinutes;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTimeMinutes,
  });
}

class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class Meal {
  final String id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final String category; // 'Breakfast', 'Soft Diets', 'Liquid Diets', 'High Protein'
  final bool isVeg;
  final bool isPopular;
  final bool isHealthySpecial;
  final String description;
  final List<String> ingredients;
  final Nutrition nutrition;
  final List<Review> reviews;
  final bool isDoctorRecommended;
  final String? clinicalDiagnosisSuggestion;
  final List<String>? clinicalTags;

  Meal({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.category,
    required this.isVeg,
    this.isPopular = false,
    this.isHealthySpecial = false,
    required this.description,
    required this.ingredients,
    required this.nutrition,
    required this.reviews,
    this.isDoctorRecommended = false,
    this.clinicalDiagnosisSuggestion,
    this.clinicalTags,
  });
}

class MealCustomization {
  bool extraRice;
  bool extraCurry;
  String saltPreference; // 'Normal', 'No Salt', 'Less Salt'
  String spicePreference; // 'Normal', 'Less Spice', 'More Spice'
  bool noOnion;
  bool noGarlic;
  bool extraSalad;
  bool extraCurd;
  String specialInstructions;
  bool doubleSealedHeated; // Thermal option
  bool clinicalApprovedOnly; // Approved clinical ingredients option
  bool addonEggBanana;

  MealCustomization({
    this.extraRice = false,
    this.extraCurry = false,
    this.saltPreference = 'Normal',
    this.spicePreference = 'Normal',
    this.noOnion = false,
    this.noGarlic = false,
    this.extraSalad = false,
    this.extraCurd = false,
    this.specialInstructions = '',
    this.doubleSealedHeated = false,
    this.clinicalApprovedOnly = false,
    this.addonEggBanana = false,
  });

  MealCustomization copy() {
    return MealCustomization(
      extraRice: extraRice,
      extraCurry: extraCurry,
      saltPreference: saltPreference,
      spicePreference: spicePreference,
      noOnion: noOnion,
      noGarlic: noGarlic,
      extraSalad: extraSalad,
      extraCurd: extraCurd,
      specialInstructions: specialInstructions,
      doubleSealedHeated: doubleSealedHeated,
      clinicalApprovedOnly: clinicalApprovedOnly,
      addonEggBanana: addonEggBanana,
    );
  }

  String get summary {
    List<String> parts = [];
    if (saltPreference != 'Normal') parts.add('Salt: $saltPreference');
    if (spicePreference != 'Normal') parts.add('Spice: $spicePreference');
    if (extraRice) parts.add('+Extra Rice');
    if (extraCurry) parts.add('+Extra Curry');
    if (noOnion) parts.add('No Onion');
    if (noGarlic) parts.add('No Garlic');
    if (extraSalad) parts.add('+Salad');
    if (extraCurd) parts.add('+Curd');
    if (addonEggBanana) parts.add('+Egg & Fruit');
    if (doubleSealedHeated) parts.add('Double Sealed (Heated)');
    if (clinicalApprovedOnly) parts.add('Clinical Approved Ingredients');
    if (specialInstructions.isNotEmpty) parts.add('Note: "$specialInstructions"');
    return parts.isEmpty ? 'Default Preparation' : parts.join(', ');
  }
}

class CartItem {
  final String id; // unique cart item id (mealId + customization details)
  final Meal meal;
  int quantity;
  final MealCustomization customization;

  CartItem({
    required this.id,
    required this.meal,
    required this.quantity,
    required this.customization,
  });
}

enum OrderStatus { Received, Preparing, OutForDelivery, Delivered }

class ActiveOrder {
  final String id;
  final String orderNumber;
  final List<CartItem> items;
  final String hospitalId;
  final String hospitalName;
  final double grandTotal;
  OrderStatus status;
  final DateTime createdAt;
  final String? patientName;
  final String? patientRoom;
  final String? patientWard;
  final String? patientDiagnosis;

  ActiveOrder({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.hospitalId,
    required this.hospitalName,
    required this.grandTotal,
    required this.status,
    required this.createdAt,
    this.patientName,
    this.patientRoom,
    this.patientWard,
    this.patientDiagnosis,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

// =========================================================================
// 2. STATIC DATABASE & VALUES
// =========================================================================

final List<String> STAT_DIAGNOSES = [
  'General Recovery',
  'Post-Surgery Recovery',
  'Diabetes Management',
  'Hypertension & Cardiac Care',
  'Gastroenteritis',
  'Maternity & Lactation',
  'High Protein Recovery',
  'Orthopedic Healing'
];

final List<Hospital> STAT_HOSPITALS = [
  Hospital(
    id: 'bgh',
    name: 'Government Hospital',
    image: 'https://images.unsplash.com/photo-1587351021355-a479a299d2f9?auto=format&fit=crop&q=80&w=400',
    location: 'Bunder Road, Bhatkal, KA',
    rating: 4.2,
  ),
  Hospital(
    id: 'welfare',
    name: 'Welfare Hospital',
    image: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=400',
    location: 'Sowda Cargo Street, Bhatkal, KA',
    rating: 4.7,
  ),
  Hospital(
    id: 'shamsnoor',
    name: 'Shams Noor Hospital',
    image: 'https://images.unsplash.com/photo-1586773860418-d3b3da9601ee?auto=format&fit=crop&q=80&w=400',
    location: 'Shamsuddin Circle, Bhatkal, KA',
    rating: 4.5,
  ),
  Hospital(
    id: 'asiya',
    name: 'Asiya Hospital',
    image: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=400',
    location: 'National Highway 66, Bhatkal, KA',
    rating: 4.4,
  ),
  Hospital(
    id: 'lifecare',
    name: 'Lifecare Hospital',
    image: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&q=80&w=400',
    location: 'Main Road, Bhatkal, KA',
    rating: 4.6,
  ),
];

final List<Meal> STAT_MEALS = [
  // BREAKFAST (Exactly 4 Dishes)
  Meal(
    id: 'bf-doc-veg',
    name: "Steamed Vegetable Idli with Thin Sambhar",
    image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&q=80&w=600',
    price: 50.00,
    rating: 4.9,
    category: 'Breakfast',
    isVeg: true,
    isPopular: true,
    isHealthySpecial: true,
    isDoctorRecommended: true,
    clinicalTags: ["Post-Surgery Recovery", "Diabetes Management", "Hypertension & Cardiac Care"],
    clinicalDiagnosisSuggestion: "Prescribed to soothe digestion, regulate high blood sugar, or during cardiac bedrest. Steam-fermented, zero oil, and extremely gentle on the digestive tract.",
    description: 'Light & Easy on the Stomach—Perfect for resting. Fluffy, cloud-soft steamed idlis packed with carrots and green beans, served with a steaming, highly digestible thin sambhar.',
    ingredients: ['Steamed Rice Batter', 'Carrots', 'Beans', 'Thin Sambar', 'Mild Spices'],
    nutrition: Nutrition(calories: 180, protein: 7, carbs: 35, fat: 1, prepTimeMinutes: 12),
    reviews: [Review(id: 'r1', userName: 'Zainab Fatima', rating: 5, comment: 'Very light on the stomach, zero oil feel. Upma was hot when delivered to my bedside.', date: 'Today')],
  ),
  Meal(
    id: 'bf-doc-nonveg',
    name: "Shoupa Pana (Dill Leaves Crepe)",
    image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&q=80&w=600',
    price: 50.00,
    rating: 4.8,
    category: 'Breakfast',
    isVeg: true,
    isHealthySpecial: true,
    isDoctorRecommended: true,
    clinicalTags: ["Maternity & Lactation", "Digestive Healing", "Mild Acidity Care"],
    clinicalDiagnosisSuggestion: "Nourishing traditional herb-infused steamed cakes. Dill leaves promote maternal lactation and soothe stomach walls.",
    description: 'Vivid & Aromatic Herb Crepe—Gentle digestive comfort. A traditional herb-infused steamed rice crepe flavored with fresh medicinal dill leaves and a touch of light, soothing jaggery.',
    ingredients: ['Rice Flour', 'Dill Leaves', 'Light Jaggery', 'Grated Coconut'],
    nutrition: Nutrition(calories: 190, protein: 6, carbs: 36, fat: 2, prepTimeMinutes: 10),
    reviews: [],
  ),
  Meal(
    id: 'bf-norm-veg',
    name: "Oats Vegetable Upma",
    image: 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?auto=format&fit=crop&q=80&w=600',
    price: 50.00,
    rating: 4.6,
    category: 'Breakfast',
    isVeg: true,
    isDoctorRecommended: true,
    clinicalTags: ["High Fiber", "Diabetes Management", "Heart Healthy"],
    clinicalDiagnosisSuggestion: "Low-glycemic breakfast. Oats beta-glucans help regulate cholesterol and maintain blood glucose levels.",
    description: 'Light & Easy on the Stomach—Perfect for resting. High-fiber dry-roasted rolled oats cooked with carrots, peas, and a hint of lime. Keeps stomach light and comfortable.',
    ingredients: ['Rolled Oats', 'Green Peas', 'Carrots', 'Curry Leaves', 'Mustard Seeds'],
    nutrition: Nutrition(calories: 170, protein: 6, carbs: 29, fat: 2, prepTimeMinutes: 10),
    reviews: [],
  ),
  Meal(
    id: 'bf-norm-nonveg',
    name: "Dosa with Vegetable Kootu",
    image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&q=80&w=600',
    price: 50.00,
    rating: 4.7,
    category: 'Breakfast',
    isVeg: true,
    isDoctorRecommended: true,
    clinicalTags: ["Digestive Healing", "Mild Acidity Care", "Low Sodium"],
    clinicalDiagnosisSuggestion: "Thin oil-free fermented rice-and-lentil crepe served with a mild, water-based coconut-and-moong-dal vegetable Kootu.",
    description: 'Light & Easy on the Stomach—Perfect for resting. Golden, oil-free fermented rice crepe paired with a soothing, non-spicy vegetable stew that is exceptionally easy to digest.',
    ingredients: ['Fermented Rice Crepe', 'Ash Gourd Kootu', 'Ridge Gourd', 'Moong Dal', 'Mild Coconut Paste'],
    nutrition: Nutrition(calories: 210, protein: 5, carbs: 38, fat: 3, prepTimeMinutes: 12),
    reviews: [],
  ),

  // LUNCH (Exactly 2 Dishes - Veg and Non-Veg)
  Meal(
    id: 'lh-doc-veg',
    name: "The Healing Veg Thali (Mild & Nutritious)",
    image: 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?auto=format&fit=crop&q=80&w=400',
    price: 140.00,
    rating: 4.9,
    category: 'Lunch',
    isVeg: true,
    isPopular: true,
    isHealthySpecial: true,
    isDoctorRecommended: true,
    clinicalTags: ["Clinical Post-Surgery", "Cardiac & Renal Care", "Hypertension Protocol"],
    clinicalDiagnosisSuggestion: "Formulated for individuals on salt restrictions. Includes therapeutic gourds that support kidney and blood pressure workloads.",
    description: 'Controlled portion of unpolished red rice, water-based vegetable Kootu (ash gourd/ridge gourd) with moong dal, low-oil cabbage Poriyal with fresh coconut, and a glass of salt-free ginger buttermilk.',
    ingredients: ['Unpolished Red Rice', 'Ash Gourd Kootu', 'Cabbage Poriyal', 'Ginger Buttermilk (Saltless)', 'Moong Dal'],
    nutrition: Nutrition(calories: 380, protein: 12, carbs: 64, fat: 4, prepTimeMinutes: 15),
    reviews: [Review(id: 'r3', userName: 'Dr. Aditya Naik', rating: 5, comment: 'Extremely clean and simple. Recommended for post-surgery wards.', date: 'Yesterday')],
  ),
  Meal(
    id: 'lh-doc-nonveg',
    name: "The High-Protein Non-Veg/Caregiver Thali (Clean Energy)",
    image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=400',
    price: 195.00,
    rating: 4.8,
    category: 'Lunch',
    isVeg: false,
    isHealthySpecial: true,
    isDoctorRecommended: true,
    clinicalTags: ["High Energy For Caregivers", "Tissue Rebuilding", "Protein Recovery"],
    clinicalDiagnosisSuggestion: "High-protein, energy-rich meal for caregivers or recovery guests needing tissue building. Rich in lean amino acids.",
    description: 'Unpolished red rice, light coastal fish curry or lean chicken curry cooked with a diluted coconut milk and tamarind base, served with Heerekayi Upkari (ridge gourd stir-fry) or Ambat greens.',
    ingredients: ['Unpolished Red Rice', 'Coastal Fish Curry', 'Lean Chicken Breast', 'Ridge Gourd Upkari', 'Leafy Greens Ambat'],
    nutrition: Nutrition(calories: 520, protein: 34, carbs: 70, fat: 11, prepTimeMinutes: 20),
    reviews: [],
  ),

  // SOUP (Fresh, Hot Recovery Soups)
  Meal(
    id: 'sp-tomato',
    name: "Hot Clinical Tomato & Carrot Soup",
    image: 'https://images.unsplash.com/photo-1547592165-e1d17fed6005?auto=format&fit=crop&q=80&w=400',
    price: 39.00,
    rating: 4.7,
    category: 'Soup',
    isVeg: true,
    isPopular: true,
    description: 'A comforting blend of hand-picked tomatoes and sweet carrots simmered with wild garden herbs and a touch of roasted cumin. Low sodium and highly digestible.',
    ingredients: ['Tomatoes', 'Carrots', 'Garden Herbs', 'Cumin Seeds', 'Black Pepper'],
    nutrition: Nutrition(calories: 110, protein: 3, carbs: 22, fat: 1, prepTimeMinutes: 10),
    reviews: [],
  ),
  Meal(
    id: 'sp-chicken',
    name: "Medicinal Chicken Bone Broth",
    image: 'https://images.unsplash.com/photo-1607532941433-304659e8198a?auto=format&fit=crop&q=80&w=400',
    price: 42.00,
    rating: 4.9,
    category: 'Soup',
    isVeg: false,
    isHealthySpecial: true,
    description: 'Slow-simmered organic chicken bone marrow broth enriched with immunity-boosting turmeric, crushed ginger, and cracked black pepper. Excellent for recovery.',
    ingredients: ['Chicken Bone Stock', 'Ginger', 'Turmeric', 'Black Pepper', 'Fresh Parsley'],
    nutrition: Nutrition(calories: 140, protein: 12, carbs: 4, fat: 3, prepTimeMinutes: 15),
    reviews: [],
  ),
  Meal(
    id: 'sp-lentil',
    name: "Immunity Lentil Garlic Soup",
    image: 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&q=80&w=400',
    price: 35.00,
    rating: 4.6,
    category: 'Soup',
    isVeg: true,
    description: 'A nutritious clear split yellow lentil soup flavored with roasted garlic cloves, fresh spinach shreds, and lemon zest. Rich in natural iron.',
    ingredients: ['Yellow Moong Dal', 'Garlic', 'Baby Spinach', 'Lemon Juice', 'Turmeric'],
    nutrition: Nutrition(calories: 130, protein: 8, carbs: 20, fat: 2, prepTimeMinutes: 12),
    reviews: [],
  ),
  Meal(
    id: 'sp-mushroom',
    name: "Creamy Mushroom & Herb Potage",
    image: 'https://images.unsplash.com/photo-1547592165-e1d17fed6005?auto=format&fit=crop&q=80&w=400',
    price: 39.00,
    rating: 4.5,
    category: 'Soup',
    isVeg: true,
    description: 'Finely pureed fresh button mushrooms simmered with light almond milk, thyme, and cracked green peppercorns. Dairy-free and extremely light.',
    ingredients: ['Button Mushrooms', 'Almond Milk', 'Fresh Thyme', 'Green Peppercorn'],
    nutrition: Nutrition(calories: 125, protein: 4, carbs: 16, fat: 3, prepTimeMinutes: 12),
    reviews: [],
  ),

  // JUICE (Exactly 6 Fresh Juice Types)
  Meal(
    id: 'jc-orange',
    name: "Cold-Pressed Sweet Orange Booster",
    image: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?auto=format&fit=crop&q=80&w=400',
    price: 90.00,
    rating: 4.8,
    category: 'Juice',
    isVeg: true,
    isPopular: true,
    description: '100% natural, freshly squeezed Nagpur oranges with no added sugar, artificial sweeteners, or preservatives. Loaded with Vitamin C.',
    ingredients: ['Nagpur Oranges', 'Mint Leaf'],
    nutrition: Nutrition(calories: 95, protein: 1, carbs: 22, fat: 0, prepTimeMinutes: 5),
    reviews: [],
  ),
  Meal(
    id: 'jc-beetroot',
    name: "Detox Beetroot & Pomegranate Blend",
    image: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&q=80&w=400',
    price: 90.00,
    rating: 4.9,
    category: 'Juice',
    isVeg: true,
    description: 'A vibrant, deep red nectar of fresh organic beetroot, red apples, and sweet pomegranate seeds. Restores hemoglobin levels quickly.',
    ingredients: ['Beetroot', 'Pomegranate Seeds', 'Red Apple'],
    nutrition: Nutrition(calories: 110, protein: 2, carbs: 26, fat: 0, prepTimeMinutes: 6),
    reviews: [],
  ),
  Meal(
    id: 'jc-ginger',
    name: "Anti-Inflammatory Ginger & Turmeric Tonic",
    image: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&q=80&w=400',
    price: 90.00,
    rating: 4.7,
    category: 'Juice',
    isVeg: true,
    description: 'A cold-pressed wellness elixir of carrots, green apples, fresh ginger root, and organic turmeric. Powerfully fights cellular inflammation.',
    ingredients: ['Carrot', 'Green Apple', 'Fresh Ginger', 'Turmeric Root'],
    nutrition: Nutrition(calories: 70, protein: 1, carbs: 16, fat: 0, prepTimeMinutes: 5),
    reviews: [],
  ),
  Meal(
    id: 'jc-watermelon',
    name: "Fresh Watermelon & Mint Cooler",
    image: 'https://images.unsplash.com/photo-1543157148-f68f214fb391?auto=format&fit=crop&q=80&w=400',
    price: 90.00,
    rating: 4.6,
    category: 'Juice',
    isVeg: true,
    description: 'Hydrating watermelon nectar blended with freshly plucked garden mint leaves. Extremely refreshing for hospital ward summer days.',
    ingredients: ['Watermelon Chunks', 'Garden Mint'],
    nutrition: Nutrition(calories: 80, protein: 1, carbs: 18, fat: 0, prepTimeMinutes: 5),
    reviews: [],
  ),
  Meal(
    id: 'jc-coconut',
    name: "Pure Clinical Coconut Water",
    image: 'https://images.unsplash.com/photo-1608885898957-a599fb1b468b?auto=format&fit=crop&q=80&w=400',
    price: 60.00,
    rating: 4.9,
    category: 'Juice',
    isVeg: true,
    isPopular: true,
    description: 'Freshly tapped tender coastal coconut water packed with natural potassium, magnesium, and hydration electrolytes.',
    ingredients: ['Tender Coconut Water'],
    nutrition: Nutrition(calories: 45, protein: 0, carbs: 10, fat: 0, prepTimeMinutes: 4),
    reviews: [],
  ),
  Meal(
    id: 'jc-lime',
    name: "Digestive Sweet Lime Juice",
    image: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?auto=format&fit=crop&q=80&w=400',
    price: 90.00,
    rating: 4.7,
    category: 'Juice',
    isVeg: true,
    description: 'Freshly pressed sweet lime (Mosambi) juice with a pinch of digestive black salt. Stimulates appetite and settles nausea.',
    ingredients: ['Sweet Lime', 'Black Salt'],
    nutrition: Nutrition(calories: 85, protein: 1, carbs: 20, fat: 0, prepTimeMinutes: 5),
    reviews: [],
  ),

  // SNACKS (Healthy Recovery Snacks)
  Meal(
    id: 'sn-fruit-bowl',
    name: 'Immunity Fruit Bowl',
    image: 'https://images.unsplash.com/photo-1519996521430-02b798c1d881?auto=format&fit=crop&q=80&w=400',
    price: 90.00,
    rating: 4.7,
    category: 'Snacks',
    isVeg: true,
    isHealthySpecial: true,
    description: 'A vibrant selection of freshly sliced seasonal fruits packed with Vitamin C and fiber to boost recovery. Includes sweet papaya, pomegranate, crisp apple, banana, and a splash of lemon juice.',
    ingredients: ['Papaya', 'Apple', 'Pomegranate Seeds', 'Banana', 'Kiwi', 'Fresh Lemon'],
    nutrition: Nutrition(calories: 140, protein: 2, carbs: 33, fat: 0, prepTimeMinutes: 8),
    reviews: [],
  ),
  Meal(
    id: 'sn-sprouts',
    name: 'Sprouts & Paneer Salad',
    image: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&q=80&w=400',
    price: 85.00,
    rating: 4.5,
    category: 'Snacks',
    isVeg: true,
    description: 'A high-protein mid-day snack of steamed green gram (moong) sprouts, diced fresh cottage cheese (paneer), cucumber, and tomatoes, tossed with fresh coriander and lemon dressing.',
    ingredients: ['Moong Sprouts', 'Fresh Paneer', 'Cucumber', 'Tomatoes', 'Coriander', 'Lemon Juice', 'Black Pepper'],
    nutrition: Nutrition(calories: 190, protein: 14, carbs: 18, fat: 6, prepTimeMinutes: 10),
    reviews: [],
  ),
  Meal(
    id: 'sn-makhana',
    name: 'Roasted Low-Salt Organic Makhana',
    image: 'https://images.unsplash.com/photo-1600180758890-6b94519a8ba6?auto=format&fit=crop&q=80&w=400',
    price: 75.00,
    rating: 4.8,
    category: 'Snacks',
    isVeg: true,
    description: 'Crispy dry-roasted water lily seeds tossed with organic turmeric and a tiny pinch of rock salt. Extremely rich in calcium and low in sodium.',
    ingredients: ['Water Lily Seeds', 'Turmeric', 'Rock Salt', 'Olive Oil Touch'],
    nutrition: Nutrition(calories: 120, protein: 3, carbs: 24, fat: 1, prepTimeMinutes: 6),
    reviews: [],
  ),

  // Caregiver Survival Packs (3 bundled items)
  Meal(
    id: 'gr-overnight',
    name: 'The Overnight Survival Kit',
    image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&q=80&w=400',
    price: 299.00,
    rating: 4.9,
    category: 'Grocery',
    isVeg: true,
    description: 'The Overnight Kit: A 1L secure mineral water bottle, a pack of pH-balanced sanitizing wet wipes, a 1.5m long mobile charging cable, and a light nutritious digestive snack.',
    ingredients: ['1L Water Bottle', 'Hygienic Wet Wipes (30s)', '1.5m Charging Cable', 'High-Fiber Digestive Biscuits'],
    nutrition: Nutrition(calories: 140, protein: 2, carbs: 22, fat: 5, prepTimeMinutes: 0),
    reviews: [],
  ),
  Meal(
    id: 'gr-comfort',
    name: 'The Patient Comfort Pack',
    image: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&q=80&w=400',
    price: 399.00,
    rating: 4.8,
    category: 'Grocery',
    isVeg: true,
    description: 'Designed to block out ICU machine alerts, dim harsh fluorescent lights, and support peaceful rest. Includes a contoured blackout sleep eye mask, sound-dampening silicone earplugs, an inflatable cervical neck pillow, and a pocket notebook & pen.',
    ingredients: ['Blackout Sleep Mask', 'Silicone Earplugs', 'Inflatable Neck Pillow', 'Pocket Notebook', 'Ballpoint Pen'],
    nutrition: Nutrition(calories: 0, protein: 0, carbs: 0, fat: 0, prepTimeMinutes: 0),
    reviews: [],
  ),
  Meal(
    id: 'gr-hygiene',
    name: 'The Hygiene & Protection Bundle',
    image: 'https://images.unsplash.com/photo-1584622781564-1d987f7333c1?auto=format&fit=crop&q=80&w=400',
    price: 199.00,
    rating: 4.9,
    category: 'Grocery',
    isVeg: true,
    description: 'Complete bedside sanitization and personal hygiene shield. Includes a Dettol Hand Sanitizer (50ml), a pack of 10 surgical 3-ply masks, a Dove moisturizing soap bar, and a pack of double-ply facial tissues.',
    ingredients: ['Hand Sanitizer (50ml)', '3-Ply Surgical Masks (10s)', 'Dove Soap Bar', 'Soft Facial Tissues (100 Pcs)'],
    nutrition: Nutrition(calories: 0, protein: 0, carbs: 0, fat: 0, prepTimeMinutes: 0),
    reviews: [],
  ),

  Meal(
    id: 'gr-sanitizer',
    name: 'Dettol Hand Sanitizer (50ml)',
    image: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&q=80&w=400',
    price: 60.00,
    rating: 4.9,
    category: 'Grocery',
    isVeg: true,
    description: 'Alcohol-based instant hand sanitizer, kills 99.9% germs. Essential for clean bedside recovery and caregiver safety.',
    ingredients: [],
    nutrition: Nutrition(calories: 0, protein: 0, carbs: 0, fat: 0, prepTimeMinutes: 0),
    reviews: [],
  ),
  Meal(
    id: 'gr-wipes',
    name: 'Hygienic Wet Wipes (30 Pcs)',
    image: 'https://images.unsplash.com/photo-1563453392212-326f5e854473?auto=format&fit=crop&q=80&w=400',
    price: 90.00,
    rating: 4.8,
    category: 'Grocery',
    isVeg: true,
    description: 'Extra soft, pH-balanced sanitizing wet wipes for facial, hand, and bedside surface sterilization.',
    ingredients: [],
    nutrition: Nutrition(calories: 0, protein: 0, carbs: 0, fat: 0, prepTimeMinutes: 0),
    reviews: [],
  ),
  Meal(
    id: 'gr-tissues',
    name: 'Bedside Soft Facial Tissues (100 Pcs)',
    image: 'https://images.unsplash.com/photo-1607619056574-7b8f30413b58?auto=format&fit=crop&q=80&w=400',
    price: 75.00,
    rating: 4.7,
    category: 'Grocery',
    isVeg: true,
    description: 'Ultra-absorbent double ply bedside facial tissue paper.',
    ingredients: [],
    nutrition: Nutrition(calories: 0, protein: 0, carbs: 0, fat: 0, prepTimeMinutes: 0),
    reviews: [],
  ),
];

// =========================================================================
// JSON SERIALIZATION HELPERS
// =========================================================================

Map<String, dynamic> patientDetailsToJson(PatientDetails details) {
  return {
    'roomNumber': details.roomNumber,
    'ward': details.ward,
    'patientName': details.patientName,
    'notes': details.notes,
    'diagnosis': details.diagnosis,
  };
}

PatientDetails patientDetailsFromJson(Map<String, dynamic> json) {
  return PatientDetails(
    roomNumber: json['roomNumber'] ?? '',
    ward: json['ward'] ?? '',
    patientName: json['patientName'] ?? '',
    notes: json['notes'] ?? '',
    diagnosis: json['diagnosis'] ?? 'General Recovery',
  );
}

Map<String, dynamic> employeeDetailsToJson(EmployeeDetails details) {
  return {
    'employeeName': details.employeeName,
    'department': details.department,
    'employeeId': details.employeeId,
  };
}

EmployeeDetails employeeDetailsFromJson(Map<String, dynamic> json) {
  return EmployeeDetails(
    employeeName: json['employeeName'] ?? '',
    department: json['department'] ?? '',
    employeeId: json['employeeId'] ?? '',
  );
}

Map<String, dynamic> userProfileToJson(UserProfile profile) {
  return {
    'phone': profile.phone,
    'role': profile.role.index,
    'selectedHospitalId': profile.selectedHospitalId,
    'patientDetails': profile.patientDetails != null ? patientDetailsToJson(profile.patientDetails!) : null,
    'employeeDetails': profile.employeeDetails != null ? employeeDetailsToJson(profile.employeeDetails!) : null,
  };
}

UserProfile userProfileFromJson(Map<String, dynamic> json) {
  return UserProfile(
    phone: json['phone'] ?? '',
    role: json['role'] == 1 ? UserRole.Employee : UserRole.Patient,
    selectedHospitalId: json['selectedHospitalId'] ?? '',
    patientDetails: json['patientDetails'] != null ? patientDetailsFromJson(json['patientDetails']) : null,
    employeeDetails: json['employeeDetails'] != null ? employeeDetailsFromJson(json['employeeDetails']) : null,
  );
}

Map<String, dynamic> mealCustomizationToJson(MealCustomization c) {
  return {
    'extraRice': c.extraRice,
    'extraCurry': c.extraCurry,
    'saltPreference': c.saltPreference,
    'spicePreference': c.spicePreference,
    'noOnion': c.noOnion,
    'noGarlic': c.noGarlic,
    'extraSalad': c.extraSalad,
    'extraCurd': c.extraCurd,
    'specialInstructions': c.specialInstructions,
    'doubleSealedHeated': c.doubleSealedHeated,
    'clinicalApprovedOnly': c.clinicalApprovedOnly,
    'addonEggBanana': c.addonEggBanana,
  };
}

MealCustomization mealCustomizationFromJson(Map<String, dynamic> json) {
  return MealCustomization(
    extraRice: json['extraRice'] ?? false,
    extraCurry: json['extraCurry'] ?? false,
    saltPreference: json['saltPreference'] ?? 'Normal',
    spicePreference: json['spicePreference'] ?? 'Normal',
    noOnion: json['noOnion'] ?? false,
    noGarlic: json['noGarlic'] ?? false,
    extraSalad: json['extraSalad'] ?? false,
    extraCurd: json['extraCurd'] ?? false,
    specialInstructions: json['specialInstructions'] ?? '',
    doubleSealedHeated: json['doubleSealedHeated'] ?? false,
    clinicalApprovedOnly: json['clinicalApprovedOnly'] ?? false,
    addonEggBanana: json['addonEggBanana'] ?? false,
  );
}

Map<String, dynamic> cartItemToJson(CartItem item) {
  return {
    'id': item.id,
    'mealId': item.meal.id,
    'quantity': item.quantity,
    'customization': mealCustomizationToJson(item.customization),
  };
}

CartItem cartItemFromJson(Map<String, dynamic> json) {
  final mealId = json['mealId'] ?? '';
  final meal = STAT_MEALS.firstWhere((m) => m.id == mealId, orElse: () => STAT_MEALS[0]);
  return CartItem(
    id: json['id'] ?? '',
    meal: meal,
    quantity: json['quantity'] ?? 1,
    customization: mealCustomizationFromJson(json['customization'] ?? {}),
  );
}

Map<String, dynamic> activeOrderToJson(ActiveOrder order) {
  return {
    'id': order.id,
    'orderNumber': order.orderNumber,
    'items': order.items.map((i) => cartItemToJson(i)).toList(),
    'hospitalId': order.hospitalId,
    'hospitalName': order.hospitalName,
    'grandTotal': order.grandTotal,
    'status': order.status.index,
    'createdAt': order.createdAt.toIso8601String(),
  };
}

ActiveOrder activeOrderFromJson(Map<String, dynamic> json) {
  final itemsList = json['items'] as List? ?? [];
  return ActiveOrder(
    id: json['id'] ?? '',
    orderNumber: json['orderNumber'] ?? '',
    items: itemsList.map((i) => cartItemFromJson(i)).toList(),
    hospitalId: json['hospitalId'] ?? '',
    hospitalName: json['hospitalName'] ?? '',
    grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
    status: OrderStatus.values[json['status'] as int? ?? 0],
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}

Map<String, dynamic> appNotificationToJson(AppNotification notification) {
  return {
    'id': notification.id,
    'title': notification.title,
    'message': notification.message,
    'time': notification.time,
    'isRead': notification.isRead,
  };
}

AppNotification appNotificationFromJson(Map<String, dynamic> json) {
  return AppNotification(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    message: json['message'] ?? '',
    time: json['time'] ?? '',
    isRead: json['isRead'] ?? false,
  );
}
