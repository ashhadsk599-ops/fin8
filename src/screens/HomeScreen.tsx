import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { MEALS, OFFERS } from '../data';
import { Meal, MealCategory } from '../types';
import { 
  Search, Star, Clock, Flame, Dumbbell, ChevronRight, Compass,
  CheckCircle, Plus, Eye, Heart, ShieldAlert, BadgeInfo, Smartphone, X, MapPin, Package
} from 'lucide-react';
import { handleImageError } from '../utils/localImages';

export const HomeScreen: React.FC = () => {
  const { 
    user, 
    selectedHospital, 
    navigateTo, 
    setSelectedMeal, 
    setCustomizingMeal,
    addToCart,
    toggleFavorite, 
    isFavorite,
    userLiveLocation,
    fetchLiveLocation,
    isLoadingLocation
  } = useApp();

  const [activeCategory, setActiveCategory] = useState<MealCategory | 'All'>('Breakfast');
  const [selectedRoleMenu, setSelectedRoleMenu] = useState<'All' | 'Light & Healing' | 'High Energy' | 'For the Family' | 'Bedside Essentials'>('All');
  const [addedMealId, setAddedMealId] = useState<string | null>(null);
  const [installModalOpen, setInstallModalOpen] = useState(false);

  // Carousel State & auto-scroll interval hook (3 seconds)
  const [carouselIndex, setCarouselIndex] = useState(0);
  const carouselMeals = MEALS.filter(m => ['bf-doc-veg', 'bf-doc-nonveg', 'lh-doc-veg', 'sp-chicken'].includes(m.id)).slice(0, 4);
  const finalCarouselMeals = carouselMeals.length === 4 ? carouselMeals : MEALS.slice(0, 4);

  useEffect(() => {
    const timer = setInterval(() => {
      setCarouselIndex((prev) => (prev + 1) % finalCarouselMeals.length);
    }, 3000);
    return () => clearInterval(timer);
  }, [finalCarouselMeals.length]);
  
  // Greeting name
  const userName = user?.role === 'Patient' 
    ? user.patientDetails?.patientName 
    : user?.employeeDetails?.employeeName;
  
  const greetingText = () => {
    const hr = new Date().getHours();
    if (hr < 12) return 'Good Morning ☀️';
    if (hr < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  };

  // Filtered meals based on Category Chip and Mapped Specialized Role Menus
  const filteredMeals = MEALS.filter(m => {
    if (selectedRoleMenu === 'Light & Healing') {
      if (m.category === 'Grocery') return false;
      const match = m.isDoctorRecommended || m.category === 'Soup' || (m.isVeg && m.category === 'Breakfast') || m.id === 'jc-coconut';
      if (!match) return false;
    } else if (selectedRoleMenu === 'High Energy') {
      if (m.category === 'Grocery') return false;
      const match = m.nutrition.protein >= 12 || !m.isVeg || m.id === 'bf-doc-nonveg' || m.id === 'lh-doc-nonveg' || m.id === 'sp-chicken' || m.id === 'sn-sprouts';
      if (!match) return false;
    } else if (selectedRoleMenu === 'For the Family') {
      if (m.category === 'Grocery') return false;
      const match = m.category === 'Lunch' || m.category === 'Snacks' || m.id === 'jc-watermelon' || m.id === 'jc-lime' || m.id === 'jc-orange';
      if (!match) return false;
    } else if (selectedRoleMenu === 'Bedside Essentials') {
      if (m.category !== 'Grocery') return false;
    } else {
      if (activeCategory !== 'Grocery' && m.category === 'Grocery') return false;
    }

    if (activeCategory !== 'All') {
      if (m.category !== activeCategory) return false;
    }

    return true;
  });

  const popularMeals = MEALS.filter(m => m.isPopular);
  const specialMeals = MEALS.filter(m => m.isHealthySpecial);

  const handleMealClick = (meal: Meal) => {
    setSelectedMeal(meal);
    navigateTo('meal-detail');
  };

  const handleAddClick = (e: React.MouseEvent, meal: Meal) => {
    e.stopPropagation();
    addToCart(meal, 1);
    setAddedMealId(meal.id);
    setTimeout(() => {
      setAddedMealId(prev => (prev === meal.id ? null : prev));
    }, 1500);
  };

  return (
    <div id="home-screen" className="pb-24 bg-brand-cream min-h-screen">
      {/* Top Banner Area & Hospital Header */}
      <div className="bg-gradient-to-b from-brand-green-light to-transparent px-4 pt-6 pb-2">
        <div className="flex justify-between items-center max-w-4xl mx-auto">
          <div>
            <span className="text-xs text-brand-green-dark font-bold bg-brand-green-medium/10 px-2.5 py-1 rounded-full">
              {greetingText()}
            </span>
            <h2 className="font-display text-2xl font-black text-brand-green-dark mt-2.5 tracking-tight leading-none">
              Hello, {userName || 'Admitted Guest'}!
            </h2>
            <p className="text-xs text-brand-light mt-1">
              What clean nutrition do you need today?
            </p>
          </div>
          
          {/* Active Live Location Indicator */}
          <div 
            onClick={fetchLiveLocation}
            className="text-right bg-white p-2.5 rounded-2xl border border-brand-green-light/40 shadow-sm cursor-pointer max-w-[180px] sm:max-w-[240px] transition hover:border-brand-green-medium hover:shadow-md relative overflow-hidden group select-none"
            title="Click to refresh live location"
          >
            <div className="flex items-center justify-end gap-1.5">
              <span className="relative flex h-2 w-2">
                <span className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${isLoadingLocation ? 'bg-brand-orange' : 'bg-brand-green-light'}`}></span>
                <span className={`relative inline-flex rounded-full h-2 w-2 ${isLoadingLocation ? 'bg-brand-orange' : 'bg-brand-green-light'}`}></span>
              </span>
              <p className="text-[10px] uppercase font-bold tracking-wider text-brand-orange leading-none flex items-center gap-1">
                <MapPin className="w-3 h-3 text-brand-orange inline" />
                {isLoadingLocation ? 'Locating...' : 'Your Location'}
              </p>
            </div>
            <h4 className={`text-xs font-bold text-brand-dark truncate mt-1 ${isLoadingLocation ? 'animate-pulse text-brand-light' : ''}`}>
              {userLiveLocation}
            </h4>
            <p className="text-[9px] text-brand-green-dark underline font-medium mt-0.5 group-hover:text-brand-green-medium transition-colors">
              Tap to refresh GPS
            </p>
          </div>
        </div>



      </div>

      <div className="max-w-4xl mx-auto px-4 mt-4 space-y-8">
        
        {/* Dishes Carousel of 4 items with 3 second interval */}
        <div 
          onClick={() => handleMealClick(finalCarouselMeals[carouselIndex])}
          className="relative bg-slate-950 rounded-3xl overflow-hidden border border-brand-green-light/35 shadow-md h-56 group cursor-pointer"
        >
          {/* Slide image */}
          <img 
            src={finalCarouselMeals[carouselIndex].image} 
            alt={finalCarouselMeals[carouselIndex].name} 
            onError={(e) => handleImageError(e, finalCarouselMeals[carouselIndex].image)}
            className="w-full h-full object-cover opacity-85 transition-all duration-700 ease-in-out transform hover:scale-105"
          />
          {/* Gradient Overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-slate-950/85 via-slate-950/20 to-transparent" />
          
          {/* Badge */}
          <div className="absolute top-4 left-4 bg-brand-orange text-white text-[9px] font-black uppercase px-2.5 py-1 rounded-full shadow-md">
            🔥 Featured Chef Recommendation
          </div>

          {/* Slide Content */}
          <div className="absolute bottom-4 left-4 right-4 text-white">
            <span className="text-[10px] text-brand-orange font-extrabold uppercase tracking-widest block mb-0.5">
              {finalCarouselMeals[carouselIndex].category} Special
            </span>
            <h3 className="text-base font-black text-white leading-tight tracking-tight drop-shadow-md">
              {finalCarouselMeals[carouselIndex].name}
            </h3>
            <div className="flex items-center gap-3.5 mt-2 text-xs font-semibold text-slate-200">
              <span className="bg-white/20 px-2 py-0.5 rounded-md font-mono text-white">₹{finalCarouselMeals[carouselIndex].price}</span>
              <span className="flex items-center gap-1">
                <Flame className="w-3.5 h-3.5 text-brand-orange fill-brand-orange/20" />
                {finalCarouselMeals[carouselIndex].calories} kcal
              </span>
              <span>•</span>
              <span>Protein: {finalCarouselMeals[carouselIndex].protein}g</span>
            </div>
          </div>

          {/* Dots Indicator */}
          <div className="absolute bottom-4 right-4 flex gap-1.5 z-10">
            {finalCarouselMeals.map((_, idx) => (
              <button
                key={idx}
                onClick={(e) => {
                  e.stopPropagation();
                  setCarouselIndex(idx);
                }}
                className={`w-2.5 h-2.5 rounded-full border border-white/50 transition-all ${carouselIndex === idx ? 'bg-white scale-125 font-bold' : 'bg-white/40'}`}
              />
            ))}
          </div>
        </div>

        {/* Categories Chips */}
        <div>
          <h3 className="text-base font-extrabold text-brand-green-dark tracking-tight mb-3">Dietary & Stay Essentials</h3>
          <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
            {['Breakfast', 'Soup', 'Lunch', 'Juice', 'Snacks', 'Grocery'].map((cat) => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat as MealCategory)}
                className={`px-4 py-2 rounded-full text-xs font-bold transition flex-shrink-0 cursor-pointer ${
                  activeCategory === cat 
                    ? 'bg-brand-green-dark text-white shadow-md' 
                    : 'bg-white text-brand-green-dark border border-brand-green-light/30 hover:bg-brand-green-light/20'
                }`}
              >
                {cat === 'Breakfast' 
                  ? '🥣 Breakfast' 
                  : cat === 'Soup' 
                    ? '🍵 Hot Soup' 
                    : cat === 'Lunch' 
                      ? '🍛 Lunch Plates' 
                      : cat === 'Juice' 
                        ? '🥤 Fresh Juices' 
                        : cat === 'Snacks'
                          ? '🍎 Light Snacks'
                          : '📦 Essentials'
                }
              </button>
            ))}
          </div>
        </div>

        {/* Today's Healthy Menu */}
        <div>
          <div className="flex justify-between items-center mb-3">
            <div>
              <h3 className="text-base font-black text-brand-green-dark tracking-tight leading-none">
                {activeCategory === 'Grocery' ? "Essentials Specials" : `${activeCategory} Specials`}
              </h3>
              <p className="text-[11px] text-brand-light mt-0.5">
                Sterilized kitchens, non-greasy, rich in macro-nutrients.
              </p>
            </div>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-2 md:grid-cols-3 gap-3">
            {filteredMeals.map((meal) => (
              <div 
                key={meal.id}
                id={`meal-card-${meal.id}`}
                onClick={() => handleMealClick(meal)}
                className="bg-white rounded-2xl overflow-hidden border border-brand-green-light/30 shadow-sm hover:shadow-md transition duration-300 group cursor-pointer flex flex-col justify-between"
              >
                {/* Image and badges */}
                <div className="relative h-28 sm:h-32 w-full overflow-hidden bg-gray-100">
                  <img 
                    src={meal.image} 
                    alt={meal.name}
                    onError={(e) => handleImageError(e, meal.image)}
                    className="w-full h-full object-cover group-hover:scale-105 transition duration-500"
                  />
                  
                  {/* Veg/Non-Veg tag */}
                  <div className="absolute top-2 left-2 bg-white/95 px-2 py-0.5 rounded-full shadow-sm flex items-center gap-1 border border-gray-100">
                    <span className={`w-2 h-2 rounded-full ${meal.isVeg ? 'bg-brand-green-dark' : 'bg-brand-error'}`} />
                    <span className="text-[9px] font-bold text-brand-dark uppercase tracking-wider">
                      {meal.isVeg ? 'Veg' : 'Non-Veg'}
                    </span>
                  </div>

                  {/* Favorite Heart Button */}
                  <button 
                    onClick={(e) => {
                      e.stopPropagation();
                      toggleFavorite(meal.id);
                    }}
                    className="absolute top-2 right-2 bg-white/90 hover:bg-white text-brand-light hover:text-brand-error p-1.5 rounded-full shadow-sm transition"
                  >
                    <Heart className={`w-3.5 h-3.5 transition ${isFavorite(meal.id) ? 'fill-brand-error text-brand-error' : ''}`} />
                  </button>

                  {/* Nutrition Summary Bar on Image bottom */}
                  <div className="absolute bottom-1.5 left-1.5 right-1.5 glass-effect py-1 px-2 rounded-lg flex justify-between items-center text-[10px]">
                    {meal.category === 'Grocery' || meal.category === 'Snacks' ? (
                      <>
                        <div className="flex items-center gap-1 font-semibold text-brand-orange text-[9px]">
                          <Package className="w-3 h-3 text-brand-orange" />
                          <span>{meal.category === 'Grocery' ? 'Essentials' : 'Light Snack'}</span>
                        </div>
                        <div className="flex items-center gap-0.5 text-brand-orange font-bold text-[9px]">
                          <Star className="w-2.5 h-2.5 fill-brand-orange" />
                          <span>{meal.rating}</span>
                        </div>
                      </>
                    ) : (
                      <>
                        <div className="flex items-center gap-0.5 font-bold text-brand-green-dark text-[9px]">
                          <Flame className="w-3 h-3 text-brand-orange fill-brand-orange/15" />
                          <span>{meal.calories} kcal</span>
                        </div>
                        <div className="flex items-center gap-0.5 font-bold text-brand-green-dark text-[9px]">
                          <Dumbbell className="w-3 h-3 text-brand-green-medium" />
                          <span>{meal.protein}g</span>
                        </div>
                        <div className="flex items-center gap-0.5 text-brand-orange font-bold text-[9px]">
                          <Star className="w-2.5 h-2.5 fill-brand-orange" />
                          <span>{meal.rating}</span>
                        </div>
                      </>
                    )}
                  </div>
                </div>

                {/* Info and Price */}
                <div className="p-3 flex-1 flex flex-col justify-between">
                  <div>
                    <h4 className="text-xs font-bold text-brand-dark group-hover:text-brand-green-dark transition leading-snug line-clamp-1">
                      {meal.name}
                    </h4>
                    <p className="text-[10px] text-brand-light mt-1 leading-snug line-clamp-2">
                      {meal.description}
                    </p>
                  </div>

                  <div className="flex justify-between items-center mt-2.5 pt-2 border-t border-gray-100">
                    <div className="flex flex-col">
                      <span className="text-[9px] text-brand-light font-medium uppercase tracking-wider leading-none">Price</span>
                      <span className="text-xs font-extrabold text-brand-green-dark mt-0.5">₹{meal.price}</span>
                    </div>

                    <div className="flex items-center gap-1">
                      <button 
                        id={`add-btn-${meal.id}`}
                        onClick={(e) => handleAddClick(e, meal)}
                        className={`font-bold text-[10px] px-3 py-1.5 rounded-lg shadow-sm transition flex items-center gap-0.5 cursor-pointer ${
                          addedMealId === meal.id 
                            ? 'bg-emerald-600 text-white scale-105' 
                            : 'bg-brand-green-dark hover:bg-brand-green-dark/90 text-white'
                        }`}
                      >
                        {addedMealId === meal.id ? (
                          <>✓ Added</>
                        ) : (
                          <><Plus className="w-3 h-3" /> Add</>
                        )}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Section: Recommended & Healthy Specials */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-4">
          
          {/* Recommended list */}
          <div>
            <h3 className="text-base font-extrabold text-brand-green-dark tracking-tight mb-3">⭐ Bedside Favorites</h3>
            <div className="space-y-3">
              {popularMeals.slice(0, 3).map(meal => (
                <div 
                  key={meal.id} 
                  onClick={() => handleMealClick(meal)}
                  className="flex items-center gap-3 bg-white p-2.5 rounded-2xl border border-brand-green-light/20 shadow-sm hover:shadow-md transition cursor-pointer"
                >
                  <img src={meal.image} alt={meal.name} onError={(e) => handleImageError(e, meal.image)} className="w-14 h-14 rounded-xl object-cover flex-shrink-0" />
                  <div className="flex-1 min-w-0">
                    <h4 className="text-xs font-bold text-brand-dark truncate">{meal.name}</h4>
                    <div className="flex items-center gap-2 mt-1">
                      {meal.category !== 'Grocery' && meal.category !== 'Snacks' && (
                        <>
                          <span className="text-[10px] text-brand-green-dark font-medium">{meal.calories} kcal</span>
                          <span className="w-1 h-1 bg-gray-300 rounded-full" />
                        </>
                      )}
                      <span className="text-[10px] text-brand-orange font-bold flex items-center gap-0.5">
                        <Star className="w-2.5 h-2.5 fill-brand-orange" /> {meal.rating}
                      </span>
                    </div>
                  </div>
                  <button 
                    onClick={(e) => handleAddClick(e, meal)}
                    className="bg-brand-green-light hover:bg-brand-green-dark text-brand-green-dark hover:text-white p-1.5 rounded-lg transition"
                  >
                    <Plus className="w-3.5 h-3.5" />
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Clinically Designed specials */}
          <div>
            <h3 className="text-base font-extrabold text-brand-green-dark tracking-tight mb-3">🩺 Clinically Supervised</h3>
            <div className="space-y-3">
              {specialMeals.slice(0, 3).map(meal => (
                <div 
                  key={meal.id} 
                  onClick={() => handleMealClick(meal)}
                  className="flex items-center gap-3 bg-white p-2.5 rounded-2xl border border-brand-green-light/20 shadow-sm hover:shadow-md transition cursor-pointer"
                >
                  <img src={meal.image} alt={meal.name} onError={(e) => handleImageError(e, meal.image)} className="w-14 h-14 rounded-xl object-cover flex-shrink-0" />
                  <div className="flex-1 min-w-0">
                    <h4 className="text-xs font-bold text-brand-dark truncate">{meal.name}</h4>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-[10px] text-brand-green-dark font-medium">Protein: {meal.protein}g</span>
                      <span className="w-1 h-1 bg-gray-300 rounded-full" />
                      <span className="text-[10px] bg-brand-orange/10 text-brand-orange font-bold px-1.5 py-0.2 rounded">
                        Special
                      </span>
                    </div>
                  </div>
                  <button 
                    onClick={(e) => handleAddClick(e, meal)}
                    className="bg-brand-green-light hover:bg-brand-green-dark text-brand-green-dark hover:text-white p-1.5 rounded-lg transition"
                  >
                    <Plus className="w-3.5 h-3.5" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Safe Recover Disclaimer */}
        <div className="bg-amber-50 rounded-2xl p-4 border border-amber-200/50 flex gap-3 text-brand-dark">
          <BadgeInfo className="w-5 h-5 text-brand-orange flex-shrink-0 mt-0.5" />
          <p className="font-sans text-xs leading-relaxed text-amber-950 font-medium">
            <strong className="text-xs uppercase font-extrabold text-brand-orange block mb-0.5">Dietary Safety Note:</strong>
            Our menu matches standard postoperative and general ward regulations. If you are restricted by absolute liquids or clear diabetic programs, please customize your preferences or note them down.
          </p>
        </div>

        {/* Offers Carousel */}
        <div>
          <div className="flex justify-between items-center mb-3">
            <h3 className="text-base font-extrabold text-brand-green-dark tracking-tight">Healthy Offers & Coupons</h3>
            <button 
              onClick={() => navigateTo('offers')}
              className="text-xs font-bold text-brand-orange hover:underline cursor-pointer flex items-center gap-0.5"
            >
              See all <ChevronRight className="w-3 h-3" />
            </button>
          </div>

          <div className="flex gap-4 overflow-x-auto no-scrollbar pb-2">
            {OFFERS.map(offer => (
              <div 
                key={offer.id}
                onClick={() => navigateTo('offers')}
                className="flex-shrink-0 w-72 bg-gradient-to-br from-brand-green-dark to-brand-green-medium text-white rounded-2xl p-4 shadow-md border border-brand-green-light/20 relative overflow-hidden cursor-pointer hover:shadow-lg transition"
              >
                <div className="absolute -right-6 -bottom-6 w-20 h-20 bg-white/5 rounded-full" />
                <span className="bg-brand-orange text-white text-[10px] font-extrabold px-2.5 py-0.5 rounded-full uppercase tracking-wider">
                  {offer.code}
                </span>
                <h4 className="font-bold text-sm text-brand-cream mt-2">{offer.title}</h4>
                <p className="text-xs text-brand-cream/80 mt-1 leading-normal truncate">{offer.description}</p>
                <p className="text-[10px] text-white/60 mt-2">Min. order value ₹{offer.minOrderValue}</p>
              </div>
            ))}
          </div>
        </div>

      </div>

    </div>
  );
};
