import React, { createContext, useContext, useState, useEffect } from 'react';
import { 
  Hospital, Meal, User, UserRole, PatientDetails, EmployeeDetails, 
  CartItem, Offer, Order, OrderStatus, MealCustomization, Notification as AppNotification
} from '../types';
import { HOSPITALS, MEALS, OFFERS } from '../data';
import { db } from '../firebase';
import { collection, doc, setDoc, updateDoc, onSnapshot } from 'firebase/firestore';

export type ScreenType = 
  | 'splash' 
  | 'onboarding' 
  | 'login' 
  | 'select-hospital' 
  | 'patient-flow' 
  | 'employee-flow' 
  | 'home' 
  | 'meal-detail' 
  | 'customization' 
  | 'cart' 
  | 'checkout' 
  | 'success' 
  | 'tracking' 
  | 'profile' 
  | 'settings' 
  | 'search' 
  | 'favorites' 
  | 'offers'
  | 'more'
  | 'care-pack'
  | 'admin';

const sendSystemNotification = (title: string, body: string) => {
  if (typeof window === 'undefined' || !('Notification' in window)) return;
  if (Notification.permission === 'granted') {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.ready.then((registration) => {
        registration.showNotification(title, {
          body,
          icon: '/logo.png',
          badge: '/logo.png',
          vibrate: [200, 100, 200],
        } as any);
      }).catch((err) => {
        console.warn('SW registration not ready for notification:', err);
        try {
          new Notification(title, { body, icon: '/logo.png' });
        } catch (e) {
          console.error('Failed to create new Notification:', e);
        }
      });
    } else {
      try {
        new Notification(title, { body, icon: '/logo.png' });
      } catch (e) {
        console.error('Failed to create new Notification:', e);
      }
    }
  }
};

interface AppContextType {
  // Navigation
  screen: ScreenType;
  setScreen: (screen: ScreenType) => void;
  screenHistory: ScreenType[];
  navigateTo: (screen: ScreenType) => void;
  goBack: () => void;

  // Active Selections
  selectedHospital: Hospital | null;
  selectHospital: (hospital: Hospital) => void;
  selectedMeal: Meal | null;
  setSelectedMeal: (meal: Meal | null) => void;
  customizingMeal: Meal | null;
  setCustomizingMeal: (meal: Meal | null) => void;

  // User State
  user: User | null;
  loginAsGuest: (shouldNavigate?: boolean) => void;
  loginWithPhone: (phone: string) => void;
  setUserRole: (role: UserRole) => void;
  setPatientDetails: (details: PatientDetails) => void;
  setEmployeeDetails: (details: EmployeeDetails) => void;
  completeSignup: (data: {
    phone: string;
    role: UserRole;
    hospital: Hospital;
    patientDetails?: PatientDetails;
    employeeDetails?: EmployeeDetails;
  }) => void;
  logout: () => void;

  // Favorites
  favorites: string[]; // meal ids
  toggleFavorite: (mealId: string) => void;
  isFavorite: (mealId: string) => boolean;

  // Cart
  cart: CartItem[];
  addToCart: (meal: Meal, quantity: number, customization: MealCustomization) => void;
  updateCartQuantity: (cartItemId: string, delta: number) => void;
  removeFromCart: (cartItemId: string) => void;
  clearCart: () => void;
  cartCount: number;
  cartSubtotal: number;
  scheduleDiscountAmount: number;
  cartTotal: number;

  // Time Simulation & Schedule Discounts
  simulatedTime: string;
  setSimulatedTime: (time: string) => void;
  getClinicalScheduleInfo: (category: string) => {
    isAvailable: boolean;
    discountPercentage: number;
    discountLabel: string;
    message: string;
    deadlineStr: string;
  };

  // Coupon
  appliedCoupon: Offer | null;
  applyCoupon: (code: string) => boolean;
  removeCoupon: () => void;

  // Orders
  orders: Order[];
  placeOrder: (paymentMethod: 'Cash' | 'UPI' | 'Card') => Order;
  activeOrder: Order | null;
  setActiveOrder: (order: Order | null) => void;
  updateOrderStatus: (orderId: string, status: OrderStatus) => void;

  // App Settings
  darkMode: boolean;
  setDarkMode: (val: boolean) => void;
  notificationsEnabled: boolean;
  setNotificationsEnabled: (val: boolean) => void;
  language: 'English' | 'Kannada' | 'Urdu';
  setLanguage: (lang: 'English' | 'Kannada' | 'Urdu') => void;
  translate: (text: string) => string;
  t: (text: string) => string;

  // Notifications
  notifications: AppNotification[];
  addNotification: (title: string, message: string) => void;
  markNotificationsAsRead: () => void;

