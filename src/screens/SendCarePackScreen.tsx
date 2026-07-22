import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { HOSPITALS } from '../data';
import { Heart, Sparkles, MapPin, ClipboardList, CheckCircle2 } from 'lucide-react';

export const SendCarePackScreen: React.FC = () => {
  const { selectHospital, setPatientDetails, loginAsGuest, addNotification, navigateTo } = useApp();

  const [selectedHospitalId, setSelectedHospitalId] = useState('');
  const [wardNumber, setWardNumber] = useState('');
  const [roomNumber, setRoomNumber] = useState('');
  const [lovedOneName, setLovedOneName] = useState('');
  const [error, setError] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!lovedOneName.trim()) {
      setError("Please enter your loved one's name");
      return;
    }
    if (!selectedHospitalId) {
      setError("Please choose your hospital location");
      return;
    }
    if (!wardNumber.trim()) {
      setError('Please enter a ward number');
      return;
    }
    if (!roomNumber.trim()) {
      setError('Please enter a room number');
      return;
    }

    setError('');

    const hospital = HOSPITALS.find(h => h.id === selectedHospitalId);
    if (hospital) {
      selectHospital(hospital);
      loginAsGuest(false);
      setPatientDetails({
        patientName: lovedOneName,
        ward: wardNumber,
        roomNumber: roomNumber,
        notes: "Overnight Care Pack Order"
      });

      addNotification(
        "Care Pack Enabled! 🎁",
        `Pre-ordering for ${lovedOneName} at ${hospital.name}, Ward ${wardNumber}.`
      );

      setIsSuccess(true);
      setTimeout(() => {
        navigateTo('home');
      }, 2500);
    }
  };

  if (isSuccess) {
    return (
      <div className="p-6 text-center py-20 flex flex-col items-center justify-center animate-fade-in bg-white min-h-[70vh] rounded-3xl border border-brand-green-light/20 m-4">
        <div className="w-16 h-16 bg-brand-green-light rounded-full flex items-center justify-center text-brand-green-dark mb-4 animate-bounce">
          <CheckCircle2 className="w-10 h-10" />
        </div>
        <h3 className="text-lg font-black text-brand-green-dark uppercase tracking-wider">Care Pack Configured!</h3>
        <p className="text-xs text-brand-light mt-2 max-w-xs mx-auto leading-relaxed">
          Bedspace details have been safely linked. Redirecting you to choose nutritious diets and premium caregiver essentials...
        </p>
      </div>
    );
  }

  return (
    <div className="p-4 pb-24 space-y-6 animate-fade-in">
      <div className="bg-white rounded-3xl p-5 border border-brand-green-light/25 shadow-sm flex items-center gap-3.5">
        <div className="bg-brand-orange text-white p-3 rounded-2xl shadow-md">
          <Heart className="w-6 h-6 fill-white animate-pulse" />
        </div>
        <div>
          <span className="text-[10px] uppercase font-black tracking-wider text-brand-orange bg-brand-orange/10 px-2 py-0.5 rounded-full">
            Hospital Support Flow
          </span>
          <h3 className="font-display text-lg font-black text-brand-green-dark tracking-tight mt-1 leading-none">
            Send a Care Pack
          </h3>
        </div>
      </div>

      {/* NEW SECTION: What We Send */}
      <div className="bg-gradient-to-br from-brand-green-dark to-brand-green-medium text-white rounded-3xl p-5 shadow-lg space-y-4">
        <h4 className="text-xs font-black uppercase tracking-wider flex items-center gap-1.5 border-b border-white/20 pb-2">
          <ClipboardList className="w-4 h-4 text-brand-orange" /> What is Included in the Care Pack
        </h4>
        <div className="space-y-3.5 text-xs">
          <div className="flex gap-2.5 items-start">
            <span className="bg-white/10 p-1.5 rounded-lg text-sm">🛏️</span>
            <div>
              <p className="font-extrabold text-white">Overnight Caregiver Comfort Pack</p>
              <p className="text-[11px] text-white/80 leading-normal mt-0.5">
                Premium orthopedic memory foam neck pillow, warm flannel blanket, 100% blackout eyeshade, and clinical earplugs for sound sleep on ward recliners.
              </p>
            </div>
          </div>

          <div className="flex gap-2.5 items-start">
            <span className="bg-white/10 p-1.5 rounded-lg text-sm">🍲</span>
            <div>
              <p className="font-extrabold text-white">Steaming Hot Diets & Lunch Plates</p>
              <p className="text-[11px] text-white/80 leading-normal mt-0.5">
                Low-sodium, non-greasy breakfast (Khichdi or high-fiber Upma) and custom-balanced protein lunch plates tailored for nursing environments.
              </p>
            </div>
          </div>

          <div className="flex gap-2.5 items-start">
            <span className="bg-white/10 p-1.5 rounded-lg text-sm">🥤</span>
            <div>
              <p className="font-extrabold text-white">Cold-Pressed Nourishing Juices</p>
              <p className="text-[11px] text-white/80 leading-normal mt-0.5">
                100% raw tender coconut water and iron-rich beetroot detox juices to double hydration and maintain strong caregiver immunity.
              </p>
            </div>
          </div>

          <div className="flex gap-2.5 items-start">
            <span className="bg-white/10 p-1.5 rounded-lg text-sm">🧴</span>
            <div>
              <p className="font-extrabold text-white">Sanitization & Hygiene Shield</p>
              <p className="text-[11px] text-white/80 leading-normal mt-0.5">
                Instant medical-grade hand sanitizer (70% alcohol-based) and sterile antibacterial wet wipes for bedside safety and infection control.
              </p>
            </div>
          </div>
        </div>
      </div>

      {error && (
        <div className="bg-amber-50 text-amber-900 border border-amber-200 rounded-2xl p-4 text-xs flex gap-2 items-start">
          <span className="text-brand-orange mt-0.5">⚠️</span>
          <p className="font-semibold">{error}</p>
        </div>
      )}

      {/* Form Card */}
      <div className="bg-white rounded-3xl p-5 border border-brand-green-light/20 shadow-sm">
        <h4 className="text-xs font-black text-brand-green-dark uppercase tracking-wider mb-4 flex items-center gap-1.5">
          <MapPin className="w-4 h-4 text-brand-orange" /> Bedside Handoff Details
        </h4>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-1.5">
            <label className="text-[11px] font-black uppercase tracking-wider text-brand-green-dark">
              Loved One's Full Name (Relative staying)
            </label>
            <input 
              type="text"
              placeholder="e.g. Rayan Ahmed"
              value={lovedOneName}
              onChange={(e) => setLovedOneName(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 bg-brand-cream/10 focus:border-brand-green-medium focus:ring-1 focus:ring-brand-green-medium outline-none text-xs text-brand-dark"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-[11px] font-black uppercase tracking-wider text-brand-green-dark">
              Hospital Location
            </label>
            <select
              value={selectedHospitalId}
              onChange={(e) => setSelectedHospitalId(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border border-gray-200 bg-white focus:border-brand-green-medium focus:ring-1 focus:ring-brand-green-medium outline-none text-xs text-brand-dark"
            >
              <option value="">Choose your hospital</option>
              {HOSPITALS.map(h => (
                <option key={h.id} value={h.id}>
                  {h.name} ({h.location})
                </option>
              ))}
            </select>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1.5">
              <label className="text-[11px] font-black uppercase tracking-wider text-brand-green-dark">
                Ward Number
              </label>
              <input 
                type="text"
                placeholder="e.g. Ward 4B"
                value={wardNumber}
                onChange={(e) => setWardNumber(e.target.value)}
                className="w-full px-4 py-3 rounded-xl border border-gray-200 bg-brand-cream/10 focus:border-brand-green-medium focus:ring-1 focus:ring-brand-green-medium outline-none text-xs text-brand-dark"
              />
            </div>
            
            <div className="space-y-1.5">
              <label className="text-[11px] font-black uppercase tracking-wider text-brand-green-dark">
                Room / Bed Number
              </label>
              <input 
                type="text"
                placeholder="e.g. Bed 102"
                value={roomNumber}
                onChange={(e) => setRoomNumber(e.target.value)}
                className="w-full px-4 py-3 rounded-xl border border-gray-200 bg-brand-cream/10 focus:border-brand-green-medium focus:ring-1 focus:ring-brand-green-medium outline-none text-xs text-brand-dark"
              />
            </div>
          </div>

          <div className="bg-brand-green-light/10 border border-brand-green-medium/10 rounded-2xl p-3.5 text-[11px] text-brand-green-dark flex items-start gap-2">
            <Sparkles className="w-4.5 h-4.5 text-brand-orange flex-shrink-0 mt-0.5" />
            <p className="leading-normal">
              Our clinical food delivery agent will transport the items inside hospital gates directly to the specified bedside safely.
            </p>
          </div>

          <button
            type="submit"
            className="w-full bg-brand-orange hover:bg-brand-orange/90 text-white font-black text-xs uppercase py-3.5 rounded-xl transition cursor-pointer flex items-center justify-center gap-2 shadow-lg mt-2"
          >
            <Heart className="w-4.5 h-4.5 fill-white" />
            <span>Select Diets & Essentials</span>
          </button>
        </form>
      </div>
    </div>
  );
};
