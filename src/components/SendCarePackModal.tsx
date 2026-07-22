import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { HOSPITALS } from '../data';
import { X, Heart, ShieldAlert, Sparkles, MapPin } from 'lucide-react';

interface SendCarePackModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const SendCarePackModal: React.FC<SendCarePackModalProps> = ({ isOpen, onClose }) => {
  const { selectHospital, setPatientDetails, loginAsGuest, addNotification } = useApp();
  
  const [selectedHospitalId, setSelectedHospitalId] = useState('');
  const [wardNumber, setWardNumber] = useState('');
  const [roomNumber, setRoomNumber] = useState('');
  const [lovedOneName, setLovedOneName] = useState('');
  const [error, setError] = useState('');

  if (!isOpen) return null;

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
    
    // Find hospital object
    const hospital = HOSPITALS.find(h => h.id === selectedHospitalId);
    if (hospital) {
      // Step 1: Select hospital
      selectHospital(hospital);
      
      // Step 2: Log in as guest caregiver
      loginAsGuest(false);

      // Step 3: Configure patient/relative details
      setPatientDetails({
        patientName: lovedOneName,
        ward: wardNumber,
        roomNumber: roomNumber,
        notes: "Overnight Care Pack Order"
      });

      // Notify
      addNotification(
        "Care Pack Enabled! 🎁",
        `Pre-ordering for ${lovedOneName} at ${hospital.name}, Ward ${wardNumber}.`
      );

      onClose();
    }
  };

  return (
    <div className="fixed inset-0 bg-slate-900/70 backdrop-blur-sm z-[9999] flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl flex flex-col max-h-[90vh] border border-brand-green-light/20 relative animate-fade-in overflow-y-auto no-scrollbar">
        
        {/* Close Button */}
        <button 
          onClick={onClose}
          className="absolute top-4 right-4 text-brand-light hover:text-brand-dark transition p-1 rounded-full hover:bg-brand-cream"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Header decoration */}
        <div className="flex items-center gap-3.5 mb-5 border-b border-gray-100 pb-4">
          <div className="bg-brand-orange text-white p-3 rounded-2xl shadow-md">
            <Heart className="w-6 h-6 fill-white" />
          </div>
          <div>
            <span className="text-[10px] uppercase font-black tracking-wider text-brand-orange bg-brand-orange/10 px-2 py-0.5 rounded-full">
              Hospital Support Flow
            </span>
            <h3 className="text-lg font-black text-brand-green-dark tracking-tight mt-1 leading-none">
              Send a Care Pack
            </h3>
          </div>
        </div>

        <p className="text-xs text-brand-light leading-relaxed mb-4">
          Pre-order steaming breakfast, healthy warm lunches, fresh cold-pressed juices, and caregiver overnight comfort bundles for a relative staying overnight in the hospital.
        </p>

        {error && (
          <div className="bg-amber-50 text-amber-900 border border-amber-200 rounded-xl p-3 mb-4 text-xs flex gap-2 items-start">
            <ShieldAlert className="w-4 h-4 text-brand-orange flex-shrink-0 mt-0.5" />
            <p className="font-semibold">{error}</p>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Loved One Name */}
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

          {/* Hospital Selection */}
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

          {/* Ward & Room Input (Horizontal Grid) */}
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

          {/* Guidance Banner */}
          <div className="bg-brand-green-light/10 border border-brand-green-medium/10 rounded-2xl p-3.5 text-[11px] text-brand-green-dark flex items-start gap-2">
            <Sparkles className="w-4.5 h-4.5 text-brand-orange flex-shrink-0 mt-0.5" />
            <p className="leading-normal">
              We prepare every care pack in sterilized kitchens with non-greasy recipes, then transport them directly inside hospital gates for secure bedside hand-off.
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
