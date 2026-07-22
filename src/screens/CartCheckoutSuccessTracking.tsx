import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { OFFERS, MEALS } from '../data';
import { 
  ArrowLeft, Trash2, Tag, Percent, ArrowRight, ShieldCheck, 
  MapPin, Check, CreditCard, Landmark, Coins, CheckCircle, Clock,
  Truck, Utensils, Box, Sparkles, Smile, RefreshCw, ChevronDown, ChevronUp
} from 'lucide-react';

export const CartCheckoutSuccessTracking: React.FC = () => {
  const { 
    screen, 
    cart, 
    addToCart,
    updateCartQuantity, 
    removeFromCart, 
    cartCount, 
    cartSubtotal,
    scheduleDiscountAmount,
    cartTotal, 
    appliedCoupon, 
    applyCoupon, 
    removeCoupon, 
    selectedHospital, 
    user,
    placeOrder, 
    activeOrder,
    setActiveOrder, 
    navigateTo, 
    goBack,
    getClinicalScheduleInfo,
    loginWithPhone,
    setPatientDetails
  } = useApp();

  // Local States
  const [couponInput, setCouponInput] = useState('');
  const [couponError, setCouponError] = useState('');
  const [paymentMethod, setPaymentMethod] = useState<'Cash' | 'UPI' | 'Card'>('UPI');
  const [dropOffOption, setDropOffOption] = useState<'NurseStation' | 'WardDoor' | 'Lobby'>('NurseStation');
  const [isPlacingOrder, setIsPlacingOrder] = useState(false);
  const [checkInSheetOpen, setCheckInSheetOpen] = useState(false);
  const [isPriceExpanded, setIsPriceExpanded] = useState(false);

  // Check if current user is a guest (needs bedside registration)
  const isGuest = !user || user.phone === 'Guest' || (!user.patientDetails && !user.employeeDetails);

  // Address details autofill
  const hospitalName = selectedHospital?.name || 'Bhatkal General Hospital';
  const hospitalLocation = selectedHospital?.location || 'Bhatkal';
  
  const roomNumber = !isGuest && user?.role === 'Patient' ? user.patientDetails?.roomNumber : (!isGuest ? 'Staff Room' : 'Pending Link');
  const wardName = !isGuest && user?.role === 'Patient' ? user.patientDetails?.ward : (!isGuest ? (user?.employeeDetails?.department || 'Staff') : 'Pending Link');
  const recipientName = !isGuest && user?.role === 'Patient' ? user.patientDetails?.patientName : (!isGuest ? (user?.employeeDetails?.employeeName || 'Staff') : 'Guest Patient');

  // Calculations
  const discountAmount = appliedCoupon 
    ? Math.round((cartSubtotal * appliedCoupon.discountPercentage) / 100) 
    : 0;
  const deliveryCharge = cartSubtotal > 0 ? 30 : 0;
  const gst = cartSubtotal > 0 ? Math.round(cartSubtotal * 0.05) : 0; // 5% GST
  const finalGrandTotal = cartTotal;

  const handleApplyCoupon = (e: React.FormEvent) => {
    e.preventDefault();
    if (!couponInput.trim()) return;
    const success = applyCoupon(couponInput);
    if (success) {
      setCouponError('');
    } else {
      setCouponError('Invalid coupon code or minimum value not reached.');
    }
  };

  const handlePlaceOrder = () => {
    if (isGuest) {
      navigateTo('login');
      return;
    }

    setIsPlacingOrder(true);
    setTimeout(() => {
      placeOrder(paymentMethod);
      setIsPlacingOrder(false);
    }, 1200);
  };

  // 1. RENDER CART & CHECKOUT IN MY TRAY PAGE
  if (screen === 'cart' || screen === 'checkout') {
    const recommendedJuices = MEALS.filter(m => m.category === 'Juice');
    const recommendedEssentials = MEALS.filter(m => m.category === 'Grocery');

    return (
      <div id="cart-screen" className="bg-brand-cream min-h-screen pb-64">
        {/* Top Header */}
        <div className="p-4 bg-white border-b border-gray-100 flex items-center justify-between shadow-sm max-w-2xl mx-auto sticky top-0 z-30">
          <button onClick={goBack} className="text-brand-dark hover:text-brand-green-dark p-1 cursor-pointer">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h2 className="text-sm font-black text-brand-green-dark uppercase tracking-wider">My Tray & Order</h2>
          <span className="text-xs font-bold text-brand-green-dark bg-brand-green-light px-2.5 py-1 rounded-lg">{cartCount} Items</span>
        </div>

        {cart.length === 0 ? (
          /* Empty State */
          <div className="max-w-md mx-auto px-6 py-16 text-center">
            <div className="w-24 h-24 bg-brand-green-light/40 rounded-full flex items-center justify-center mx-auto mb-5 border border-brand-green-medium/10">
              <Utensils className="w-10 h-10 text-brand-green-dark opacity-80" />
            </div>
            <h3 className="text-lg font-black text-brand-green-dark tracking-tight">Your Tray is Empty</h3>
            <p className="text-xs text-brand-light mt-1.5 max-w-xs mx-auto">
              You haven't added any healthy, sterile meals yet.
            </p>
            <button 
              onClick={() => navigateTo('home')} 
              className="mt-6 bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-bold text-xs px-6 py-3.5 rounded-xl shadow-md transition cursor-pointer"
            >
              Browse Healing Menu
            </button>
          </div>
        ) : (
          /* Cart & Checkout Content */
          <div className="max-w-2xl mx-auto px-4 mt-4 space-y-4">

            {/* List of food items */}
            <div className="bg-white rounded-3xl p-4 shadow-xs border border-brand-green-light/20 divide-y divide-gray-100">
              <h3 className="text-xs font-black text-brand-green-dark uppercase tracking-wider mb-3">
                Selected Meals ({cartCount})
              </h3>
              {cart.map((item) => {
                const custTags: string[] = [];
                if (item.customization.extraRice) custTags.push('+ Extra Rice');
                if (item.customization.extraCurry) custTags.push('+ Extra Curry');
                if (item.customization.extraSalad) custTags.push('+ Salad');
                if (item.customization.extraCurd) custTags.push('+ Curd');
                if (item.customization.addonEggBanana) {
                  custTags.push(item.meal.category === 'Lunch' ? '+ Egg & Apple' : '+ Egg & Banana');
                }
                if (item.customization.saltPreference !== 'Normal') custTags.push(item.customization.saltPreference);
                if (item.customization.spicePreference !== 'Normal') custTags.push(item.customization.spicePreference);
                if (item.customization.noOnion) custTags.push('No Onion');
                if (item.customization.noGarlic) custTags.push('No Garlic');

                const itemPrice = item.meal.price + 
                  (item.customization.extraRice ? 25 : 0) + 
                  (item.customization.extraCurry ? 30 : 0) + 
                  (item.customization.extraSalad ? 15 : 0) + 
                  (item.customization.extraCurd ? 15 : 0) +
                  (item.customization.addonEggBanana ? 20 : 0);

                return (
                  <div key={item.id} className="py-3 first:pt-1 last:pb-1 flex gap-3">
                    <img src={item.meal.image} alt={item.meal.name} className="w-14 h-14 rounded-xl object-cover flex-shrink-0 bg-gray-50 border border-gray-100" />
                    <div className="flex-1 min-w-0 flex flex-col justify-between">
                      <div>
                        <div className="flex justify-between items-start gap-1">
                          <h4 className="text-xs font-bold text-brand-dark leading-tight truncate">{item.meal.name}</h4>
                          <button 
                            onClick={() => removeFromCart(item.id)}
                            className="text-brand-light hover:text-brand-error p-0.5 transition cursor-pointer"
                            title="Remove item"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>
                        <p className="text-xs font-black text-brand-green-dark mt-0.5">₹{itemPrice}</p>
                        
                        {custTags.length > 0 && (
                          <div className="flex flex-wrap gap-1 mt-1.5">
                            {custTags.map((tag, i) => (
                              <span key={i} className="text-[8px] font-bold text-brand-green-dark bg-brand-green-light/50 px-1.5 py-0.5 rounded">
                                {tag}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>

                      <div className="flex justify-between items-center mt-2">
                        <span className="text-[10px] text-brand-light font-semibold">Portions</span>
                        <div className="flex items-center gap-2 bg-brand-cream border border-brand-green-light/20 px-2 py-0.5 rounded-lg">
                          <button 
                            onClick={() => updateCartQuantity(item.id, -1)}
                            className="p-0.5 rounded bg-white text-brand-green-dark shadow-xs cursor-pointer"
                          >
                            <MinusIcon className="w-3 h-3" />
                          </button>
                          <span className="text-xs font-bold text-brand-green-dark w-4 text-center">{item.quantity}</span>
                          <button 
                            onClick={() => updateCartQuantity(item.id, 1)}
                            className="p-0.5 rounded bg-white text-brand-green-dark shadow-xs cursor-pointer"
                          >
                            <PlusIcon className="w-3 h-3" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Recommended Fresh Juices & Hydration */}
            {recommendedJuices.length > 0 && (
              <div className="bg-white rounded-3xl p-4 shadow-xs border border-brand-green-light/20 space-y-3">
                <div className="flex justify-between items-center">
                  <h3 className="text-xs font-black text-brand-green-dark uppercase tracking-wider flex items-center gap-1.5">
                    🥤 Recommended Fresh Juices
                  </h3>
                  <span className="text-[10px] text-brand-light font-medium">Hydration</span>
                </div>
                <div className="flex gap-3 overflow-x-auto no-scrollbar pb-1">
                  {recommendedJuices.map((j) => (
                    <div key={j.id} className="w-36 flex-shrink-0 bg-brand-cream/60 rounded-2xl p-2.5 border border-brand-green-light/20 flex flex-col justify-between">
                      <div>
                        <img src={j.image} alt={j.name} className="w-full h-20 object-cover rounded-xl mb-2 bg-gray-100" />
                        <h4 className="text-[11px] font-black text-brand-dark leading-tight line-clamp-2">{j.name}</h4>
                      </div>
                      <div className="flex justify-between items-center mt-2.5 pt-1.5 border-t border-gray-200/50">
                        <span className="text-xs font-extrabold text-brand-green-dark">₹{j.price}</span>
                        <button 
                          onClick={() => addToCart(j, 1)}
                          className="bg-brand-green-dark hover:bg-brand-green-dark/90 text-white font-extrabold text-[10px] px-2.5 py-1 rounded-lg flex items-center gap-0.5 cursor-pointer shadow-xs transition"
                        >
                          <PlusIcon className="w-3 h-3" /> Add
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Bedside Essentials & Provisions */}
            {recommendedEssentials.length > 0 && (
              <div className="bg-white rounded-3xl p-4 shadow-xs border border-brand-green-light/20 space-y-3">
                <div className="flex justify-between items-center">
                  <h3 className="text-xs font-black text-brand-green-dark uppercase tracking-wider flex items-center gap-1.5">
                    📦 Bedside Essentials
                  </h3>
                  <span className="text-[10px] text-brand-light font-medium">Daily Care</span>
                </div>
                <div className="flex gap-3 overflow-x-auto no-scrollbar pb-1">
                  {recommendedEssentials.map((g) => (
                    <div key={g.id} className="w-36 flex-shrink-0 bg-brand-cream/60 rounded-2xl p-2.5 border border-brand-green-light/20 flex flex-col justify-between">
                      <div>
                        <img src={g.image} alt={g.name} className="w-full h-20 object-cover rounded-xl mb-2 bg-gray-100" />
                        <h4 className="text-[11px] font-black text-brand-dark leading-tight line-clamp-2">{g.name}</h4>
                      </div>
                      <div className="flex justify-between items-center mt-2.5 pt-1.5 border-t border-gray-200/50">
                        <span className="text-xs font-extrabold text-brand-green-dark">₹{g.price}</span>
                        <button 
                          onClick={() => addToCart(g, 1)}
                          className="bg-brand-green-dark hover:bg-brand-green-dark/90 text-white font-extrabold text-[10px] px-2.5 py-1 rounded-lg flex items-center gap-0.5 cursor-pointer shadow-xs transition"
                        >
                          <PlusIcon className="w-3 h-3" /> Add
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Drop-off Point Selection inside My Tray Page */}
            <div className="bg-white rounded-3xl p-4 shadow-xs border border-brand-green-light/20 space-y-2.5">
              <h3 className="text-xs font-black text-brand-green-dark uppercase tracking-wider flex items-center gap-1.5">
                <Truck className="w-4 h-4 text-brand-orange" /> Drop-off Point Choice
              </h3>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                {[
                  { id: 'NurseStation', title: 'Nurse Station Desk', desc: 'Ward reception Desk', icon: '🏥' },
                  { id: 'WardDoor', title: 'Ward Door', desc: 'Hand over silently at door', icon: '🤫' },
                  { id: 'Lobby', title: 'Main Lobby', desc: 'Meet outside entrance', icon: '🚶' },
                ].map((opt) => (
                  <button
                    key={opt.id}
                    type="button"
                    onClick={() => setDropOffOption(opt.id as any)}
                    className={`p-2.5 rounded-xl border text-left transition flex items-center gap-2.5 cursor-pointer ${
                      dropOffOption === opt.id
                        ? 'bg-brand-green-light/35 border-brand-green-medium text-brand-green-dark font-bold shadow-xs'
                        : 'bg-brand-cream/50 text-brand-dark border-gray-100 hover:bg-brand-green-light/10'
                    }`}
                  >
                    <span className="text-lg">{opt.icon}</span>
                    <div className="min-w-0">
                      <h4 className="text-xs font-black truncate">{opt.title}</h4>
                      <p className="text-[9px] text-brand-light truncate">{opt.desc}</p>
                    </div>
                  </button>
                ))}
              </div>
            </div>

          </div>
        )}

        {/* FIXED BOTTOM BAR: Coupon + Total Amount + Place Order */}
        {cart.length > 0 && (
          <div className="fixed bottom-0 inset-x-0 bg-white border-t border-brand-green-medium/30 p-4 shadow-2xl z-40 max-w-2xl mx-auto rounded-t-3xl space-y-2.5">
            
            {/* 1. Smaller Apply Coupon */}
            <div className="bg-brand-cream/70 p-2 rounded-2xl border border-brand-green-light/20">
              {!appliedCoupon ? (
                <form onSubmit={handleApplyCoupon} className="flex gap-2 items-center">
                  <Tag className="w-3.5 h-3.5 text-brand-orange flex-shrink-0 ml-1" />
                  <input 
                    type="text" 
                    placeholder="Coupon code (e.g. HEAL100)"
                    value={couponInput}
                    onChange={(e) => setCouponInput(e.target.value.toUpperCase())}
                    className="flex-1 bg-white border border-gray-200 rounded-lg px-2.5 py-1 text-xs font-bold uppercase focus:ring-1 focus:ring-brand-green-dark"
                  />
                  <button 
                    type="submit"
                    className="bg-brand-green-dark hover:bg-brand-green-dark/90 text-white text-[11px] font-bold px-3 py-1 rounded-lg shadow cursor-pointer flex-shrink-0"
                  >
                    Apply
                  </button>
                </form>
              ) : (
                <div className="flex justify-between items-center px-1">
                  <div className="flex items-center gap-1.5">
                    <Percent className="w-3.5 h-3.5 text-brand-orange" />
                    <span className="text-xs font-bold text-brand-green-dark">{appliedCoupon.code} (-₹{discountAmount})</span>
                  </div>
                  <button onClick={removeCoupon} className="text-[11px] font-bold text-brand-error hover:underline cursor-pointer">
                    Remove
                  </button>
                </div>
              )}
              {couponError && <p className="text-[10px] text-brand-error mt-1 px-1 font-semibold">{couponError}</p>}
            </div>

            {/* 2. Total Amount + Expandable Price Structure */}
            <div className="flex justify-between items-center">
              <div>
                <span className="text-[10px] uppercase font-bold text-brand-light block">Total Payable</span>
                <span className="text-xl font-black text-brand-green-dark leading-none">₹{finalGrandTotal}</span>
              </div>
              <button 
                type="button"
                onClick={() => setIsPriceExpanded(!isPriceExpanded)}
                className="flex items-center gap-1 text-[11px] font-bold text-brand-green-dark bg-brand-green-light/40 px-2.5 py-1 rounded-lg hover:bg-brand-green-light/70 transition cursor-pointer"
              >
                <span>{isPriceExpanded ? 'Hide breakdown' : 'Price breakdown'}</span>
                {isPriceExpanded ? <ChevronUp className="w-3.5 h-3.5" /> : <ChevronDown className="w-3.5 h-3.5" />}
              </button>
            </div>

            {/* Expandable detailed fee structure */}
            {isPriceExpanded && (
              <div className="pt-2 border-t border-dashed border-gray-200 space-y-1.5 text-xs animate-fade-in text-brand-light max-h-36 overflow-y-auto">
                <div className="flex justify-between">
                  <span>Meal Subtotal</span>
                  <span className="font-semibold text-brand-dark">₹{cartSubtotal}</span>
                </div>
                {appliedCoupon && (
                  <div className="flex justify-between text-brand-green-dark font-semibold">
                    <span>Promo Discount ({appliedCoupon.code})</span>
                    <span>-₹{discountAmount}</span>
                  </div>
                )}
                {scheduleDiscountAmount > 0 && (
                  <div className="flex justify-between text-brand-orange font-bold">
                    <span>Schedule Savings</span>
                    <span>-₹{scheduleDiscountAmount}</span>
                  </div>
                )}
                <div className="flex justify-between">
                  <span>Hospital Ward Delivery</span>
                  <span className="font-semibold text-brand-dark">₹{deliveryCharge}</span>
                </div>
                <div className="flex justify-between">
                  <span>Dietary GST (5%)</span>
                  <span className="font-semibold text-brand-dark">₹{gst}</span>
                </div>
              </div>
            )}

            {/* 3. Place Order Button */}
            <button
              id="place-order-tray-btn"
              onClick={handlePlaceOrder}
              disabled={isPlacingOrder}
              className="w-full bg-brand-orange hover:bg-brand-orange/95 text-white font-extrabold text-sm py-3.5 rounded-2xl shadow-md transition flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50"
            >
              {isPlacingOrder ? (
                <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                <>
                  <span>Place Order Bedside</span>
                  <Check className="w-4 h-4 stroke-[3]" />
                </>
              )}
            </button>

          </div>
        )}
      </div>
    );
  }

  // 2. RENDER SUCCESS SCREEN
  if (screen === 'success') {
    return (
      <div id="success-screen" className="bg-brand-cream min-h-screen px-6 py-12 flex flex-col justify-between">
        <div className="max-w-md mx-auto w-full my-auto text-center space-y-6">
          
          <div className="relative w-28 h-28 bg-white rounded-full flex items-center justify-center mx-auto shadow-lg border-2 border-brand-green-light mb-6">
            <CheckCircle className="w-16 h-16 text-brand-green-dark animate-pulse" />
            <div className="absolute -inset-1 rounded-full border-2 border-brand-orange animate-ping opacity-25" />
          </div>

          <span className="bg-brand-orange/10 text-brand-orange text-xs font-black px-3.5 py-1 rounded-full uppercase tracking-widest">
            Order Confirmed
          </span>

          <h2 className="text-3xl font-black text-brand-green-dark tracking-tight leading-tight">
            Nourishment Is On Its Way!
          </h2>
          
          <p className="text-sm text-brand-light leading-relaxed max-w-xs mx-auto">
            Your healthy meal is being cooked right now with certified clinical safety and low-oil hygiene.
          </p>

          <div className="bg-white p-5 rounded-3xl border border-brand-green-light/25 shadow-sm space-y-3">
            <div className="flex justify-between items-center text-xs text-brand-light">
              <span>Order Number</span>
              <strong className="text-brand-dark font-black font-mono">{activeOrder?.orderNumber || 'HP283912'}</strong>
            </div>
            <div className="flex justify-between items-center text-xs text-brand-light">
              <span>Estimated Delivery</span>
              <span className="text-brand-green-dark font-extrabold flex items-center gap-1">
                <Clock className="w-3.5 h-3.5 text-brand-orange" />
                {activeOrder?.estimatedDeliveryMinutes || '25'} mins
              </span>
            </div>
            <div className="flex justify-between items-center text-xs text-brand-light">
              <span>Delivery Point</span>
              <span className="text-brand-dark font-bold truncate max-w-[180px]">
                {hospitalName}, Room {roomNumber}
              </span>
            </div>
          </div>
        </div>

        {/* Action Controls */}
        <div className="max-w-md mx-auto w-full space-y-3">
          <button
            id="track-order-btn"
            onClick={() => navigateTo('tracking')}
            className="w-full bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-bold text-sm py-4 rounded-xl shadow-md transition flex items-center justify-center gap-2 cursor-pointer"
          >
            <Truck className="w-4 h-4 animate-bounce" />
            <span>Track Order Bedside</span>
          </button>
          
          <button
            id="back-home-btn"
            onClick={() => navigateTo('home')}
            className="w-full bg-white border border-brand-green-light/40 text-brand-green-dark hover:bg-brand-green-light/10 font-bold text-sm py-3.5 rounded-xl transition cursor-pointer"
          >
            Back to Home Feed
          </button>
        </div>
      </div>
    );
  }

  // 3. RENDER ORDER TRACKING SCREEN
  const orderToTrack = activeOrder;
  const trackingStatus = orderToTrack?.status || 'Received';

  const steps = [
    { label: 'Order Received', desc: 'Nourishment request sent to sterile kitchen.', icon: Box, status: 'Received' },
    { label: 'Preparing', desc: 'Health chef preparing your low-sodium, nutrient meal.', icon: Utensils, status: 'Preparing' },
    { label: 'Out for Delivery', desc: 'Container sealed in thermal bag. Ascending to ward.', icon: Truck, status: 'Out for Delivery' },
    { label: 'Delivered', desc: 'Meal handed over to ward nurse or bedside.', icon: Smile, status: 'Delivered' }
  ];

  const getStepIndex = (status: string) => {
    if (status === 'Received') return 0;
    if (status === 'Preparing') return 1;
    if (status === 'Out for Delivery') return 2;
    if (status === 'Delivered') return 3;
    return 0;
  };

  const activeStepIdx = getStepIndex(trackingStatus);

  return (
    <div id="tracking-screen" className="bg-brand-cream min-h-screen pb-24">
      {/* App Bar */}
      <div className="p-4 bg-white border-b border-gray-100 flex items-center justify-between shadow-sm sticky top-0 z-30 max-w-xl mx-auto">
        <button onClick={() => navigateTo('home')} className="text-brand-dark hover:text-brand-green-dark p-1 cursor-pointer">
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h2 className="text-sm font-extrabold text-brand-green-dark uppercase tracking-wider">Live Bedside Tracking</h2>
        <button 
          onClick={() => {
            if (orderToTrack) {
              const currentStatus = orderToTrack.status;
              let next: any = 'Received';
              if (currentStatus === 'Received') next = 'Preparing';
              else if (currentStatus === 'Preparing') next = 'Out for Delivery';
              else if (currentStatus === 'Out for Delivery') next = 'Delivered';
              else next = 'Received';
              
              const { updateOrderStatus } = useApp();
              updateOrderStatus(orderToTrack.id, next);
            }
          }}
          className="text-xs font-bold text-brand-orange bg-brand-orange/10 px-2 py-1 rounded-md flex items-center gap-1 cursor-pointer"
          title="Force simulator step"
        >
          <RefreshCw className="w-3 h-3" />
          <span>Simulate</span>
        </button>
      </div>

      <div className="max-w-xl mx-auto px-4 mt-6 space-y-6">
        
        {/* Status header card */}
        <div className="bg-white p-5 rounded-3xl border border-brand-green-light/25 shadow-sm flex gap-4 items-center">
          <div className="w-14 h-14 rounded-full bg-brand-green-light flex items-center justify-center text-brand-green-dark flex-shrink-0">
            <Truck className="w-7 h-7 text-brand-green-dark animate-pulse" />
          </div>
          <div>
            <p className="text-[10px] text-brand-light uppercase font-black tracking-widest leading-none">Current Status</p>
            <h3 className="text-lg font-black text-brand-green-dark mt-1 tracking-tight leading-none">
              {trackingStatus === 'Received' ? 'Kitchen is Reviewing' :
               trackingStatus === 'Preparing' ? 'Baking Fresh & Warm' :
               trackingStatus === 'Out for Delivery' ? 'Approaching Your Ward' :
               'Enjoy Your Healthy Meal'}
            </h3>
            <p className="text-xs text-brand-light mt-1.5 leading-normal">
              Order No: <strong className="font-semibold font-mono text-brand-dark">{orderToTrack?.orderNumber || 'HP239120'}</strong>
            </p>
          </div>
        </div>

        {/* Live Timeline list */}
        <div className="bg-white rounded-3xl p-6 shadow-sm border border-brand-green-light/20 relative">
          <h3 className="text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-6">Delivery Timeline</h3>
          
          <div className="relative space-y-8 pl-8">
            <span className="absolute left-3 top-2.5 bottom-2 w-[2px] bg-gray-100" />
            <span 
              className="absolute left-3 top-2.5 transition-all duration-1000 w-[2px] bg-brand-green-dark" 
              style={{ height: `${(activeStepIdx / (steps.length - 1)) * 90}%` }}
            />

            {steps.map((step, idx) => {
              const isCompleted = idx <= activeStepIdx;
              const isActive = idx === activeStepIdx;
              const StepIcon = step.icon;

              return (
                <div key={idx} className="relative flex gap-4 items-start">
                  <span className={`absolute -left-8 top-0.5 w-6.5 h-6.5 rounded-full flex items-center justify-center transition border ${
                    isCompleted 
                      ? 'bg-brand-green-dark border-brand-green-dark text-white' 
                      : 'bg-white border-gray-200 text-brand-light/60'
                  } ${isActive ? 'ring-4 ring-brand-green-light/80 scale-110 animate-pulse' : ''}`}>
                    {isCompleted ? <Check className="w-3.5 h-3.5 stroke-[3]" /> : <span className="w-2 h-2 rounded-full bg-gray-300" />}
                  </span>

                  <div className="flex gap-3">
                    <div className={`p-2 rounded-xl border transition ${
                      isCompleted ? 'bg-brand-green-light/30 border-brand-green-medium/20 text-brand-green-dark' : 'bg-gray-50 border-transparent text-brand-light/40'
                    }`}>
                      <StepIcon className="w-4 h-4" />
                    </div>
                    <div>
                      <h4 className={`text-xs font-bold transition ${isCompleted ? 'text-brand-dark' : 'text-brand-light/50'}`}>
                        {step.label}
                      </h4>
                      <p className={`text-[11px] leading-relaxed mt-0.5 transition ${isCompleted ? 'text-brand-light' : 'text-brand-light/30'}`}>
                        {step.desc}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Hospital courier drop details */}
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-brand-green-light/20 space-y-3.5">
          <h3 className="text-xs font-bold text-brand-green-dark uppercase tracking-wider">Bedside Delivery Target</h3>
          
          <div className="text-xs text-brand-light space-y-1.5 p-3.5 bg-brand-cream rounded-2xl border border-gray-100">
            <p><strong>Hospital:</strong> {hospitalName}</p>
            <p><strong>Recipient Admitted:</strong> {recipientName || 'Patient'}</p>
            <p><strong>Ward / Room Location:</strong> {wardName}, Room {roomNumber}</p>
            {orderToTrack?.patientDetails?.notes && (
              <p className="bg-amber-50 p-2 text-brand-dark rounded-xl mt-1 border border-amber-200/40 text-[11px]">
                📝 <strong>Special request:</strong> "{orderToTrack.patientDetails.notes}"
              </p>
            )}
          </div>
        </div>

        <div className="pt-2">
          <button
            onClick={() => navigateTo('home')}
            className="w-full bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-bold text-sm py-4 rounded-xl shadow-md transition text-center cursor-pointer block"
          >
            Back to Home Feed
          </button>
        </div>

      </div>
    </div>
  );
};

const PlusIcon: React.FC<{ className?: string }> = ({ className }) => (
  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="3" stroke="currentColor" className={className}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
  </svg>
);

const MinusIcon: React.FC<{ className?: string }> = ({ className }) => (
  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="3" stroke="currentColor" className={className}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 12h-15" />
  </svg>
);