  // Live Location
  userLiveLocation: string;
  setUserLiveLocation: (location: string) => void;
  fetchLiveLocation: () => Promise<void>;
  isLoadingLocation: boolean;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [screen, setScreenState] = useState<ScreenType>('splash');
  const [screenHistory, setScreenHistory] = useState<ScreenType[]>(['splash']);
  
  const [selectedHospital, setSelectedHospitalState] = useState<Hospital | null>(() => {
    const saved = localStorage.getItem('hp_hospital');
    return saved ? JSON.parse(saved) : null;
  });
  
  const [selectedMeal, setSelectedMeal] = useState<Meal | null>(null);
  const [customizingMeal, setCustomizingMeal] = useState<Meal | null>(null);
  
  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem('hp_user');
    return saved ? JSON.parse(saved) : null;
  });
  
  const [favorites, setFavorites] = useState<string[]>(() => {
    const saved = localStorage.getItem('hp_favorites');
    return saved ? JSON.parse(saved) : [];
  });
  
  const [cart, setCart] = useState<CartItem[]>(() => {
    const saved = localStorage.getItem('hp_cart');
    return saved ? JSON.parse(saved) : [];
  });
  
  const [appliedCoupon, setAppliedCoupon] = useState<Offer | null>(null);

  const [simulatedTime, setSimulatedTime] = useState<string>('Real Time');

  const getEffectiveTime = () => {
    if (simulatedTime === 'Real Time') {
      const now = new Date();
      return {
        hours: now.getHours(),
        minutes: now.getMinutes(),
      };
    } else {
      const [h, m] = simulatedTime.split(':').map(Number);
      return { hours: h, minutes: m };
    }
  };

  const getClinicalScheduleInfo = (category: string) => {
    const { hours, minutes } = getEffectiveTime();
    const timeInMinutes = hours * 60 + minutes;

    if (category === 'Breakfast') {
      const cutoff = 9 * 60 + 30; // 9:30 AM
      if (timeInMinutes > cutoff) {
        return {
          isAvailable: false,
          discountPercentage: 0,
          discountLabel: '',
          message: 'Breakfast closed for today (cutoff 9:30 AM).',
          deadlineStr: '09:30 AM',
        };
      }
      
      const before8 = 8 * 60; // 8:00 AM
      const before845 = 8 * 60 + 45; // 8:45 AM
      
      if (timeInMinutes < before8) {
        return {
          isAvailable: true,
          discountPercentage: 20,
          discountLabel: '20% Early Breakfast Saver',
          message: 'Secure 20% discount! Early bird delivery starts at 3:30 AM.',
          deadlineStr: '08:00 AM',
        };
      } else if (timeInMinutes < before845) {
        return {
          isAvailable: true,
          discountPercentage: 10,
          discountLabel: '10% Mid-Morning Breakfast Discount',
          message: 'Secure 10% discount on breakfast ordered before 8:45 AM.',
          deadlineStr: '08:45 AM',
        };
      } else {
        return {
          isAvailable: true,
          discountPercentage: 0,
          discountLabel: '',
          message: 'Standard pricing. Breakfast orders close at 9:30 AM.',
          deadlineStr: '09:30 AM',
        };
      }
    }

    if (category === 'Lunch') {
      const cutoff = 14 * 60; // 2:00 PM
      if (timeInMinutes > cutoff) {
        return {
          isAvailable: false,
          discountPercentage: 0,
          discountLabel: '',
          message: 'Lunch closed for today (cutoff 2:00 PM).',
          deadlineStr: '02:00 PM',
        };
      }
      
      const before1230 = 12 * 60 + 30; // 12:30 PM
      const before115 = 13 * 60 + 15; // 1:15 PM
      
      if (timeInMinutes < before1230) {
        return {
          isAvailable: true,
          discountPercentage: 15,
          discountLabel: '15% Early Lunch Saver',
          message: 'Secure 15% discount on early lunch ordered before 12:30 PM.',
          deadlineStr: '12:30 PM',
        };
      } else if (timeInMinutes < before115) {
        return {
          isAvailable: true,
          discountPercentage: 8,
          discountLabel: '8% Mid-Day Lunch Discount',
          message: 'Secure 8% discount on lunch ordered before 1:15 PM.',
          deadlineStr: '01:15 PM',
        };
      } else {
        return {
          isAvailable: true,
          discountPercentage: 0,
          discountLabel: '',
          message: 'Standard pricing. Lunch orders close at 2:00 PM.',
          deadlineStr: '02:00 PM',
        };
      }
    }

    return {
      isAvailable: true,
      discountPercentage: 0,
      discountLabel: '',
      message: '',
      deadlineStr: '',
    };
  };
  
  const [orders, setOrders] = useState<Order[]>(() => {
    const saved = localStorage.getItem('hp_orders');
    return saved ? JSON.parse(saved) : [];
  });
  
  const [activeOrder, setActiveOrder] = useState<Order | null>(() => {
    const saved = localStorage.getItem('hp_active_order');
    return saved ? JSON.parse(saved) : null;
  });

  // Settings
  const [darkMode, setDarkMode] = useState<boolean>(false);
  const [notificationsEnabled, setNotificationsEnabledState] = useState<boolean>(() => {
    const saved = localStorage.getItem('hp_notif_enabled');
    return saved !== null ? saved === 'true' : true;
  });
  const [language, setLanguageState] = useState<'English' | 'Kannada' | 'Urdu'>(() => {
    const saved = localStorage.getItem('hp_language');
    return (saved as 'English' | 'Kannada' | 'Urdu') || 'English';
  });

  const setLanguage = (lang: 'English' | 'Kannada' | 'Urdu') => {
    setLanguageState(lang);
    localStorage.setItem('hp_language', lang);
  };

  // Translation Dictionary
  const translations: Record<string, Record<string, string>> = {
    'Cura Meal': { 'Kannada': 'ಕ್ಯೂರಾ ಬೈಟ್', 'Urdu': 'کیورا بائٹ' },
    'Instant Search': { 'Kannada': 'ತ್ವರಿತ ಹುಡುಕಾಟ', 'Urdu': 'فوری تلاش' },
    'Search': { 'Kannada': 'ಹುಡುಕಾಟ', 'Urdu': 'ತಲಾಶ್' },
    'Recovery Progress & History': { 'Kannada': 'ಚೇತರಿಕೆ ಪ್ರಗತಿ ಮತ್ತು ಇತಿಹಾಸ', 'Urdu': 'صحت یابی کی ترقی اور تاریخچہ' },
    'Orders': { 'Kannada': 'ಆರ್ಡರ್‌ಗಳು', 'Urdu': 'آرڈرز' },
    'My Favorites': { 'Kannada': 'ನನ್ನ ನೆಚ್ಚಿನವುಗಳು', 'Urdu': 'میری پسندیدہ' },
    'Favorites': { 'Kannada': 'ನೆಚ್ಚಿನವುಗಳು', 'Urdu': 'پسندیدہ' },
    'Preferences': { 'Kannada': 'ಆದ್ಯತೆಗಳು', 'Urdu': 'ترجیحات' },
    'Preferences Configuration': { 'Kannada': 'ಆದ್ಯತೆಗಳ ಸಂರಚನೆ', 'Urdu': 'ترجیحات کی ترتیب' },
    'Settings': { 'Kannada': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು', 'Urdu': 'ترتیبات' },
    'Good Morning ☀️': { 'Kannada': 'ಶುಭೋದಯ ☀️', 'Urdu': 'صبح بخیر ☀️' },
    'Good Afternoon 🌤️': { 'Kannada': 'ಶುಭ ಮಧ್ಯಾಹ್ನ 🌤️', 'Urdu': 'سہ پہر بخیر 🌤️' },
    'Good Evening 🌙': { 'Kannada': 'ಶುಭ ಸಂಜೆ 🌙', 'Urdu': 'شام بخیر 🌙' },
    'What clean nutrition do you need today?': { 'Kannada': 'ಇಂದು ನಿಮಗೆ ಯಾವ ಶುದ್ಧ ಪೌಷ್ಟಿಕಾಂಶದ ಅಗತ್ಯವಿದೆ?', 'Urdu': 'آج آپ کو کون سی صاف ستھری غذا چاہیے؟' },
    'Language Settings': { 'Kannada': 'ಭಾಷಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳು', 'Urdu': 'زبان کی ترتیبات' },
    'Push Notifications': { 'Kannada': 'ಪುಶ್ ನೋಟಿಫಿಕೇಶನ್‌ಗಳು', 'Urdu': 'پش نوٹیفیکیشنز' },
    'Admitted status alarms': { 'Kannada': 'ದಾಖಲಾತಿ ಸ್ಥಿತಿ ಅಲಾರಂಗಳು', 'Urdu': 'داخل مریض کی حیثیت کے الارم' },
    'Pings when sterile container leaves kitchen.': { 'Kannada': 'ಅಡುಗೆಮನೆಯಿಂದ ಆಹಾರ ಹೊರಟಾಗ ತಿಳಿಸುತ್ತದೆ.', 'Urdu': 'جب کھانا باورچی خانے سے روانہ ہوتا ہے تو اطلاع ملتی ہے۔' },
    'Compliance & Health Info': { 'Kannada': 'ಅನುಸರಣೆ ಮತ್ತು ಆರೋಗ್ಯ ಮಾಹಿತಿ', 'Urdu': 'تعمیل اور صحت کی معلومات' },
    'Compliance & Health Information': { 'Kannada': 'ಅನುಸರಣೆ ಮತ್ತು ಆರೋಗ್ಯ ಮಾಹಿತಿ', 'Urdu': 'تعمیل اور صحت کی معلومات' },
    'Sterilized Kitchen Security': { 'Kannada': 'ಕ್ರಿಮಿನಾಶಕ ಅಡುಗೆಮನೆ ಭದ್ರತೆ', 'Urdu': 'جراثیم سے پاک باورچی خانے کی حفاظت' },
    'Guest Terms & Privacy': { 'Kannada': 'ಅತಿಥಿ ನಿಯಮಗಳು ಮತ್ತು ಗೌಪ್ಯತೆ', 'Urdu': 'مہمان کی شرائط اور رازداری' },
    'Dial Bedside Emergency Help': { 'Kannada': 'ಬೆಡ್‌ಸೈಡ್ ತುರ್ತು ಸಹಾಯಕ್ಕೆ ಕರೆ ಮಾಡಿ', 'Urdu': 'بیڈ سائیڈ ہنگامی مدد' },
    'Bhatkal healthcare units support English, local Kannada, and Urdu diets.': { 'Kannada': 'ಭಟ್ಕಳ ಆರೋಗ್ಯ ಕೇಂದ್ರಗಳು ಇಂಗ್ಲಿಷ್, ಸ್ಥಳೀಯ ಕನ್ನಡ ಮತ್ತು ಉರ್ದು ಆಹಾರಗಳನ್ನು ಬೆಂಬಲಿಸುತ್ತವೆ.', 'Urdu': 'بھٹکل ہیلتھ کیئر یونٹس انگریزی، مقامی کنڑ، اور اردو غذاؤں کو سپورٹ کرتے ہیں۔' },
    'Management & Admin Portal': { 'Kannada': 'ನಿರ್ವಹಣೆ ಮತ್ತು ಆಡಳಿತ ಪೋರ್ಟಲ್', 'Urdu': 'انتظامیہ اور ایڈمن پورٹل' },
    'Open Admin Setup': { 'Kannada': 'ಆಡಳಿತ ಪೋರ್ಟಲ್ ತೆರೆಯಿರಿ', 'Urdu': 'ایڈمن پورٹل کھولیں' },
    'Grand Total': { 'Kannada': 'ಒಟ್ಟು ಮೊತ್ತ', 'Urdu': 'کل رقم' },
    'Hello': { 'Kannada': 'ನಮಸ್ಕಾರ', 'Urdu': 'سلام' },
    'Home': { 'Kannada': 'ಮುಖಪುಟ', 'Urdu': 'ہوم' },
    'Care Pack': { 'Kannada': 'ಆರೈಕೆ ಪ್ಯಾಕ್', 'Urdu': 'کیئر پیک' },
    'Send a Care Pack': { 'Kannada': 'ಆರೈಕೆ ಪ್ಯಾಕ್ ಕಳುಹಿಸಿ', 'Urdu': 'کیئر پیک بھیجیں' },
    'Price': { 'Kannada': 'ಬೆಲೆ', 'Urdu': 'قیمت' },
    'Add': { 'Kannada': 'ಸೇರಿಸಿ', 'Urdu': 'شامل کریں' }
  };

  const translate = (text: string): string => {
    if (language === 'English') return text;
    if (translations[text] && translations[text][language]) {
      return translations[text][language];
    }
    return text;
  };

  const setNotificationsEnabled = (val: boolean) => {
    setNotificationsEnabledState(val);
    localStorage.setItem('hp_notif_enabled', String(val));
    if (val && typeof window !== 'undefined' && 'Notification' in window) {
      Notification.requestPermission().then(perm => {
        if (perm === 'granted') {
          sendSystemNotification('Cura Meal', 'Notification alerts activated successfully!');
        }
      });
    }
  };

  // Live Location
  const [userLiveLocation, setUserLiveLocation] = useState<string>(() => {
    return localStorage.getItem('hp_live_location') || 'Fetching live location...';
  });
  const [isLoadingLocation, setIsLoadingLocation] = useState<boolean>(false);

  const fetchLiveLocation = async () => {
    if (typeof window === 'undefined' || !navigator.geolocation) {
      setUserLiveLocation('GPS Not Supported');
      return;
    }

    setIsLoadingLocation(true);
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude, longitude } = position.coords;
        try {
          // Reverse geocoding via OpenStreetMap Nominatim
          const response = await fetch(
            `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`,
            {
              headers: {
                'Accept-Language': 'en',
                'User-Agent': 'CuraMealApp'
              }
            }
          );
          if (response.ok) {
            const data = await response.json();
            const address = data.display_name || '';
            const parts = address.split(', ');
            const shortAddress = parts.slice(0, 3).join(', ');
            const finalAddress = shortAddress || `GPS: ${latitude.toFixed(4)}, ${longitude.toFixed(4)}`;
            setUserLiveLocation(finalAddress);
            localStorage.setItem('hp_live_location', finalAddress);
          } else {
            const fallback = `GPS: ${latitude.toFixed(4)}, ${longitude.toFixed(4)}`;
            setUserLiveLocation(fallback);
            localStorage.setItem('hp_live_location', fallback);
          }
        } catch (error) {
          const fallback = `GPS: ${latitude.toFixed(4)}, ${longitude.toFixed(4)}`;
          setUserLiveLocation(fallback);
          localStorage.setItem('hp_live_location', fallback);
        } finally {
          setIsLoadingLocation(false);
        }
      },
      (error) => {
        console.log('Info: Geolocation error:', error.message);
        let errorMsg = 'Location Access Denied';
        if (error.code === 2) {
          errorMsg = 'GPS Unavailable';
        } else if (error.code === 3) {
          errorMsg = 'GPS Timeout';
        }
        setUserLiveLocation(errorMsg);
        setIsLoadingLocation(false);
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 5000 }
    );
  };

  useEffect(() => {
    if (typeof window !== 'undefined' && 'navigator' in window && navigator.geolocation) {
      if ('permissions' in navigator) {
        navigator.permissions.query({ name: 'geolocation' as PermissionName }).then((status) => {
          if (status.state === 'granted') {
            fetchLiveLocation();
          } else if (userLiveLocation === 'Fetching location...') {
            setUserLiveLocation('Tap to share location');
          }
        }).catch(() => {
          fetchLiveLocation();
        });
      } else {
        fetchLiveLocation();
      }
    } else {
      setUserLiveLocation('Bhatkal, Karnataka');
    }

    // Automatically request Notification permission if enabled in state and not yet requested/granted
    if (notificationsEnabled && typeof window !== 'undefined' && 'Notification' in window) {
      if (Notification.permission === 'default') {
        Notification.requestPermission().then((perm) => {
          if (perm === 'granted') {
            sendSystemNotification('Cura Meal', 'Notification alerts activated successfully!');
          }
        });
      }
    }
  }, []);

  // Notifications list
  const [notifications, setNotifications] = useState<AppNotification[]>([
    {
      id: 'n1',
      title: 'Welcome to Cura Meal!',
      message: 'Get fresh, nutritious meals served hot in your hospital ward.',
      time: 'Just now',
      isRead: false,
    },
  ]);

  // Persist selections
  useEffect(() => {
    localStorage.setItem('hp_favorites', JSON.stringify(favorites));
  }, [favorites]);

  useEffect(() => {
    localStorage.setItem('hp_cart', JSON.stringify(cart));
  }, [cart]);

  useEffect(() => {
    localStorage.setItem('hp_orders', JSON.stringify(orders));
  }, [orders]);

  // Sync real-time orders from Firestore
  useEffect(() => {
    try {
      const unsubOrders = onSnapshot(collection(db, 'orders'), (snapshot) => {
        const fetchedOrders: Order[] = [];
        snapshot.forEach((docSnap) => {
          fetchedOrders.push(docSnap.data() as Order);
        });
        if (fetchedOrders.length > 0) {
          // Sort newest first
          fetchedOrders.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
          setOrders(fetchedOrders);
        }
      }, (err) => {
        console.warn('Firestore orders sync notice:', err.message);
      });

      return () => unsubOrders();
    } catch (e) {
      console.warn('Firestore error initializing listener:', e);
    }
  }, []);

  useEffect(() => {
    if (activeOrder) {
      localStorage.setItem('hp_active_order', JSON.stringify(activeOrder));
    } else {
      localStorage.removeItem('hp_active_order');
    }
  }, [activeOrder]);

  const navigateTo = (nextScreen: ScreenType) => {
    setScreenState(nextScreen);
    setScreenHistory(prev => [...prev, nextScreen]);
  };

  const goBack = () => {
    if (screenHistory.length > 1) {
      const updated = [...screenHistory];
      updated.pop(); // remove current
      const prev = updated[updated.length - 1];
      setScreenHistory(updated);
      setScreenState(prev);
    } else {
      setScreenState('home');
    }
  };

  const selectHospital = (hospital: Hospital) => {
    setSelectedHospitalState(hospital);
    localStorage.setItem('hp_hospital', JSON.stringify(hospital));
    
    // Update user state too if exists
    if (user) {
      const updated = { ...user, selectedHospitalId: hospital.id };
      setUser(updated);
      localStorage.setItem('hp_user', JSON.stringify(updated));
    }
  };

  const loginAsGuest = (shouldNavigate: boolean = true) => {
    const guestUser: User = {
      phone: 'Guest',
      role: 'Patient',
      selectedHospitalId: selectedHospital?.id || '',
    };
    setUser(guestUser);
    localStorage.setItem('hp_user', JSON.stringify(guestUser));
    if (shouldNavigate) {
      navigateTo('home');
    }
  };

  const loginWithPhone = (phone: string) => {
    const newUser: User = {
      phone,
      role: 'Patient',
      selectedHospitalId: selectedHospital?.id || '',
    };
    setUser(newUser);
    localStorage.setItem('hp_user', JSON.stringify(newUser));
    navigateTo('select-hospital');
  };

  const setUserRole = (role: UserRole) => {
    if (user) {
      const updated = { ...user, role };
      setUser(updated);
      localStorage.setItem('hp_user', JSON.stringify(updated));
      if (role === 'Patient') {
        navigateTo('patient-flow');
      } else {
        navigateTo('employee-flow');
      }
    }
  };

  const setPatientDetails = (details: PatientDetails) => {
    if (user) {
      const updated = { ...user, patientDetails: details, employeeDetails: undefined };
      setUser(updated);
      localStorage.setItem('hp_user', JSON.stringify(updated));
      
      // Sync user to Firestore
      try {
        const userDocId = user.phone || 'user_' + Date.now();
        const cleanUserData = JSON.parse(JSON.stringify({
          ...updated,
          registeredAt: new Date().toISOString(),
        }));
        setDoc(doc(db, 'registered_users', userDocId), cleanUserData, { merge: true }).catch(e => console.warn('Firestore user save error:', e));
      } catch (e) {
        console.warn('Firestore user save error:', e);
      }

      navigateTo('home');
      addNotification('Details Configured', `Recovery Guest ${details.patientName} registered in Room ${details.roomNumber}, Ward ${details.ward}.`);
    }
  };

  const setEmployeeDetails = (details: EmployeeDetails) => {
    if (user) {
      const updated = { ...user, employeeDetails: details, patientDetails: undefined };
      setUser(updated);
      localStorage.setItem('hp_user', JSON.stringify(updated));

      // Sync user to Firestore
      try {
        const userDocId = user.phone || 'user_' + Date.now();
        const cleanUserData = JSON.parse(JSON.stringify({
          ...updated,
          registeredAt: new Date().toISOString(),
        }));
        setDoc(doc(db, 'registered_users', userDocId), cleanUserData, { merge: true }).catch(e => console.warn('Firestore user save error:', e));
      } catch (e) {
        console.warn('Firestore user save error:', e);
      }

      navigateTo('home');
      addNotification('Details Configured', `Employee ${details.employeeName} logged in under ${details.department} Department.`);
    }
  };

  const completeSignup = (data: {
    phone: string;
    email?: string;
    role: UserRole;
    hospital: Hospital;
    patientDetails?: PatientDetails;
    employeeDetails?: EmployeeDetails;
  }) => {
    const newUser: User = {
      phone: data.phone,
      email: data.email,
      role: data.role,
      selectedHospitalId: data.hospital.id,
      patientDetails: data.patientDetails,
      employeeDetails: data.employeeDetails,
    };
    setUser(newUser);
    setSelectedHospitalState(data.hospital);
    localStorage.setItem('hp_user', JSON.stringify(newUser));
    localStorage.setItem('hp_hospital', JSON.stringify(data.hospital));

    // Sync user registration to Firestore
    try {
      const userDocId = data.phone || 'user_' + Date.now();
      const cleanSignupData = JSON.parse(JSON.stringify({
        ...newUser,
        hospitalName: data.hospital.name,
        registeredAt: new Date().toISOString(),
      }));
      setDoc(doc(db, 'registered_users', userDocId), cleanSignupData, { merge: true }).catch(e => console.warn('Firestore user signup error:', e));
    } catch (e) {
      console.warn('Firestore user signup error:', e);
    }

    addNotification('Welcome', `Bedside registration complete for ${data.patientDetails?.patientName || data.employeeDetails?.employeeName || 'User'}.`);
  };

  const logout = () => {
    setUser(null);
    setSelectedHospitalState(null);
    setCart([]);
    setAppliedCoupon(null);
    setActiveOrder(null);
    localStorage.removeItem('hp_user');
    localStorage.removeItem('hp_hospital');
    localStorage.removeItem('hp_cart');
    localStorage.removeItem('hp_active_order');
    setScreenState('login');
    setScreenHistory(['login']);
  };

  const toggleFavorite = (mealId: string) => {
    setFavorites(prev => 
      prev.includes(mealId) ? prev.filter(id => id !== mealId) : [...prev, mealId]
    );
  };

  const isFavorite = (mealId: string) => favorites.includes(mealId);

  // Default meal customization
  const defaultMealCustomization: MealCustomization = {
    extraRice: false,
    extraCurry: false,
    saltPreference: 'Normal',
    spicePreference: 'Normal',
    noOnion: false,
    noGarlic: false,
    extraSalad: false,
    extraCurd: false,
    specialInstructions: '',
    addonEggBanana: false,
  };

  // Helper to calculate a stable hash of meal customization to group items in cart
  const getCustomizationKey = (cust: MealCustomization = defaultMealCustomization) => {
    const c = { ...defaultMealCustomization, ...(cust || {}) };
    return `${c.extraRice ? '1' : '0'}-${c.extraCurry ? '1' : '0'}-${c.saltPreference || 'Normal'}-${c.spicePreference || 'Normal'}-${c.noOnion ? '1' : '0'}-${c.noGarlic ? '1' : '0'}-${c.extraCurd ? '1' : '0'}-${c.addonEggBanana ? '1' : '0'}-${(c.specialInstructions || '').trim()}`;
  };

  const addToCart = (
    meal: Meal, 
    quantity: number = 1, 
    customization: MealCustomization = defaultMealCustomization
  ) => {
    const custToUse = { ...defaultMealCustomization, ...(customization || {}) };
    const sched = getClinicalScheduleInfo(meal.category);
    if (!sched.isAvailable) {
      addNotification('Order Restricted', `Cannot add ${meal.name} as ${meal.category} ordering has closed for today.`);
      return;
    }

    const custKey = getCustomizationKey(custToUse);
    const cartItemId = `${meal.id}-${custKey}`;

    setCart(prev => {
      const existingIndex = prev.findIndex(item => item.id === cartItemId);
      if (existingIndex > -1) {
        const updated = [...prev];
        updated[existingIndex].quantity += (quantity || 1);
        return updated;
      } else {
        return [...prev, { id: cartItemId, meal, quantity: (quantity || 1), customization: custToUse }];
      }
    });

    addNotification('Added to Tray', `${meal.name} added to your food tray.`);
  };

  const updateCartQuantity = (cartItemId: string, delta: number) => {
    setCart(prev => {
      const itemIndex = prev.findIndex(item => item.id === cartItemId);
      if (itemIndex > -1) {
        const updated = [...prev];
        const newQty = updated[itemIndex].quantity + delta;
        if (newQty <= 0) {
          return prev.filter(item => item.id !== cartItemId);
        } else {
          updated[itemIndex].quantity = newQty;
          return updated;
        }
      }
      return prev;
    });
  };

  const removeFromCart = (cartItemId: string) => {
    setCart(prev => prev.filter(item => item.id !== cartItemId));
  };

  const clearCart = () => {
    setCart([]);
    setAppliedCoupon(null);
  };

  const cartCount = cart.reduce((total, item) => total + item.quantity, 0);
  
  const cartSubtotal = cart.reduce((total, item) => {
    const cust = item.customization || defaultMealCustomization;
    const itemPrice = item.meal.price + 
      (cust.extraRice ? 25 : 0) + 
      (cust.extraCurry ? 30 : 0) + 
      (cust.extraCurd ? 15 : 0) +
      (cust.addonEggBanana ? 20 : 0);
    return total + (itemPrice * item.quantity);
  }, 0);

  const scheduleDiscountAmount = cart.reduce((total, item) => {
    const info = getClinicalScheduleInfo(item.meal.category);
    if (info.isAvailable && info.discountPercentage > 0) {
      return total + Math.round((item.meal.price * item.quantity * info.discountPercentage) / 100);
    }
    return total;
  }, 0);

  const discountAmount = appliedCoupon 
    ? Math.round((cartSubtotal * appliedCoupon.discountPercentage) / 100) 
    : 0;

  // Let's add standard GST & delivery charge logic
  // For hospitals, maybe lower delivery or free delivery
  const deliveryCharge = cartSubtotal > 0 ? 30 : 0;
  const gst = cartSubtotal > 0 ? Math.round(cartSubtotal * 0.05) : 0; // 5% GST for medical meal
  const cartTotal = Math.max(0, cartSubtotal + deliveryCharge + gst - discountAmount - scheduleDiscountAmount);

  const applyCoupon = (code: string): boolean => {
    const found = OFFERS.find(o => o.code.toUpperCase() === code.toUpperCase());
    if (found && cartSubtotal >= found.minOrderValue) {
      setAppliedCoupon(found);
      addNotification('Coupon Applied!', `You saved ₹${Math.round((cartSubtotal * found.discountPercentage) / 100)} with ${found.code}.`);
      return true;
    }
    return false;
  };

  const removeCoupon = () => {
    setAppliedCoupon(null);
  };

  const placeOrder = (paymentMethod: 'Cash' | 'UPI' | 'Card'): Order => {
    const orderNum = 'HP' + Math.floor(100000 + Math.random() * 900000);
    const newOrder: Order = {
      id: Math.random().toString(36).substr(2, 9),
      orderNumber: orderNum,
      items: [...cart],
      hospitalId: selectedHospital?.id || '',
      hospitalName: selectedHospital?.name || 'Bhatkal Hospital',
      userRole: user?.role || 'Patient',
      patientDetails: user?.patientDetails,
      employeeDetails: user?.employeeDetails,
      subtotal: cartSubtotal,
      deliveryCharge,
      gst,
      discount: discountAmount,
      grandTotal: cartTotal,
      paymentMethod,
      status: 'Received',
      createdAt: new Date().toISOString(),
      estimatedDeliveryMinutes: 25 + Math.floor(Math.random() * 15),
    };

    setOrders(prev => [newOrder, ...prev]);
    setActiveOrder(newOrder);
    clearCart();
    navigateTo('success');
    addNotification('Order Placed!', `Your meal order ${orderNum} has been received and sent to the kitchen.`);

    // Sync order to Firestore
    try {
      const cleanOrder = JSON.parse(JSON.stringify(newOrder));
      setDoc(doc(db, 'orders', newOrder.id), cleanOrder).catch(e => console.error('Firestore placeOrder error:', e));
    } catch (e) {
      console.error('Firestore placeOrder error:', e);
    }

    return newOrder;
  };

  const simulateOrderStatusProgress = (orderId: string) => {
    // Stage 1: Received -> Preparing (after 10 seconds)
    setTimeout(() => {
      updateOrderStatus(orderId, 'Preparing');
    }, 10000);

    // Stage 2: Preparing -> Out for Delivery (after 25 seconds)
    setTimeout(() => {
      updateOrderStatus(orderId, 'Out for Delivery');
    }, 25000);

    // Stage 3: Out for Delivery -> Delivered (after 45 seconds)
    setTimeout(() => {
      updateOrderStatus(orderId, 'Delivered');
    }, 45000);
  };

  const updateOrderStatus = (orderId: string, status: OrderStatus) => {
    setOrders(prev => prev.map(o => o.id === orderId ? { ...o, status } : o));

    // Sync status change to Firestore
    try {
      updateDoc(doc(db, 'orders', orderId), { status }).catch(e => console.warn('Firestore status update error:', e));
    } catch (e) {
      console.warn('Firestore status update error:', e);
    }
    
    // Always trigger the status change notification
    let message = '';
    if (status === 'Preparing') message = 'Our health chefs have started preparing your nutritious meal with sterile care.';
    if (status === 'Out for Delivery') message = 'Your hot container is on the way to your hospital ward!';
    if (status === 'Delivered') message = 'Meal delivered! Enjoy your warm meal. Wish you a speedy recovery!';
    
    if (message) {
      addNotification(`Order status: ${status}`, message);
    }

    setActiveOrder(prev => {
      if (prev && prev.id === orderId) {
        const updated = { ...prev, status };
        localStorage.setItem('hp_active_order', JSON.stringify(updated));
        return updated;
      }
      return prev;
    });
  };

  const addNotification = (title: string, message: string) => {
    const newNotif: AppNotification = {
      id: Math.random().toString(36).substr(2, 9),
      title,
      message,
      time: 'Just now',
      isRead: false,
    };
    setNotifications(prev => [newNotif, ...prev]);

    if (notificationsEnabled) {
      sendSystemNotification(title, message);
    }
  };

  const markNotificationsAsRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, isRead: true })));
  };

  return (
    <AppContext.Provider value={{
      screen,
      setScreen: setScreenState,
      screenHistory,
      navigateTo,
      goBack,
      selectedHospital,
      selectHospital,
      selectedMeal,
      setSelectedMeal,
      customizingMeal,
      setCustomizingMeal,
      user,
      loginAsGuest,
      loginWithPhone,
      setUserRole,
      setPatientDetails,
      setEmployeeDetails,
      completeSignup,
      logout,
      favorites,
      toggleFavorite,
      isFavorite,
      cart,
      addToCart,
      updateCartQuantity,
      removeFromCart,
      clearCart,
      cartCount,
      cartSubtotal,
      scheduleDiscountAmount,
      cartTotal: cartTotal,
      simulatedTime,
      setSimulatedTime,
      getClinicalScheduleInfo,
      appliedCoupon,
      applyCoupon,
      removeCoupon,
      orders,
      placeOrder,
      activeOrder,
      setActiveOrder,
      updateOrderStatus,
      darkMode,
      setDarkMode,
      notificationsEnabled,
      setNotificationsEnabled,
      language,
      setLanguage,
      translate,
      t: translate,
      notifications,
      addNotification,
      markNotificationsAsRead,
      userLiveLocation,
      setUserLiveLocation,
      fetchLiveLocation,
      isLoadingLocation,
    }}>
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) throw new Error('useApp must be used within an AppProvider');
  return context;
};
