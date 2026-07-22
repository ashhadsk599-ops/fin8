import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cura_meal/models/models.dart';

class AppState extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _onboardingCompleted = false;
  String _guestHospitalId = STAT_HOSPITALS[0].id;
  final List<CartItem> _cart = [];
  ActiveOrder? _activeOrder;
  final List<ActiveOrder> _pastOrders = [];
  final List<String> _favorites = [];
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      title: 'Welcome to Cura Meal!',
      message: 'Nourishing bedside delivery now active for hospitals in Bhatkal, KA.',
      time: 'Just now',
    )
  ];

  String _currentCoupon = '';
  double _couponDiscountPercentage = 0.0;
  Timer? _orderStatusTimer;
  String _simulatedTime = 'Real Time';
  String _selectedLanguage = 'English';
  String _userLiveLocation = 'Bhatkal, Karnataka';
  bool _isLoadingLocation = false;
  bool _notificationsEnabled = true;

  final List<ActiveOrder> _adminOrders = [];
  bool _adminOrdersInitialized = false;

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get onboardingCompleted => _onboardingCompleted;
  String get guestHospitalId => _guestHospitalId;
  List<CartItem> get cart => _cart;
  ActiveOrder? get activeOrder => _activeOrder;
  List<ActiveOrder> get pastOrders => _pastOrders;
  List<ActiveOrder> get adminOrders {
    _initializeAdminOrdersIfNeeded();
    return _adminOrders;
  }
  List<String> get favorites => _favorites;
  List<AppNotification> get notifications => _notifications;
  String get currentCoupon => _currentCoupon;
  String get simulatedTime => _simulatedTime;
  String get selectedLanguage => _selectedLanguage;
  String get userLiveLocation => _userLiveLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get notificationsEnabled => _notificationsEnabled;

  void _initializeAdminOrdersIfNeeded() {
    if (!_adminOrdersInitialized) {
      _adminOrdersInitialized = true;
      _adminOrders.addAll([
        ActiveOrder(
          id: 'admin-1',
          orderNumber: 'HP-9843',
          items: [
            CartItem(
              id: 'item-1',
              meal: STAT_MEALS[0], // Steamed Idli & Sambar
              quantity: 1,
              customization: MealCustomization(
                saltPreference: 'Low Sodium',
                spicePreference: 'Mild',
                doubleSealedHeated: true,
                clinicalApprovedOnly: true,
              ),
            ),
          ],
          hospitalId: 'bgh',
          hospitalName: 'Bhatkal Government Hospital',
          grandTotal: 105.0,
          status: OrderStatus.Received,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          patientName: 'Karan Kumar',
          patientRoom: 'Room 102',
          patientWard: 'Maternity Ward',
          patientDiagnosis: 'Post-Surgery Recovery',
        ),
        ActiveOrder(
          id: 'admin-2',
          orderNumber: 'HP-1254',
          items: [
            CartItem(
              id: 'item-2',
              meal: STAT_MEALS[4], // Moong Dal Khichdi
              quantity: 2,
              customization: MealCustomization(
                saltPreference: 'No Salt',
                spicePreference: 'No Spice',
                doubleSealedHeated: true,
                clinicalApprovedOnly: true,
              ),
            ),
          ],
          hospitalId: 'bgh',
          hospitalName: 'Bhatkal Government Hospital',
          grandTotal: 260.0,
          status: OrderStatus.Preparing,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          patientName: 'Mariyam Bi',
          patientRoom: 'Room 304',
          patientWard: 'ICU Sector B',
          patientDiagnosis: 'Gastroenteritis',
        ),
      ]);
    }
  }

  void updateAdminOrderStatus(String id, OrderStatus newStatus) {
    final index = _adminOrders.indexWhere((o) => o.id == id);
    if (index != -1) {
      final order = _adminOrders[index];
      order.status = newStatus;
      
      // If this is also the user's active order, update its status too!
      if (_activeOrder != null && _activeOrder!.id == id) {
        _activeOrder!.status = newStatus;
        
        // Add clinical status notifications for the guest user
        if (newStatus == OrderStatus.Preparing) {
          _addNotification(
            'Kitchen Cooking 🧑‍🍳',
            'Your meal for Order ${order.orderNumber} is being prepared with customized salt/spice settings.',
          );
        } else if (newStatus == OrderStatus.OutForDelivery) {
          _addNotification(
            'Out for Bedside Delivery 🚴',
            'Ward delivery executive is ascending to your floor with the double-sealed thermal container.',
          );
        } else if (newStatus == OrderStatus.Delivered) {
          _addNotification(
            'Meal Arrived! 🎉',
            'Order ${order.orderNumber} successfully checked and handed over to bed space.',
          );
          _pastOrders.insert(0, _activeOrder!);
          _activeOrder = null;
        }
      }
      
      _saveToPrefs();
      notifyListeners();
    }
  }

  void setNotificationsEnabled(bool val) {
    _notificationsEnabled = val;
    _saveToPrefs();
    notifyListeners();
    if (val) {
      _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    try {
      await _localNotifications.initialize(
        initializationSettings,
      );
      if (_notificationsEnabled) {
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }
  }

  Future<void> showSystemNotification(String title, String body) async {
    if (!_notificationsEnabled) return;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'cura_meal_channel',
      'Meal Status Updates',
      channelDescription: 'Real-time updates about your clinical meal preparation and delivery',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      vibrationPattern: Int64List.fromList([0, 200, 100, 200]),
    );
    final DarwinNotificationDetails darwinPlatformChannelSpecifics =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );
    
    try {
      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Error showing native notification: $e');
    }
  }

  Future<void> fetchLiveLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _userLiveLocation = 'Location services disabled';
        _isLoadingLocation = false;
        _saveToPrefs();
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _userLiveLocation = 'Location permission denied';
          _isLoadingLocation = false;
          _saveToPrefs();
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _userLiveLocation = 'Permission denied permanently';
        _isLoadingLocation = false;
        _saveToPrefs();
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      final lat = position.latitude;
      final lon = position.longitude;

      try {
        final client = HttpClient();
        final request = await client.getUrl(
          Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon'),
        );
        request.headers.set('User-Agent', 'CuraMealFlutterApp');
        request.headers.set('Accept-Language', 'en');
        final response = await request.close().timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          final data = jsonDecode(body);
          final address = data['display_name'] as String? ?? '';
          if (address.isNotEmpty) {
            final parts = address.split(', ');
            final shortAddress = parts.take(3).join(', ');
            _userLiveLocation = shortAddress;
          } else {
            _userLiveLocation = 'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}';
          }
        } else {
          _userLiveLocation = 'Bhatkal Area (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})';
        }
        client.close();
      } catch (e) {
        _userLiveLocation = 'Bhatkal Area (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})';
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
      _userLiveLocation = 'Bhatkal, Karnataka';
    } finally {
      _isLoadingLocation = false;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void setSelectedLanguage(String lang) {
    _selectedLanguage = lang;
    _saveToPrefs();
    notifyListeners();
  }

  void setSimulatedTime(String val) {
    _simulatedTime = val;
    notifyListeners();
  }

  String translate(String text) {
    if (_selectedLanguage == 'English') return text;
    final map = _translations[text];
    if (map != null && map.containsKey(_selectedLanguage)) {
      return map[_selectedLanguage]!;
    }
    return text;
  }

  static const Map<String, Map<String, String>> _translations = {
    'Cura Meal': {
      'Kannada': 'ಕ್ಯೂರಾ ಬೈಟ್',
      'Urdu': 'کیورا بائٹ',
    },
    'Instant Search': {
      'Kannada': 'ತ್ವರಿತ ಹುಡುಕಾಟ',
      'Urdu': 'فوری تلاش',
    },
    'Search': {
      'Kannada': 'ಹುಡುಕಾಟ',
      'Urdu': 'تلاش',
    },
    'Recovery Progress & History': {
      'Kannada': 'ಚೇತರಿಕೆ ಪ್ರಗತಿ ಮತ್ತು ಇತಿಹಾಸ',
      'Urdu': 'صحت یابی کی ترقی اور تاریخچہ',
    },
    'Orders': {
      'Kannada': 'ಆರ್ಡರ್‌ಗಳು',
      'Urdu': 'آرڈرز',
    },
    'My Favorites': {
      'Kannada': 'ನನ್ನ ನೆಚ್ಚಿನವುಗಳು',
      'Urdu': 'میری پسندیدہ',
    },
    'Favorites': {
      'Kannada': 'ನೆಚ್ಚಿನವುಗಳು',
      'Urdu': 'پسندیدہ',
    },
    'Preferences': {
      'Kannada': 'ಆದ್ಯತೆಗಳು',
      'Urdu': 'ترجیحات',
    },
    'Preferences Configuration': {
      'Kannada': 'ಆದ್ಯತೆಗಳ ಸಂರಚನೆ',
      'Urdu': 'ترجیحات کی ترتیب',
    },
    'Settings': {
      'Kannada': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'Urdu': 'ترتیبات',
    },
    'Good Morning ☀️': {
      'Kannada': 'ಶುಭೋದಯ ☀️',
      'Urdu': 'صبح بخیر ☀️',
    },
    'Good Afternoon 🌤️': {
      'Kannada': 'ಶುಭ ಮಧ್ಯಾಹ್ನ 🌤️',
      'Urdu': 'سہ پہر بخیر 🌤️',
    },
    'Good Evening 🌙': {
      'Kannada': 'ಶುಭ ಸಂಜೆ 🌙',
      'Urdu': 'شام بخیر 🌙',
    },
    'What clean nutrition do you need today?': {
      'Kannada': 'ಇಂದು ನಿಮಗೆ ಯಾವ ಶುದ್ಧ ಪೌಷ್ಟಿಕಾಂಶದ ಅಗತ್ಯವಿದೆ?',
      'Urdu': 'آج آپ کو کون سی صاف ستھری غذا چاہیے؟',
    },
    'Bhatkal healthcare units support English, local Kannada, and Urdu diets.': {
      'Kannada': 'ಭಟ್ಕಳ ಆರೋಗ್ಯ ಕೇಂದ್ರಗಳು ಇಂಗ್ಲಿಷ್, ಸ್ಥಳೀಯ ಕನ್ನಡ ಮತ್ತು ಉರ್ದು ಆಹಾರಗಳನ್ನು ಬೆಂಬಲಿಸುತ್ತವೆ.',
      'Urdu': 'بھٹکل ہیلتھ کیئر یونٹس انگریزی، مقامی کنڑ، اور اردو غذاؤں کو سپورٹ کرتے ہیں۔',
    },
    'CLINICAL QUICK FILTERS': {
      'Kannada': 'ಕ್ಲಿನಿಕಲ್ ಕ್ವಿಕ್ ಫಿಲ್ಟರ್‌ಗಳು',
      'Urdu': 'طبی فوری فلٹرز',
    },
    'All': {
      'Kannada': 'ಎಲ್ಲಾ',
      'Urdu': 'تمام',
    },
    'Veg Only': {
      'Kannada': 'ಸಸ್ಯಾಹಾರ ಮಾತ್ರ',
      'Urdu': 'صرف سبزی',
    },
    'Non-Veg': {
      'Kannada': 'ಮಾಂಸಾಹಾರ',
      'Urdu': 'گوشت خور',
    },
    'High Protein (12g+)': {
      'Kannada': 'ಹೆಚ್ಚಿನ ಪ್ರೋಟೀನ್ (12g+)',
      'Urdu': 'زیادہ پروٹین (12g+)',
    },
    'Low Calorie (≤220 kcal)': {
      'Kannada': 'ಕಡಿಮೆ ಕ್ಯಾಲೊರಿ (≤220 kcal)',
      'Urdu': 'کم کیلوری (≤220 kcal)',
    },
    'No Saved Favorites': {
      'Kannada': 'ಯಾವುದೇ ನೆಚ್ಚಿನವುಗಳಿಲ್ಲ',
      'Urdu': 'کوئی پسندیدہ محفوظ نہیں',
    },
    'Tap the heart icon on any meal card to build a custom shortlist of your favorite recovery foods.': {
      'Kannada': 'ನಿಮ್ಮ ನೆಚ್ಚಿನ ಆಹಾರಗಳ ಪಟ್ಟಿಯನ್ನು ನಿರ್ಮಿಸಲು ಯಾವುದೇ ಆಹಾರ ಕಾರ್ಡ್‌ನಲ್ಲಿರುವ ಹಾರ್ಟ್ ಐಕಾನ್ ಟ್ಯಾಪ್ ಮಾಡಿ.',
      'Urdu': 'اپنی پسندیدہ غذاؤں کی فہرست بنانے کے لیے کسی بھی کارڈ پر دل کے نشان کو دبائیں۔',
    },
    'Push Notifications': {
      'Kannada': 'ಪುಶ್ ನೋಟಿಫಿಕೇಶನ್‌ಗಳು',
      'Urdu': 'پش نوٹیفیکیشنز',
    },
    'Admitted status alarms: Pings when sterile container leaves kitchen.': {
      'Kannada': 'ದಾಖಲಾತಿ ಸ್ಥಿತಿ ಅಲಾರಂಗಳು: ಅಡುಗೆಮನೆಯಿಂದ ಆಹಾರ ಹೊರಟಾಗ ತಿಳಿಸುತ್ತದೆ.',
      'Urdu': 'داخل مریض کی حیثیت کے الارم: جب کھانا باورچی خانے سے روانہ ہوتا ہے تو اطلاع ملتی ہے۔',
    },
    'Language Settings': {
      'Kannada': 'ಭಾಷಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'Urdu': 'زبان کی ترتیبات',
    },
    'Compliance & Health Info': {
      'Kannada': 'ಅನುಸರಣೆ ಮತ್ತು ಆರೋಗ್ಯ ಮಾಹಿತಿ',
      'Urdu': 'تعمیل اور صحت کی معلومات',
    },
    'Sterilized Kitchen Security': {
      'Kannada': 'ಕ್ರಿಮಿನಾಶಕ ಅಡುಗೆಮನೆ ಭದ್ರತೆ',
      'Urdu': 'جراثیم سے پاک باورچی خانے کی حفاظت',
    },
    'Guest Terms & Privacy': {
      'Kannada': 'ಅತಿಥಿ ನಿಯಮಗಳು ಮತ್ತು ಗೌಪ್ಯತೆ',
      'Urdu': 'مہمان کی شرائط اور رازداری',
    },
    'Dial Bedside Emergency Help': {
      'Kannada': 'ಬೆಡ್‌ಸೈಡ್ ತುರ್ತು ಸಹಾಯಕ್ಕೆ ಕರೆ ಮಾಡಿ',
      'Urdu': 'بیڈ سائیಡ್ ہنگامی مدد',
    },
    'Hospital Admin Portal': {
      'Kannada': 'ಆಸ್ಪತ್ರೆ ಆಡಳಿತ ಪೋರ್ಟಲ್',
      'Urdu': 'ہسپتال ایڈمن پورٹل',
    },
    'Accept bedside orders, monitor diet coordinates & track preparation.': {
      'Kannada': 'ಬೆಡ್‌ಸೈಡ್ ಆರ್ಡರ್‌ಗಳನ್ನು ಸ್ವೀಕರಿಸಿ, ಆಹಾರ ನಿರ್ದೇಶಾಂಕಗಳನ್ನು ವೀಕ್ಷಿಸಿ.',
      'Urdu': 'بیڈ سائیڈ آرڈرز قبول کریں اور تیاری دیکھیں۔',
    },
    'Cura Meal operates in high-efficiency hospital zones. Delivery staff undergo double temperature checks.': {
      'Kannada': 'ಕ್ಯೂರಾ ಬೈಟ್ ಉನ್ನತ ಮಟ್ಟದ ಆಸ್ಪತ್ರೆ ವಲಯಗಳಲ್ಲಿ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತದೆ.',
      'Urdu': 'کیورا بائٹ اعلٰی معیار کے ہسپتال زونز میں کام کرتا ہے۔',
    },
    'Your nutrition tray is empty.': {
      'Kannada': 'ನಿಮ್ಮ ಆಹಾರದ ಟ್ರೇ ಖಾಲಿಯಾಗಿದೆ.',
      'Urdu': 'آپ کی غذائی ٹرے خالی ہے۔',
    },
    'Browse NutriMenu to add healthy items.': {
      'Kannada': 'ಆರೋಗ್ಯಕರ ಆಹಾರಗಳನ್ನು ಸೇರಿಸಲು ನ್ಯೂಟ್ರಿಮೆನೂ ಬ್ರೌಸ್ ಮಾಡಿ.',
      'Urdu': 'صحت بخش اشیاء شامل کرنے کے لیے نیوٹری مینو دیکھیں۔',
    },
    'Applied Coupon Savings': {
      'Kannada': 'ಅನ್ವಯಿಸಲಾದ ಕೂಪನ್ ಉಳಿತಾಯ',
      'Urdu': 'لاگو کردہ کوپن کی بچت',
    },
    'Grand Total': {
      'Kannada': 'ಒಟ್ಟು ಮೊತ್ತ',
      'Urdu': 'کل رقم',
    },
    'Confirm & Dispatch Bedside Delivery': {
      'Kannada': 'ಖಚಿತಪಡಿಸಿ ಮತ್ತು ಬೆಡ್‌ಸೈಡ್ ವಿತರಣೆಗೆ ಕಳುಹಿಸಿ',
      'Urdu': 'بیڈ سائیڈ ڈیلیوری کی تصدیق اور روانگی',
    },
  };

  // Shared Preferences Save/Load
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', _onboardingCompleted);
      await prefs.setString('selected_language', _selectedLanguage);
      await prefs.setString('guest_hospital_id', _guestHospitalId);
      await prefs.setStringList('favorites', _favorites);
      
      if (_currentUser != null) {
        final profileJson = jsonEncode(userProfileToJson(_currentUser!));
        await prefs.setString('current_user', profileJson);
      } else {
        await prefs.remove('current_user');
      }
      
      final cartJson = jsonEncode(_cart.map((i) => cartItemToJson(i)).toList());
      await prefs.setString('cart_items', cartJson);
      
      if (_activeOrder != null) {
        final activeOrderJson = jsonEncode(activeOrderToJson(_activeOrder!));
        await prefs.setString('active_order', activeOrderJson);
      } else {
        await prefs.remove('active_order');
      }
      
      final pastOrdersJson = jsonEncode(_pastOrders.map((o) => activeOrderToJson(o)).toList());
      await prefs.setString('past_orders', pastOrdersJson);
      
      final notificationsJson = jsonEncode(_notifications.map((n) => appNotificationToJson(n)).toList());
      await prefs.setString('notifications', notificationsJson);
      await prefs.setString('user_live_location', _userLiveLocation);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
      _guestHospitalId = prefs.getString('guest_hospital_id') ?? STAT_HOSPITALS[0].id;
      
      final favList = prefs.getStringList('favorites');
      if (favList != null) {
        _favorites.clear();
        _favorites.addAll(favList);
      }
      
      final userStr = prefs.getString('current_user');
      if (userStr != null) {
        final decoded = jsonDecode(userStr);
        _currentUser = userProfileFromJson(decoded);
      }
      
      final cartStr = prefs.getString('cart_items');
      if (cartStr != null) {
        final List decoded = jsonDecode(cartStr);
        _cart.clear();
        _cart.addAll(decoded.map((i) => cartItemFromJson(i)).toList());
      }
      
      final activeOrderStr = prefs.getString('active_order');
      if (activeOrderStr != null) {
        final decoded = jsonDecode(activeOrderStr);
        _activeOrder = activeOrderFromJson(decoded);
        if (_activeOrder != null && _activeOrder!.status != OrderStatus.Delivered) {
          // Automatic timeline simulation is disabled. Updates are manual.
        }
      }
      
      final pastOrdersStr = prefs.getString('past_orders');
      if (pastOrdersStr != null) {
        final List decoded = jsonDecode(pastOrdersStr);
        _pastOrders.clear();
        _pastOrders.addAll(decoded.map((o) => activeOrderFromJson(o)).toList());
      }
      
      final notificationsStr = prefs.getString('notifications');
      if (notificationsStr != null) {
        final List decoded = jsonDecode(notificationsStr);
        _notifications.clear();
        _notifications.addAll(decoded.map((n) => appNotificationFromJson(n)).toList());
      }

      _userLiveLocation = prefs.getString('user_live_location') ?? 'Bhatkal, Karnataka';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      await initializeNotifications();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Hospital? get selectedHospital {
    if (_currentUser == null) {
      return STAT_HOSPITALS.firstWhere(
        (h) => h.id == _guestHospitalId,
        orElse: () => STAT_HOSPITALS[0],
      );
    }
    return STAT_HOSPITALS.firstWhere(
      (h) => h.id == _currentUser!.selectedHospitalId,
      orElse: () => STAT_HOSPITALS[0],
    );
  }

  void completeOnboarding() {
    _onboardingCompleted = true;
    _saveToPrefs();
    notifyListeners();
  }

  void updateGuestHospital(String id) {
    _guestHospitalId = id;
    _saveToPrefs();
    notifyListeners();
  }

  // Profile actions
  void loginUser(UserProfile profile) {
    _currentUser = profile;
    _currentCoupon = '';
    _couponDiscountPercentage = 0.0;
    _addNotification(
      'Admission Registered',
      'You check-in at ${selectedHospital?.name ?? "hospital"} is complete. Bedside deliveries are linked to your ward details.',
    );
    if (_cart.isNotEmpty) {
      _addNotification(
        'Order Placed & On Its Way! 🚴',
        'Your bedside clinical diet order is placed and on its way! Check your active timeline to track it live. You have exclusive offers waiting under settings!',
      );
      checkoutOrder();
    }
    _saveToPrefs();
    notifyListeners();
  }

  void sendCarePack({
    required String lovedOneName,
    required String hospitalId,
    required String ward,
    required String roomNumber,
  }) {
    final guestProfile = UserProfile(
      phone: 'Guest',
      role: UserRole.Patient,
      selectedHospitalId: hospitalId,
      patientDetails: PatientDetails(
        patientName: lovedOneName,
        ward: ward,
        roomNumber: roomNumber,
        notes: 'Overnight Care Pack Order',
      ),
    );
    _currentUser = guestProfile;
    _guestHospitalId = hospitalId;
    _currentCoupon = '';
    _couponDiscountPercentage = 0.0;

    _addNotification(
      'Care Pack Enabled! 🎁',
      'Pre-ordering for $lovedOneName at ${selectedHospital?.name ?? "Hospital"}, Ward $ward.',
    );

    _saveToPrefs();
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _onboardingCompleted = false;
    _cart.clear();
    _activeOrder = null;
    _pastOrders.clear();
    _favorites.clear();
    _currentCoupon = '';
    _couponDiscountPercentage = 0.0;
    _orderStatusTimer?.cancel();
    _saveToPrefs();
    notifyListeners();
  }

  // Cart actions
  void addToCart(Meal meal, MealCustomization customization, int quantity) {
    final specId = '${meal.id}-${customization.saltPreference}-${customization.spicePreference}-'
        '${customization.extraRice ? "er" : ""}-${customization.extraCurry ? "ec" : ""}-'
        '${customization.doubleSealedHeated ? "ds" : ""}-${customization.clinicalApprovedOnly ? "ca" : ""}-'
        '${customization.addonEggBanana ? "eb" : ""}';

    final existingIndex = _cart.indexWhere((item) => item.id == specId);
    if (existingIndex >= 0) {
      _cart[existingIndex].quantity += quantity;
    } else {
      _cart.add(CartItem(
        id: specId,
        meal: meal,
        quantity: quantity,
        customization: customization.copy(),
      ));
    }
    _saveToPrefs();
    notifyListeners();
  }

  void updateCartItemQuantity(String id, int quantity) {
    final index = _cart.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = quantity;
      }
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeFromCart(String id) {
    _cart.removeWhere((item) => item.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _currentCoupon = '';
    _couponDiscountPercentage = 0.0;
    _saveToPrefs();
    notifyListeners();
  }

  // Favorites
  void toggleFavorite(String mealId) {
    if (_favorites.contains(mealId)) {
      _favorites.remove(mealId);
    } else {
      _favorites.add(mealId);
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Coupon
  bool applyCoupon(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized == 'HEAL100') {
      _currentCoupon = 'HEAL100';
      _couponDiscountPercentage = 20.0;
      _saveToPrefs();
      notifyListeners();
      return true;
    } else if (normalized == 'RECOVER50') {
      _currentCoupon = 'RECOVER50';
      _couponDiscountPercentage = 15.0;
      _saveToPrefs();
      notifyListeners();
      return true;
    } else if (normalized == 'NUTRIFIT') {
      _currentCoupon = 'NUTRIFIT';
      _couponDiscountPercentage = 10.0;
      _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _currentCoupon = '';
    _couponDiscountPercentage = 0.0;
    _saveToPrefs();
    notifyListeners();
  }

  // Billing Math
  Map<String, dynamic> getClinicalScheduleInfo(String category) {
    int hour = 9;
    int minute = 0;

    if (_simulatedTime == 'Real Time') {
      final now = DateTime.now();
      hour = now.hour;
      minute = now.minute;
    } else {
      final parts = _simulatedTime.split(':');
      if (parts.length == 2) {
        hour = int.tryParse(parts[0]) ?? 9;
        minute = int.tryParse(parts[1]) ?? 0;
      }
    }

    final totalMinutes = hour * 60 + minute;

    if (category == 'Breakfast') {
      final bool isAvailable = totalMinutes >= 300 && totalMinutes < 570;
      double discountPercentage = 0;
      String discountLabel = '';

      if (isAvailable) {
        if (totalMinutes < 480) {
          discountPercentage = 20.0;
          discountLabel = 'Breakfast Early Bird (20% Off)';
        } else if (totalMinutes < 510) {
          discountPercentage = 10.0;
          discountLabel = 'Breakfast Saver (10% Off)';
        }
      }

      return {
        'isAvailable': isAvailable,
        'discountPercentage': discountPercentage,
        'discountLabel': discountLabel,
      };
    } else if (category == 'Lunch') {
      final bool isAvailable = totalMinutes >= 660 && totalMinutes < 840;
      double discountPercentage = 0;
      String discountLabel = '';

      if (isAvailable) {
        if (totalMinutes < 750) {
          discountPercentage = 15.0;
          discountLabel = 'Lunch Early Bird (15% Off)';
        } else if (totalMinutes < 780) {
          discountPercentage = 8.0;
          discountLabel = 'Lunch Saver (8% Off)';
        }
      }

      return {
        'isAvailable': isAvailable,
        'discountPercentage': discountPercentage,
        'discountLabel': discountLabel,
      };
    }

    return {
      'isAvailable': true,
      'discountPercentage': 0.0,
      'discountLabel': '',
    };
  }

  double get cartSubtotal {
    double total = 0;
    for (var item in _cart) {
      double itemPrice = item.meal.price;
      if (item.customization.addonEggBanana) {
        itemPrice += 20.0;
      }
      if (item.customization.extraCurd) {
        itemPrice += 15.0;
      }
      if (item.customization.extraRice) {
        itemPrice += 25.0;
      }
      if (item.customization.extraCurry) {
        itemPrice += 30.0;
      }
      if (item.customization.extraSalad) {
        itemPrice += 15.0;
      }
      total += itemPrice * item.quantity;
    }
    return total;
  }

  double get scheduleDiscountAmount {
    double total = 0.0;
    for (var item in _cart) {
      final info = getClinicalScheduleInfo(item.meal.category);
      if (info['isAvailable'] == true && (info['discountPercentage'] as double) > 0) {
        total += (item.meal.price * item.quantity * (info['discountPercentage'] as double)) / 100;
      }
    }
    return total.roundToDouble();
  }

  double get couponDiscountAmount {
    return cartSubtotal * (_couponDiscountPercentage / 100);
  }

  double get gstCharge {
    return cartSubtotal * 0.05;
  }

  double get deliveryCharge {
    if (cartSubtotal == 0) return 0.0;
    return 20.00;
  }

  double get cartGrandTotal {
    double total = cartSubtotal - couponDiscountAmount - scheduleDiscountAmount + gstCharge + deliveryCharge;
    return total < 0 ? 0.0 : total;
  }

  void checkoutOrder() {
    if (_cart.isEmpty || _currentUser == null) return;

    final orderNum = 'HP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final newOrder = ActiveOrder(
      id: DateTime.now().toIso8601String(),
      orderNumber: orderNum,
      items: List.from(_cart),
      hospitalId: _currentUser!.selectedHospitalId,
      hospitalName: selectedHospital?.name ?? 'Bhatkal Hospital',
      grandTotal: cartGrandTotal,
      status: OrderStatus.Received,
      createdAt: DateTime.now(),
      patientName: _currentUser?.role == UserRole.Patient
          ? _currentUser?.patientDetails?.patientName
          : _currentUser?.employeeDetails?.employeeName ?? 'Admitted Guest',
      patientRoom: _currentUser?.patientDetails?.roomNumber ?? 'G-10',
      patientWard: _currentUser?.patientDetails?.ward ?? 'General',
      patientDiagnosis: _currentUser?.patientDetails?.diagnosis ?? 'General Recovery',
    );

    _activeOrder = newOrder;
    _initializeAdminOrdersIfNeeded();
    _adminOrders.insert(0, newOrder);
    _cart.clear();
    _currentCoupon = '';
    _couponDiscountPercentage = 0.0;

    _addNotification(
      'Order Placed! 🧾',
      'Order $orderNum received. Bedside delivery preparation started with clinical directives.',
    );

    _saveToPrefs();
    notifyListeners();

    // Start automated timeline status updates & notifications (Disabled - only manual admin updates allowed)
    // _startTimelineSimulation();
  }

  void _startTimelineSimulation() {
    _orderStatusTimer?.cancel();

    _orderStatusTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (_activeOrder == null) {
        timer.cancel();
        return;
      }

      switch (_activeOrder!.status) {
        case OrderStatus.Received:
          _activeOrder!.status = OrderStatus.Preparing;
          _addNotification(
            'Kitchen Cooking 🧑‍🍳',
            'Your meal for Order ${_activeOrder!.orderNumber} is being prepared with customized salt/spice settings.',
          );
          break;
        case OrderStatus.Preparing:
          _activeOrder!.status = OrderStatus.OutForDelivery;
          _addNotification(
            'Out for Bedside Delivery 🚴',
            'Ward delivery executive is ascending to your floor with the double-sealed thermal container.',
          );
          break;
        case OrderStatus.OutForDelivery:
          _activeOrder!.status = OrderStatus.Delivered;
          _addNotification(
            'Meal Arrived! 🎉',
            'Order ${_activeOrder!.orderNumber} successfully checked and handed over to bed space.',
          );
          _pastOrders.insert(0, _activeOrder!);
          _activeOrder = null;
          timer.cancel();
          break;
        case OrderStatus.Delivered:
          timer.cancel();
          break;
      }
      _saveToPrefs();
      notifyListeners();
    });
  }

  void _addNotification(String title, String msg) {
    _notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().toIso8601String(),
        title: title,
        message: msg,
        time: 'Just now',
      ),
    );
    _saveToPrefs();
    showSystemNotification(title, msg);
  }

  void markNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _saveToPrefs();
    notifyListeners();
  }

  void simulateTimelineTick() {
    if (_activeOrder == null) return;
    switch (_activeOrder!.status) {
      case OrderStatus.Received:
        _activeOrder!.status = OrderStatus.Preparing;
        _addNotification(
          'Kitchen Cooking 🧑‍🍳',
          'Your meal for Order ${_activeOrder!.orderNumber} is being prepared with customized salt/spice settings.',
        );
        break;
      case OrderStatus.Preparing:
        _activeOrder!.status = OrderStatus.OutForDelivery;
        _addNotification(
          'Out for Bedside Delivery 🚴',
          'Ward delivery executive is ascending to your floor with the double-sealed thermal container.',
        );
        break;
      case OrderStatus.OutForDelivery:
        _activeOrder!.status = OrderStatus.Delivered;
        _addNotification(
          'Meal Arrived! 🎉',
          'Order ${_activeOrder!.orderNumber} successfully checked and handed over to bed space.',
        );
        _pastOrders.insert(0, _activeOrder!);
        _activeOrder = null;
        _orderStatusTimer?.cancel();
        break;
      case OrderStatus.Delivered:
        break;
    }
    _saveToPrefs();
    notifyListeners();
  }

  void clearOrderHistory() {
    _adminOrders.clear();
    _pastOrders.clear();
    _activeOrder = null;
    _orderStatusTimer?.cancel();
    _saveToPrefs();
    notifyListeners();
  }

  @override
  void dispose() {
    _orderStatusTimer?.cancel();
    super.dispose();
  }
}
