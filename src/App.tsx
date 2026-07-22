import React, { useState, useEffect } from 'react';
import { AppProvider, useApp, ScreenType } from './context/AppContext';
import { SplashOnboardingLogin } from './screens/SplashOnboardingLogin';
import { HospitalSelectionFlow } from './screens/HospitalSelectionFlow';
import { HomeScreen } from './screens/HomeScreen';
import { MealDetailCustomization } from './screens/MealDetailCustomization';
import { CartCheckoutSuccessTracking } from './screens/CartCheckoutSuccessTracking';
import { SearchScreen, FavoritesScreen, OffersScreen, ProfileScreen, SettingsScreen } from './screens/TabsScreens';
import { SendCarePackScreen } from './screens/SendCarePackScreen';
import { MoreScreen } from './screens/MoreScreen';
import { AdminScreen } from './screens/AdminScreen';
import { 
  Home, Search, Heart, User, ShoppingBag, Bell, Leaf, 
  MapPin, CheckCircle, Tag, Settings, ArrowRight, X, Clock, Smartphone, LayoutGrid 
} from 'lucide-react';
import { InstallGuideModal } from './components/InstallGuideModal';
import { SendCarePackModal } from './components/SendCarePackModal';

const AppContent: React.FC = () => {
  const { 
    screen, 
    setScreen, 
    navigateTo, 
    cartCount, 
    selectedHospital, 
    user,
    notifications,
    markNotificationsAsRead
  } = useApp();

  const [notifDropdownOpen, setNotifDropdownOpen] = useState(false);
  const [installModalOpen, setInstallModalOpen] = useState(false);
  const [carePackModalOpen, setCarePackModalOpen] = useState(false);

  // Auto-prompt install modal when user opens the web app in browser (unless already installed or standalone)
  useEffect(() => {
    const isStandalone = typeof window !== 'undefined' && (
      window.matchMedia('(display-mode: standalone)').matches || 
      (window.navigator as any).standalone === true
    );
    const isInstalled = localStorage.getItem('pwa_installed') === 'true';
    const isDismissed = localStorage.getItem('pwa_dismissed') === 'true';

    if (isStandalone || isInstalled || isDismissed) {
      return;
    }

    const hasPrompted = sessionStorage.getItem('pwa_install_prompt_shown');
    if (!hasPrompted) {
      const timer = setTimeout(() => {
        setInstallModalOpen(true);
        sessionStorage.setItem('pwa_install_prompt_shown', 'true');
      }, 1500);
      return () => clearTimeout(timer);
    }
  }, []);

  // Determine if we should show the persistent top bar and bottom nav
  const showMainLayout = [
    'home', 'search', 'favorites', 'profile', 'offers', 'settings', 'care-pack', 'more'
  ].includes(screen);

  // Unread notifications count
  const unreadNotifsCount = notifications.filter(n => !n.isRead).length;

  const handleNotifClick = () => {
    setNotifDropdownOpen(!notifDropdownOpen);
    if (!notifDropdownOpen) {
      markNotificationsAsRead();
    }
  };

  return (
    <div className="min-h-screen bg-brand-cream text-brand-dark font-sans relative antialiased flex flex-col justify-between selection:bg-brand-green-light">
      
      {/* 1. TOP HEADER (Only for main tab screens) */}
      {showMainLayout && (
        <header className="sticky top-0 z-40 bg-white border-b border-brand-green-light/10 shadow-sm max-w-lg mx-auto w-full px-4 py-3 flex items-center justify-between">
          <div 
            onClick={() => navigateTo('home')}
            className="flex items-center gap-1.5 cursor-pointer group"
          >
            <div className="w-8 h-8 rounded-full overflow-hidden flex items-center justify-center bg-white border border-brand-green-light/30 shadow-sm">
              <img src="/logo.png?v=5" className="w-full h-full object-contain" referrerPolicy="no-referrer" />
            </div>
            <span className="font-black text-brand-green-dark text-base tracking-tight">Cura Meal</span>
          </div>

          <div className="flex items-center gap-3 z-30 relative">
            
            {/* Notifications panel toggle */}
            <button 
              onClick={handleNotifClick}
              className="p-1.5 rounded-full hover:bg-brand-cream text-brand-green-dark transition relative"
              title="Notifications"
            >
              <Bell className="w-4.5 h-4.5" />
              {unreadNotifsCount > 0 && (
                <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-brand-orange rounded-full ring-2 ring-white animate-pulse" />
              )}
            </button>

            {/* Cart Shortcut */}
            <button 
              onClick={() => navigateTo('cart')}
              className="p-1.5 rounded-full hover:bg-brand-cream text-brand-green-dark transition relative"
              title="Your Cart"
            >
              <ShoppingBag className="w-4.5 h-4.5" />
              {cartCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-brand-orange text-white text-[10px] font-black w-4.5 h-4.5 rounded-full flex items-center justify-center border border-white">
                  {cartCount}
                </span>
              )}
            </button>
          </div>

          {/* Notifications Dropdown Drawer */}
          {notifDropdownOpen && (
            <div className="absolute top-14 right-4 w-72 bg-white rounded-2xl shadow-xl border border-brand-green-light/20 p-4 z-50 animate-fade-in space-y-3">
              <div className="flex justify-between items-center border-b border-gray-50 pb-2">
                <h4 className="text-xs font-extrabold text-brand-green-dark uppercase tracking-wider flex items-center gap-1">
                  📢 Hospital Feeds
                </h4>
                <button onClick={() => setNotifDropdownOpen(false)}>
                  <X className="w-4 h-4 text-brand-light hover:text-brand-dark" />
                </button>
              </div>

              <div className="space-y-3 max-h-60 overflow-y-auto no-scrollbar">
                {notifications.map((notif) => (
                  <div key={notif.id} className="text-left bg-brand-cream/35 p-2.5 rounded-xl border border-gray-100">
                    <h5 className="text-xs font-bold text-brand-dark leading-snug">{notif.title}</h5>
                    <p className="text-[10px] text-brand-light leading-relaxed mt-0.5">{notif.message}</p>
                    <span className="text-[9px] text-brand-light/70 mt-1 block font-mono">{notif.time}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </header>
      )}

      {/* Care Pack Action Bar - Only on Home Page */}
      {showMainLayout && screen === 'home' && (
        <div 
          onClick={() => setScreen('care-pack')}
          className="bg-gradient-to-r from-brand-orange to-amber-500 text-white text-center py-2.5 px-4 flex items-center justify-center gap-2 font-black text-[11px] uppercase tracking-wider cursor-pointer hover:opacity-95 transition-all duration-200 shadow-md max-w-lg mx-auto w-full z-30 sticky top-[53px] border-b border-white/10"
        >
          <Heart className="w-4 h-4 fill-white animate-pulse text-white flex-shrink-0" />
          <span>Send a Care Pack to a Loved One in the Hospital</span>
          <ArrowRight className="w-3.5 h-3.5 ml-1" />
        </div>
      )}

      {/* 2. ROUTE SCREEN ORCHESTRATION */}
      <main className="flex-1 w-full max-w-lg mx-auto bg-brand-cream relative">
        {(() => {
          switch (screen) {
            case 'splash':
            case 'onboarding':
            case 'login':
              return <SplashOnboardingLogin />;
            
            case 'select-hospital':
            case 'patient-flow':
            case 'employee-flow':
              return <HospitalSelectionFlow />;
            
            case 'home':
              return <HomeScreen />;
            
            case 'meal-detail':
            case 'customization':
              return <MealDetailCustomization />;
            
            case 'cart':
            case 'checkout':
            case 'success':
            case 'tracking':
              return <CartCheckoutSuccessTracking />;
            
            case 'search':
              return <SearchScreen />;
            
            case 'favorites':
              return <FavoritesScreen />;
            
            case 'offers':
              return <OffersScreen />;
            
            case 'profile':
              return <ProfileScreen />;
            
            case 'care-pack':
              return <SendCarePackScreen />;
            
            case 'more':
              return <MoreScreen />;
            
            case 'settings':
              return <SettingsScreen />;
            
            case 'admin':
              return <AdminScreen />;
            
            default:
              return <HomeScreen />;
          }
        })()}
      </main>

      {/* 3. PERSISTENT BOTTOM NAVIGATION (Only for main feed tabs) */}
      {showMainLayout && (
        <nav className="fixed bottom-0 inset-x-0 bg-white/95 backdrop-blur-md border-t border-brand-green-light/10 p-2 shadow-xl z-40 max-w-lg mx-auto rounded-t-3xl flex justify-around items-center">
          {/* Home tab */}
          <button 
            id="nav-home-tab"
            onClick={() => setScreen('home')}
            className={`flex flex-col items-center py-1.5 px-3 rounded-2xl transition cursor-pointer ${
              screen === 'home' ? 'text-brand-green-dark scale-105' : 'text-brand-light/70 hover:text-brand-green-dark'
            }`}
          >
            <Home className="w-5 h-5" />
            <span className="text-[10px] font-bold mt-1">Home</span>
          </button>

          {/* Search tab */}
          <button 
            id="nav-search-tab"
            onClick={() => setScreen('search')}
            className={`flex flex-col items-center py-1.5 px-3 rounded-2xl transition cursor-pointer ${
              screen === 'search' ? 'text-brand-green-dark scale-105' : 'text-brand-light/70 hover:text-brand-green-dark'
            }`}
          >
            <Search className="w-5 h-5" />
            <span className="text-[10px] font-bold mt-1">Search</span>
          </button>

          {/* More Services tab (In Middle) */}
          <button 
            id="nav-more-tab"
            onClick={() => setScreen('more')}
            className={`flex flex-col items-center py-1.5 px-3 rounded-2xl transition cursor-pointer ${
              screen === 'more' ? 'text-brand-green-dark scale-105 font-black' : 'text-brand-light/70 hover:text-brand-green-dark'
            }`}
          >
            <LayoutGrid className="w-5 h-5" />
            <span className="text-[10px] font-bold mt-1">More</span>
          </button>

          {/* Orders / Progress tracking tab */}
          <button 
            id="nav-orders-tab"
            onClick={() => {
              setScreen('profile');
              // triggers scroll/focus on history
            }}
            className={`flex flex-col items-center py-1.5 px-3 rounded-2xl transition cursor-pointer ${
              screen === 'profile' ? 'text-brand-green-dark scale-105' : 'text-brand-light/70 hover:text-brand-green-dark'
            }`}
          >
            <ShoppingBag className="w-5 h-5 animate-pulse" />
            <span className="text-[10px] font-bold mt-1">Orders</span>
          </button>

          {/* Profile settings tab */}
          <button 
            id="nav-settings-tab"
            onClick={() => setScreen('settings')}
            className={`flex flex-col items-center py-1.5 px-3 rounded-2xl transition cursor-pointer ${
              screen === 'settings' ? 'text-brand-green-dark scale-105' : 'text-brand-light/70 hover:text-brand-green-dark'
            }`}
          >
            <Settings className="w-5 h-5" />
            <span className="text-[10px] font-bold mt-1">Settings</span>
          </button>
        </nav>
      )}

      {/* 4. MOBILE APP INSTALL OVERLAY */}
      <InstallGuideModal isOpen={installModalOpen} onClose={() => setInstallModalOpen(false)} />

      {/* 5. CARE PACK DIALOG FLOW */}
      <SendCarePackModal isOpen={carePackModalOpen} onClose={() => setCarePackModalOpen(false)} />

    </div>
  );
};

export default function App() {
  return (
    <AppProvider>
      <AppContent />
    </AppProvider>
  );
}
