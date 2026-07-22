import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { Meal, MealCustomization } from '../types';
import { 
  ArrowLeft, Heart, Star, Flame, Dumbbell, ShieldAlert,
  Apple, Plus, Minus, Sparkles, ShoppingBag 
} from 'lucide-react';
import { handleImageError } from '../utils/localImages';

export const MealDetailCustomization: React.FC = () => {
  const { 
    selectedMeal, 
    customizingMeal, 
    navigateTo, 
    goBack,
    addToCart, 
    toggleFavorite, 
    isFavorite,
  } = useApp();

  // Active meal state
  const meal = selectedMeal || customizingMeal;

  // Customization States
  const [extraRice, setExtraRice] = useState(false);
  const [extraCurry, setExtraCurry] = useState(false);
  const [saltPreference, setSaltPreference] = useState<'Normal' | 'No Salt' | 'Less Salt'>('Normal');
  const [spicePreference, setSpicePreference] = useState<'Normal' | 'Less Spice' | 'More Spice'>('Normal');
  const [noOnion, setNoOnion] = useState(false);
  const [noGarlic, setNoGarlic] = useState(false);
  const [specialInstructions, setSpecialInstructions] = useState('');
  const [quantity, setQuantity] = useState(1);

  // Reset states when meal changes
  useEffect(() => {
    if (meal) {
      setExtraRice(false);
      setExtraCurry(false);
      setSaltPreference('Normal');
      setSpicePreference('Normal');
      setNoOnion(false);
      setNoGarlic(false);
      setSpecialInstructions('');
      setQuantity(1);
    }
  }, [meal]);

  if (!meal) {
    return (
      <div className="p-8 text-center bg-brand-cream min-h-screen flex flex-col items-center justify-center">
        <ShieldAlert className="w-12 h-12 text-brand-orange mb-3" />
        <h3 className="text-lg font-bold text-brand-green-dark">No Meal Selected</h3>
        <button onClick={() => navigateTo('home')} className="mt-4 bg-brand-green-dark text-white px-4 py-2 rounded-xl text-xs font-bold cursor-pointer">
          Go back Home
        </button>
      </div>
    );
  }

  // Calculate customized price increment
  const extraRiceCost = extraRice ? 25 : 0;
  const extraCurryCost = extraCurry ? 30 : 0;
  
  const unitPrice = meal.price + extraRiceCost + extraCurryCost;
  const totalPrice = unitPrice * quantity;

  const handleAddToCart = () => {
    const cust: MealCustomization = {
      extraRice,
      extraCurry,
      saltPreference,
      spicePreference,
      noOnion,
      noGarlic,
      extraSalad: false,
      extraCurd: false,
      specialInstructions,
      addonEggBanana: false
    };
    addToCart(meal, quantity, cust);
    navigateTo('cart');
  };

  return (
    <div id="meal-detail-screen" className="bg-brand-cream min-h-screen pb-32">
      {/* Hero Image Banner with overlaid controls & small macro profile */}
      <div className="relative h-64 sm:h-80 w-full bg-gray-100">
        <img src={meal.image} alt={meal.name} onError={(e) => handleImageError(e, meal.image)} className="w-full h-full object-cover" />
        
        {/* Top Controls Overlay */}
        <div className="absolute top-4 inset-x-4 flex justify-between items-center z-10">
          <button 
            onClick={goBack}
            className="bg-white/90 backdrop-blur-md p-2.5 rounded-full shadow-md text-brand-dark hover:bg-white transition cursor-pointer"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <button 
            onClick={() => toggleFavorite(meal.id)}
            className="bg-white/90 backdrop-blur-md p-2.5 rounded-full shadow-md text-brand-dark hover:bg-white transition cursor-pointer"
          >
            <Heart className={`w-5 h-5 ${isFavorite(meal.id) ? 'fill-brand-error text-brand-error' : ''}`} />
          </button>
        </div>

        {/* Category Badge top left */}
        <div className="absolute top-4 left-16 bg-brand-green-dark/90 backdrop-blur-md text-white text-[10px] font-bold uppercase px-3 py-1 rounded-full shadow-md">
          {meal.category}
        </div>

        {/* Small Macro Nutritional Profile Badge inside Image at Bottom */}
        {meal.category !== 'Grocery' && meal.category !== 'Snacks' && (
          <div className="absolute bottom-3 inset-x-3 bg-black/60 backdrop-blur-md text-white p-2 rounded-2xl border border-white/20 shadow-lg flex items-center justify-between text-[10px] font-semibold">
            <div className="flex items-center gap-1 font-bold text-amber-300">
              <Flame className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
              <span>{meal.nutrition.calories} kcal</span>
            </div>
            <div className="flex items-center gap-1 text-emerald-300">
              <Dumbbell className="w-3.5 h-3.5" />
              <span>{meal.nutrition.protein}g Prot</span>
            </div>
            <div className="flex items-center gap-1 text-sky-300">
              <Apple className="w-3.5 h-3.5" />
              <span>{meal.nutrition.carbs}g Carbs</span>
            </div>
            <div className="flex items-center gap-1 text-orange-300">
              <Sparkles className="w-3.5 h-3.5" />
              <span>{meal.nutrition.fat}g Fat</span>
            </div>
          </div>
        )}
      </div>

      {/* Main Content & Brief Details */}
      <div className="max-w-2xl mx-auto px-4 mt-4 space-y-4">
        
        {/* Brief Meal Header Card */}
        <div className="bg-white rounded-3xl p-4 shadow-sm border border-brand-green-light/20">
          <div className="flex justify-between items-start gap-2">
            <div>
              <div className="flex items-center gap-1.5 mb-1">
                <span className={`w-2.5 h-2.5 rounded-full ${meal.isVeg ? 'bg-brand-green-dark' : 'bg-brand-error'}`} />
                <span className="text-[10px] font-bold uppercase tracking-wider text-brand-light">
                  {meal.isVeg ? 'Veg' : 'Non-Veg'}
                </span>
              </div>
              <h2 className="font-display text-xl font-black text-brand-green-dark tracking-tight leading-tight">{meal.name}</h2>
            </div>
            <div className="text-right flex-shrink-0">
              <span className="font-display text-lg font-black text-brand-green-dark block">₹{meal.price}</span>
              <div className="flex items-center gap-0.5 justify-end text-[10px] font-bold text-brand-orange mt-0.5">
                <Star className="w-3 h-3 fill-brand-orange" />
                <span>{meal.rating}</span>
              </div>
            </div>
          </div>

          <p className="font-editorial text-sm text-brand-dark leading-relaxed mt-2 pt-2 border-t border-gray-100">
            {meal.description}
          </p>
        </div>

        {/* Customization Options Box - Hidden for Grocery (Essentials) and Snacks */}
        {meal.category !== 'Grocery' && meal.category !== 'Snacks' && (
          <div className="bg-white rounded-3xl p-4 shadow-sm border border-brand-green-light/20 space-y-4">
            <h3 className="text-xs font-black text-brand-green-dark uppercase tracking-wider">
              ⚙️ Customization Options
            </h3>

            {/* Portion Add-ons for Lunch */}
            {meal.category === 'Lunch' && (
              <div>
                <h4 className="text-[11px] font-bold text-brand-green-dark uppercase tracking-wider mb-2">📦 Extra Portions</h4>
                <div className="space-y-2">
                  <label className="flex items-center justify-between p-2.5 bg-brand-cream rounded-xl border border-gray-100 hover:border-brand-green-medium/30 transition cursor-pointer select-none">
                    <div className="flex items-center gap-2">
                      <input 
                        type="checkbox" 
                        checked={extraRice}
                        onChange={(e) => setExtraRice(e.target.checked)}
                        className="w-4 h-4 rounded text-brand-green-dark focus:ring-brand-green-medium" 
                      />
                      <span className="text-xs font-bold text-brand-dark">Extra Basmati Rice portion</span>
                    </div>
                    <span className="text-xs font-bold text-brand-green-dark">+₹25</span>
                  </label>

                  <label className="flex items-center justify-between p-2.5 bg-brand-cream rounded-xl border border-gray-100 hover:border-brand-green-medium/30 transition cursor-pointer select-none">
                    <div className="flex items-center gap-2">
                      <input 
                        type="checkbox" 
                        checked={extraCurry}
                        onChange={(e) => setExtraCurry(e.target.checked)}
                        className="w-4 h-4 rounded text-brand-green-dark focus:ring-brand-green-medium" 
                      />
                      <span className="text-xs font-bold text-brand-dark">Extra Dal / Chicken Gravy portion</span>
                    </div>
                    <span className="text-xs font-bold text-brand-green-dark">+₹30</span>
                  </label>
                </div>
              </div>
            )}

            {/* Salt Preferences */}
            <div>
              <h4 className="text-[11px] font-bold text-brand-green-dark uppercase tracking-wider mb-2">🧂 Salt Preference</h4>
              <div className="grid grid-cols-3 gap-2">
                {(['No Salt', 'Less Salt', 'Normal'] as const).map((pref) => (
                  <button
                    key={pref}
                    type="button"
                    onClick={() => setSaltPreference(pref)}
                    className={`py-2 px-2 rounded-xl text-xs font-bold border transition text-center cursor-pointer ${
                      saltPreference === pref 
                        ? 'bg-brand-green-dark text-white border-brand-green-dark shadow-sm' 
                        : 'bg-brand-cream text-brand-dark border-gray-100 hover:bg-brand-green-light/25'
                    }`}
                  >
                    {pref}
                  </button>
                ))}
              </div>
            </div>

            {/* Spice Preferences */}
            <div>
              <h4 className="text-[11px] font-bold text-brand-green-dark uppercase tracking-wider mb-2">🌶️ Spice Preference</h4>
              <div className="grid grid-cols-3 gap-2">
                {(['Less Spice', 'Normal', 'More Spice'] as const).map((pref) => (
                  <button
                    key={pref}
                    type="button"
                    onClick={() => setSpicePreference(pref)}
                    className={`py-2 px-2 rounded-xl text-xs font-bold border transition text-center cursor-pointer ${
                      spicePreference === pref 
                        ? 'bg-brand-orange text-white border-brand-orange shadow-sm' 
                        : 'bg-brand-cream text-brand-dark border-gray-100 hover:bg-brand-orange/10'
                    }`}
                  >
                    {pref}
                  </button>
                ))}
              </div>
            </div>

            {/* Dietary / Nurse Instructions */}
            <div>
              <h4 className="text-[11px] font-bold text-brand-green-dark uppercase tracking-wider mb-1.5">✍️ Nurse / Special Instructions</h4>
              <textarea
                rows={2}
                maxLength={150}
                placeholder="e.g. Steam extra soft, pack warm..."
                value={specialInstructions}
                onChange={(e) => setSpecialInstructions(e.target.value)}
                className="block w-full border border-gray-100 rounded-2xl bg-brand-cream p-2.5 text-xs font-medium focus:bg-white focus:ring-2 focus:ring-brand-green-dark transition resize-none"
              />
            </div>

          </div>
        )}

      </div>

      {/* Bottom Sticky Bar for Quantity & Add to Food Tray */}
      <div className="fixed bottom-0 inset-x-0 bg-white border-t border-gray-100 p-3.5 shadow-2xl flex justify-between items-center max-w-lg mx-auto rounded-t-3xl z-40">
        <div>
          <span className="text-[9px] uppercase font-bold text-brand-light block mb-0.5">Quantity</span>
          <div className="flex items-center gap-2.5 bg-brand-green-light/40 border border-brand-green-medium/20 px-2.5 py-1 rounded-xl">
            <button 
              onClick={() => setQuantity(prev => Math.max(1, prev - 1))}
              className="p-1 rounded bg-white text-brand-green-dark shadow-xs cursor-pointer"
            >
              <Minus className="w-3.5 h-3.5" />
            </button>
            <span className="text-xs font-black text-brand-green-dark w-4 text-center">{quantity}</span>
            <button 
              onClick={() => setQuantity(prev => prev + 1)}
              className="p-1 rounded bg-white text-brand-green-dark shadow-xs cursor-pointer"
            >
              <Plus className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>

        <div className="text-right">
          <p className="text-[9px] uppercase font-bold text-brand-light leading-none">Total Amount</p>
          <span className="text-lg font-black text-brand-green-dark block mt-0.5">₹{totalPrice}</span>
        </div>

        <button
          id="confirm-add-tray-btn"
          onClick={handleAddToCart}
          className="bg-brand-orange hover:bg-brand-orange/95 text-white font-bold text-xs px-5 py-3 rounded-2xl shadow-lg transition flex items-center gap-1.5 cursor-pointer"
        >
          <ShoppingBag className="w-4 h-4" />
          <span>Add to Tray</span>
        </button>
      </div>
    </div>
  );
};
