import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { MEALS, OFFERS } from '../data';
import { Meal, MealCategory } from '../types';
import { 
  Search, Star, Heart, Flame, Dumbbell, Sparkles, ShoppingBag, Plus,
  User, MapPin, ClipboardList, Shield, Globe, Bell, Eye, EyeOff,
  Check, ArrowRight, ArrowLeft, HelpCircle, ChevronRight, ChevronUp, ChevronDown, FileText, Info, LogOut, Smartphone
} from 'lucide-react';

// ==========================================
// 1. INSTANT SEARCH SCREEN
// ==========================================
export const SearchScreen: React.FC = () => {
  const { setSelectedMeal, navigateTo, t } = useApp();
  const [query, setQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('All');

  const categories = [
    { id: 'All', label: 'All', icon: '🍽️' },
    { id: 'Breakfast', label: 'Breakfast', icon: '🥣' },
    { id: 'Soup', label: 'Soup', icon: '🍵' },
    { id: 'Lunch', label: 'Lunch', icon: '🍛' },
    { id: 'Juice', label: 'Juice', icon: '🥤' },
    { id: 'Snacks', label: 'Snacks', icon: '🍎' },
    { id: 'Grocery', label: 'Essentials', icon: '📦' },
  ];

  const filteredMeals = MEALS.filter(meal => {
    const textMatch = meal.name.toLowerCase().includes(query.toLowerCase()) || 
                      meal.description.toLowerCase().includes(query.toLowerCase());
    
    if (!textMatch) return false;
    if (selectedCategory !== 'All' && meal.category !== selectedCategory) return false;

    return true;
  });

  const handleMealClick = (meal: Meal) => {
    setSelectedMeal(meal);
    navigateTo('meal-detail');
  };

  return (
    <div id="search-view" className="pb-24 bg-brand-cream min-h-screen">
      {/* Search Header */}
      <div className="bg-white p-4 shadow-sm border-b border-gray-100 max-w-4xl mx-auto sticky top-0 z-30">
        <div className="relative">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4.5 h-4.5 text-brand-green-dark" />
          <input 
            type="text" 
            autoFocus
            placeholder="Search nutritious soups, khichdi, idli, upma..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-3 bg-brand-cream rounded-2xl text-xs font-semibold focus:bg-white focus:ring-2 focus:ring-brand-green-light focus:border-transparent transition"
          />
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-3 sm:px-4 mt-4 flex flex-row gap-3 items-start">
        {/* Left Side Categories (Vertical on all screen sizes) */}
        <div className="w-28 sm:w-44 bg-white p-2 sm:p-3 rounded-2xl border border-brand-green-light/25 shadow-sm sticky top-20 flex-shrink-0">
          <h3 className="text-[10px] sm:text-[11px] font-black uppercase text-brand-green-dark tracking-wider mb-2 px-1 sm:px-2">
            Categories
          </h3>
          <div className="flex flex-col gap-1.5">
            {categories.map((cat) => (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id)}
                className={`w-full text-left px-2 sm:px-3 py-2 sm:py-2.5 rounded-xl text-[11px] sm:text-xs font-bold transition flex items-center gap-1.5 sm:gap-2 cursor-pointer ${
                  selectedCategory === cat.id 
                    ? 'bg-brand-green-dark text-white shadow-sm' 
                    : 'text-brand-dark hover:bg-brand-cream/80 bg-brand-cream/40'
                }`}
              >
                <span className="text-sm sm:text-base">{cat.icon}</span>
                <span className="truncate">{t(cat.label)}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Right Side Search Results */}
        <div className="flex-1 min-w-0 space-y-3">
          <div className="flex justify-between items-center px-1">
            <span className="text-xs text-brand-light font-medium">
              Showing {filteredMeals.length} dishes
            </span>
          </div>

          {filteredMeals.length > 0 ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              {filteredMeals.map(meal => (
                <div 
                  key={meal.id}
                  onClick={() => handleMealClick(meal)}
                  className="bg-white p-2.5 sm:p-3 rounded-2xl border border-brand-green-light/25 shadow-sm hover:shadow-md transition cursor-pointer flex items-center justify-between gap-2.5 group"
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    <img 
                      src={meal.image} 
                      alt={meal.name} 
                      className="w-14 h-14 sm:w-16 sm:h-16 rounded-xl object-cover flex-shrink-0 bg-gray-50 border border-gray-100" 
                    />
                    <h4 className="text-xs font-black text-brand-dark group-hover:text-brand-green-dark transition truncate">
                      {meal.name}
                    </h4>
                  </div>
                  <span className="text-xs font-extrabold text-brand-green-dark flex-shrink-0 bg-brand-green-light/30 px-2 sm:px-2.5 py-1 rounded-lg">
                    ₹{meal.price}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-12 bg-white rounded-2xl border border-brand-green-light/25">
              <p className="text-sm text-brand-light italic">No matching healthy meals found.</p>
              <p className="text-xs text-brand-light/70 mt-1">Try searching for simple items like "khichdi" or "upma".</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// ==========================================
// 2. SAVED FAVORITES SCREEN
// ==========================================
export const FavoritesScreen: React.FC = () => {
  const { favorites, toggleFavorite, setSelectedMeal, navigateTo } = useApp();

  // Filter actual favorite meals
  const favMeals = MEALS.filter(m => favorites.includes(m.id));

  const handleMealClick = (meal: Meal) => {
    setSelectedMeal(meal);
    navigateTo('meal-detail');
  };

  return (
    <div id="favorites-view" className="pb-24 bg-brand-cream min-h-screen">
      <div className="p-4 bg-white shadow-sm border-b border-gray-100 max-w-2xl mx-auto sticky top-0 z-30 flex justify-between items-center">
        <h2 className="text-sm font-extrabold text-brand-green-dark uppercase tracking-wider">Your Saved Favorites</h2>
        <span className="text-xs font-bold text-brand-green-dark bg-brand-green-light px-2.5 py-0.5 rounded-full">{favMeals.length} saved</span>
      </div>

      <div className="max-w-2xl mx-auto px-4 mt-6">
        {favMeals.length === 0 ? (
          /* Empty State */
          <div className="text-center py-16 px-6">
            <div className="w-24 h-24 bg-brand-green-light/40 rounded-full flex items-center justify-center mx-auto mb-6 border border-brand-green-medium/10">
              <Heart className="w-10 h-10 text-brand-green-dark opacity-40 fill-transparent" />
            </div>
            <h3 className="text-lg font-black text-brand-green-dark tracking-tight">No Saved Favorites</h3>
            <p className="text-xs text-brand-light mt-1.5 max-w-xs mx-auto leading-relaxed">
              Tap the heart icon on any meal card to build a custom shortlist of your favorite recovery foods.
            </p>
            <button 
              onClick={() => navigateTo('home')}
              className="mt-6 bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-bold text-xs px-5 py-3.5 rounded-xl shadow cursor-pointer"
            >
              Browse Healing Plates
            </button>
          </div>
        ) : (
          /* Favorites Grid */
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {favMeals.map(meal => (
              <div 
                key={meal.id}
                onClick={() => handleMealClick(meal)}
                className="bg-white rounded-3xl overflow-hidden border border-brand-green-light/20 shadow-sm hover:shadow-md transition cursor-pointer relative"
              >
                <img src={meal.image} alt={meal.name} className="w-full h-36 object-cover" />
                
                {/* Remove heart */}
                <button 
                  onClick={(e) => {
                    e.stopPropagation();
                    toggleFavorite(meal.id);
                  }}
                  className="absolute top-2.5 right-2.5 bg-white p-1.5 rounded-full shadow"
                >
                  <Heart className="w-4 h-4 fill-brand-error text-brand-error" />
                </button>

                <div className="p-3">
                  <h4 className="text-xs font-bold text-brand-dark truncate">{meal.name}</h4>
                  <div className="flex justify-between items-center mt-2.5">
                    <span className="text-xs font-extrabold text-brand-green-dark">₹{meal.price}</span>
                    <span className="text-[10px] text-brand-orange font-bold flex items-center gap-0.5">
                      <Star className="w-3 h-3 fill-brand-orange" /> {meal.rating}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

// ==========================================
// 3. SPECIAL DISCOUNTS & OFFERS
// ==========================================
export const OffersScreen: React.FC = () => {
  const { applyCoupon, navigateTo } = useApp();
  const [successCode, setSuccessCode] = useState<string | null>(null);

  const handleCopyCode = (code: string) => {
    applyCoupon(code);
    setSuccessCode(code);
    setTimeout(() => setSuccessCode(null), 3000);
    navigateTo('cart');
  };

  return (
    <div id="offers-view" className="pb-24 bg-brand-cream min-h-screen">
      <div className="p-4 bg-white shadow-sm border-b border-gray-100 max-w-2xl mx-auto sticky top-0 z-30">
        <h2 className="text-sm font-extrabold text-brand-green-dark uppercase tracking-wider">Nutritional Coupons</h2>
      </div>

      <div className="max-w-2xl mx-auto px-4 mt-6 space-y-4">
        {OFFERS.map(offer => (
          <div 
            key={offer.id}
            className="bg-white rounded-3xl p-5 border border-brand-green-light/35 shadow-sm relative overflow-hidden flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4"
          >
            {/* Design accents */}
            <div className="absolute top-0 right-0 w-16 h-16 bg-brand-green-light rounded-bl-full opacity-40" />

            <div className="space-y-1.5 max-w-md">
              <span className="text-[10px] uppercase font-bold text-brand-orange tracking-widest block">Get Well Soon Discount</span>
              <h3 className="text-base font-black text-brand-green-dark leading-tight">{offer.title}</h3>
              <p className="text-xs text-brand-light leading-relaxed">{offer.description}</p>
              <span className="inline-block text-[10px] font-bold text-brand-green-medium">
                ✓ Valid on all menu items of admitting hospital.
              </span>
            </div>

            <div className="w-full sm:w-auto flex flex-col items-stretch sm:items-end gap-2">
              <div className="bg-brand-cream border border-brand-green-medium/25 border-dashed rounded-xl px-4 py-2.5 text-center">
                <span className="text-xs font-black font-mono text-brand-green-dark tracking-wider">{offer.code}</span>
              </div>
              <button
                id={`apply-code-${offer.code}`}
                onClick={() => handleCopyCode(offer.code)}
                className="bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-bold text-[10px] py-2 px-4 rounded-xl shadow-sm transition uppercase tracking-wider cursor-pointer"
              >
                {successCode === offer.code ? 'Applied & Navigating! ✓' : 'Apply Code'}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// ==========================================
// 4. USER PROFILE & ORDER HISTORY
// ==========================================
export const ProfileScreen: React.FC = () => {
  const { orders, navigateTo, setActiveOrder } = useApp();
  const [installModalOpen, setInstallModalOpen] = useState(false);
  const [showAllOrders, setShowAllOrders] = useState(false);

  const visibleOrders = showAllOrders ? orders : orders.slice(0, 3);

  return (
    <div id="profile-view" className="pb-24 bg-brand-cream min-h-screen">
      <div className="p-4 bg-white shadow-sm border-b border-gray-100 max-w-2xl mx-auto sticky top-0 z-30">
        <h2 className="text-sm font-extrabold text-brand-green-dark uppercase tracking-wider">Your Orders</h2>
      </div>

      <div className="max-w-2xl mx-auto px-4 mt-6 space-y-6">

        {/* Order History */}
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-brand-green-light/25">
          <h3 className="text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-4 flex items-center justify-between">
            <span className="flex items-center gap-1.5">
              <ClipboardList className="w-4.5 h-4.5 text-brand-green-medium" /> Order History
            </span>
            <span className="text-[10px] text-brand-light font-bold bg-brand-cream px-2 py-0.5 rounded-full">
              {orders.length} Total
            </span>
          </h3>

          <div className="space-y-4">
            {orders.length > 0 ? (
              <>
                {visibleOrders.map(ord => (
                  <div 
                    key={ord.id}
                    onClick={() => {
                      setActiveOrder(ord);
                      navigateTo('tracking');
                    }}
                    className="p-4 rounded-2xl border border-gray-100 hover:border-brand-green-medium/20 shadow-inner bg-brand-cream/35 cursor-pointer hover:bg-brand-green-light/10 transition"
                  >
                    <div className="flex justify-between items-center mb-1">
                      <span className="text-xs font-black text-brand-dark font-mono">{ord.orderNumber}</span>
                      <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase ${
                        ord.status === 'Delivered' ? 'bg-emerald-100 text-emerald-800' :
                        ord.status === 'Out for Delivery' ? 'bg-blue-100 text-blue-800' :
                        'bg-amber-100 text-amber-800 animate-pulse'
                      }`}>
                        {ord.status}
                      </span>
                    </div>

                    <p className="text-[10px] text-brand-light">
                      {ord.items.length} dishes • Grand Total: <strong className="font-semibold text-brand-dark">₹{ord.grandTotal}</strong>
                    </p>
                    
                    <div className="flex flex-wrap gap-1 mt-2.5">
                      {ord.items.map((item, idx) => (
                        <span key={idx} className="text-[9px] bg-white border border-gray-200 text-brand-light px-1.5 py-0.5 rounded">
                          {item.quantity}x {item.meal.name}
                        </span>
                      ))}
                    </div>

                    <span className="text-[9px] text-brand-green-dark underline font-bold mt-2.5 block text-right">
                      Track bedside details →
                    </span>
                  </div>
                ))}

                {/* View More / Show Less Dropdown Button */}
                {orders.length > 3 && (
                  <button 
                    onClick={() => setShowAllOrders(prev => !prev)}
                    className="w-full mt-3 py-2.5 px-4 bg-brand-cream hover:bg-brand-green-light/20 border border-brand-green-light/30 rounded-2xl text-xs font-bold text-brand-green-dark transition flex items-center justify-center gap-1.5 cursor-pointer"
                  >
                    <span>{showAllOrders ? 'Show Less Orders' : `View More Orders (${orders.length - 3} more)`}</span>
                    {showAllOrders ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                  </button>
                )}
              </>
            ) : (
              <p className="text-xs text-brand-light italic text-center py-4">No nutritional meals ordered yet.</p>
            )}
          </div>
        </div>

        {/* Supporting tiles */}
        <div className="bg-white rounded-3xl p-3 border border-brand-green-light/20 shadow-sm divide-y divide-gray-100">
          <div 
            onClick={() => navigateTo('settings')}
            className="flex justify-between items-center p-3 cursor-pointer hover:text-brand-green-dark transition"
          >
            <span className="text-xs font-semibold text-brand-dark">Settings & Account Details</span>
            <ChevronRight className="w-4 h-4 text-brand-light" />
          </div>
          <div 
            onClick={() => navigateTo('offers')}
            className="flex justify-between items-center p-3 cursor-pointer hover:text-brand-green-dark transition"
          >
            <span className="text-xs font-semibold text-brand-dark">Promo Coupons & Discounts</span>
            <ChevronRight className="w-4 h-4 text-brand-light" />
          </div>
          <div 
            onClick={() => navigateTo('favorites')}
            className="flex justify-between items-center p-3 cursor-pointer hover:text-brand-green-dark transition"
          >
            <span className="text-xs font-semibold text-brand-dark">Your Favorited Shortlists</span>
            <ChevronRight className="w-4 h-4 text-brand-light" />
          </div>
        </div>

      </div>

    </div>
  );
};

// ==========================================
// 5. SETTINGS SCREEN
// ==========================================
export const SettingsScreen: React.FC = () => {
  const { 
    goBack, 
    notificationsEnabled, 
    setNotificationsEnabled, 
    language, 
    setLanguage,
    t,
    navigateTo,
    user,
    selectedHospital,
    logout
  } = useApp();

  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [passwordInput, setPasswordInput] = useState('');
  const [passwordError, setPasswordError] = useState('');

  const handleAdminVerify = (e: React.FormEvent) => {
    e.preventDefault();
    if (passwordInput === 'curaadmin') {
      setPasswordError('');
      setShowPasswordModal(false);
      setPasswordInput('');
      navigateTo('admin');
    } else {
      setPasswordError('Incorrect password! Please try again.');
    }
  };

  const userName = user?.role === 'Patient' 
    ? user.patientDetails?.patientName 
    : user?.employeeDetails?.employeeName;

  const userPhone = user?.phone || 'Guest Recipient';

  return (
    <div id="settings-view" className="pb-24 bg-brand-cream min-h-screen">
      <div className="max-w-2xl mx-auto px-4 pt-6 space-y-6">

        {/* User Profile Info Card */}
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-brand-green-light/25 space-y-4">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-brand-green-light flex items-center justify-center text-brand-green-dark font-bold border border-brand-green-medium/10">
              <User className="w-6 h-6 text-brand-green-dark" />
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="text-sm font-extrabold text-brand-dark truncate leading-tight">
                {userName || 'Guest Recipient'}
              </h3>
              <p className="text-[11px] text-brand-light mt-1 font-semibold">{userPhone === 'Guest' ? 'Guest Access' : userPhone}</p>
            </div>
          </div>

          {user?.role === 'Patient' && user.patientDetails ? (
            <div className="text-[11px] text-brand-light space-y-1.5 bg-brand-cream/60 p-3.5 rounded-2xl border border-gray-100">
              <p>🏨 <strong>Hospital Unit:</strong> {selectedHospital?.name || 'Bhatkal General Hospital'}</p>
              <p>🛌 <strong>Ward & Floor:</strong> {user.patientDetails.ward}</p>
              <p>🔑 <strong>Room & Bed No:</strong> Room {user.patientDetails.roomNumber}</p>
              <p>🩺 <strong>Dietary Category:</strong> {user.patientDetails.diagnosis}</p>
              {user.patientDetails.notes && (
                <p>📝 <strong>Kitchen Notes:</strong> "{user.patientDetails.notes}"</p>
              )}
            </div>
          ) : user?.role === 'Employee' && user.employeeDetails ? (
            <div className="text-[11px] text-brand-light space-y-1.5 bg-brand-cream/60 p-3.5 rounded-2xl border border-gray-100">
              <p>🏨 <strong>Hospital Unit:</strong> {selectedHospital?.name || 'Bhatkal General Hospital'}</p>
              <p>🩺 <strong>Department:</strong> {user.employeeDetails.department}</p>
              <p>🔑 <strong>Staff ID No:</strong> {user.employeeDetails.employeeId}</p>
            </div>
          ) : (
            <div className="bg-brand-orange/5 border border-brand-orange/15 rounded-2xl p-3.5 flex flex-col gap-2">
              <p className="text-[11px] text-brand-light leading-relaxed">
                You are currently using the app with a temporary guest profile. To unlock tailored clinical nutrition:
              </p>
              <button
                onClick={() => navigateTo('login')}
                className="self-start text-[10px] font-extrabold text-brand-orange hover:underline uppercase tracking-wider"
              >
                Register Bedside Profile &rarr;
              </button>
            </div>
          )}
        </div>
        
        {/* Care Pack Feature in Settings */}
        <div 
          onClick={() => navigateTo('care-pack')}
          className="bg-gradient-to-r from-amber-500 to-brand-orange text-white rounded-3xl p-5 shadow-md border border-amber-300/40 cursor-pointer hover:opacity-95 transition flex items-center justify-between gap-3"
        >
          <div className="space-y-1">
            <span className="text-[10px] font-black uppercase tracking-wider bg-white/20 px-2.5 py-0.5 rounded-full inline-block">
              Hospital Support
            </span>
            <h3 className="font-display text-sm font-black flex items-center gap-1.5">
              <span>🎁 Send a Care Pack to Ward</span>
            </h3>
            <p className="text-[11px] text-amber-50 leading-tight">
              Send personalized health packs, fresh juices, and essential care items directly to a patient's room bed.
            </p>
          </div>
          <ChevronRight className="w-5 h-5 flex-shrink-0 text-white" />
        </div>

        {/* More Hub Link in Settings */}
        <div 
          onClick={() => navigateTo('more')}
          className="bg-brand-green-dark text-white rounded-3xl p-5 shadow-md border border-brand-green-medium/40 cursor-pointer hover:opacity-95 transition flex items-center justify-between gap-3"
        >
          <div className="space-y-1">
            <span className="text-[10px] font-black uppercase tracking-wider bg-white/20 text-emerald-100 px-2.5 py-0.5 rounded-full inline-block">
              Coastal Services
            </span>
            <h3 className="font-display text-sm font-black">
              🏨 More: Resorts, Cars, Mangalore OPD &amp; Taxis
            </h3>
            <p className="text-[11px] text-emerald-100/90 leading-tight">
              Explore local resort rentals, rental cars, Mangalore hospital bookings, and 24/7 taxi rides.
            </p>
          </div>
          <ChevronRight className="w-5 h-5 flex-shrink-0 text-white" />
        </div>

        {/* Notifications config */}
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-brand-green-light/25 space-y-4">
          <h3 className="text-xs font-bold text-brand-green-dark uppercase tracking-wider flex items-center gap-1.5">
            <Bell className="w-4 h-4" /> {t('Push Notifications')}
          </h3>
          <div className="flex justify-between items-center">
            <div>
              <p className="text-xs font-bold text-brand-dark">{t('Admitted status alarms')}</p>
              <p className="text-[10px] text-brand-light">{t('Pings when sterile container leaves kitchen.')}</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer select-none">
              <input 
                type="checkbox" 
                checked={notificationsEnabled}
                onChange={(e) => setNotificationsEnabled(e.target.checked)}
                className="sr-only peer" 
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-brand-green-dark" />
            </label>
          </div>
        </div>

        {/* Language select */}
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-brand-green-light/25 space-y-4">
          <h3 className="text-xs font-bold text-brand-green-dark uppercase tracking-wider flex items-center gap-1.5">
            <Globe className="w-4 h-4" /> {t('Language Settings')}
          </h3>
          <div className="grid grid-cols-3 gap-2">
            {(['English', 'Kannada', 'Urdu'] as const).map(lang => (
              <button
                key={lang}
                onClick={() => setLanguage(lang)}
                className={`py-2.5 rounded-xl text-xs font-bold border transition text-center cursor-pointer ${
                  language === lang 
                    ? 'bg-brand-green-dark text-white border-brand-green-dark shadow-sm' 
                    : 'bg-brand-cream text-brand-dark border-gray-100 hover:bg-brand-green-light/25'
                }`}
              >
                {lang}
              </button>
            ))}
          </div>
          <p className="text-[10px] text-brand-light">{t('Bhatkal healthcare units support English, local Kannada, and Urdu diets.')}</p>
        </div>

        {/* Legals / General info lists */}
        <div className="bg-white rounded-3xl p-5 border border-brand-green-light/25 shadow-sm space-y-4">
          <h3 className="text-xs font-bold text-brand-green-dark uppercase tracking-wider">{t('Compliance & Health Information')}</h3>
          
          <div className="space-y-3.5 text-xs text-brand-light">
            <div className="flex items-start gap-2">
              <Shield className="w-4 h-4 text-brand-green-dark mt-0.5 flex-shrink-0" />
              <div>
                <p className="font-bold text-brand-dark">{t('Sterilized Kitchen Security')}</p>
                <p className="text-[10px] leading-relaxed mt-0.5">Cura Meal operates in high-efficiency hospital zones. Delivery staff undergo double temperature checks.</p>
              </div>
            </div>

            <div className="flex items-start gap-2">
              <FileText className="w-4 h-4 text-brand-green-dark mt-0.5 flex-shrink-0" />
              <div>
                <p className="font-bold text-brand-dark">{t('Guest Terms & Privacy')}</p>
                <p className="text-[10px] leading-relaxed mt-0.5">We maintain strict adherence to hospital privacy rules. Bedside coordinates are wiped from records upon delivery confirmation.</p>
              </div>
            </div>

            <div className="flex items-start gap-2">
              <HelpCircle className="w-4 h-4 text-brand-green-dark mt-0.5 flex-shrink-0" />
              <div>
                <p className="font-bold text-brand-dark">{t('Dial Bedside Emergency Help')}</p>
                <p className="text-[10px] leading-relaxed mt-0.5">If you face severe food intolerance or need urgent medical attention, please inform your ward nurse or ring the bedside assistance alarm immediately.</p>
              </div>
            </div>
          </div>
        </div>

        {/* Admin Portal Gateway */}
        <div className="bg-slate-800 text-slate-100 rounded-3xl p-5 shadow-lg border border-slate-700/80 space-y-3.5">
          <div className="flex items-center gap-2">
            <Shield className="w-5 h-5 text-amber-500" />
            <h3 className="text-xs font-black uppercase tracking-wider text-slate-200">{t('Management & Admin Portal')}</h3>
          </div>
          <p className="text-[11px] text-slate-400 leading-normal">
            Secure clinical kitchen control panel. View placed orders, check guest bed allocations, and accept/dispatch nourishment containers.
          </p>
          <button
            onClick={() => {
              setShowPasswordModal(true);
              setPasswordInput('');
              setPasswordError('');
            }}
            className="w-full bg-amber-500 hover:bg-amber-400 text-slate-950 font-black text-xs py-3.5 rounded-xl transition uppercase tracking-wider shadow cursor-pointer flex items-center justify-center gap-1.5 animate-pulse"
          >
            <span>{t('Open Admin Setup')} &rarr;</span>
          </button>
        </div>

        {/* Sign Out Action Button */}
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-red-100 flex items-center justify-between gap-4">
          <div>
            <h3 className="text-xs font-extrabold text-brand-dark uppercase tracking-wider">{t('Account Access')}</h3>
            <p className="text-[10px] text-brand-light mt-0.5">{t('Sign out of your active bedside session on this device.')}</p>
          </div>
          <button
            onClick={() => {
              logout();
              navigateTo('home');
            }}
            className="bg-red-50 hover:bg-red-100 text-brand-error font-extrabold text-xs px-4 py-3 rounded-xl transition cursor-pointer flex items-center gap-1.5 flex-shrink-0"
          >
            <LogOut className="w-4 h-4" />
            <span>{t('Sign Out')}</span>
          </button>
        </div>

      </div>

      {showPasswordModal && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-3xl p-6 max-w-sm w-full shadow-2xl border border-gray-100 animate-fade-in text-brand-dark">
            <h3 className="text-sm font-extrabold text-brand-green-dark uppercase tracking-wider mb-2 flex items-center gap-2">
              🔐 Admin Verification
            </h3>
            <p className="text-xs text-brand-light leading-relaxed mb-4">
              Please enter the security password to open the Hospital Admin Portal.
            </p>
            <form onSubmit={handleAdminVerify} className="space-y-4">
              <input
                type="password"
                placeholder="Enter Password"
                value={passwordInput}
                onChange={(e) => setPasswordInput(e.target.value)}
                autoFocus
                className="w-full p-3.5 bg-brand-cream rounded-xl text-xs font-semibold focus:bg-white focus:ring-2 focus:ring-brand-green-light focus:border-transparent transition"
              />
              {passwordError && (
                <p className="text-[10px] text-brand-error font-bold">{passwordError}</p>
              )}
              <div className="flex gap-2 justify-end pt-2">
                <button
                  type="button"
                  onClick={() => setShowPasswordModal(false)}
                  className="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-brand-light text-xs font-bold rounded-lg transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-brand-green-dark hover:bg-brand-green-dark/90 text-white text-xs font-bold rounded-lg transition"
                >
                  Verify
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
