import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { 
  Building2, Car, Hospital as HospitalIcon, CarFront, 
  MapPin, Phone, Star, CheckCircle, ShieldCheck, 
  Calendar, Clock, Send, ChevronRight, Sparkles, AlertCircle, UserCheck
} from 'lucide-react';
import { LOCAL_IMAGES } from '../utils/localImages';

// Data for Resorts
const RESORTS = [
  {
    id: 'res-1',
    name: 'Royal Beach Resort Murdeshwar',
    location: 'Beach Road, Murdeshwar (14 km from Bhatkal)',
    pricePerNight: 3200,
    rating: 4.8,
    image: LOCAL_IMAGES.resortBeach,
    features: ['Sea View Balcony', 'AC Rooms', 'Patient Family Kitchenette', '24/7 Hot Water', 'Power Backup'],
    phone: '+91 98801 23456',
  },
  {
    id: 'res-2',
    name: 'Shree Sai Coastal Resort Bhatkal',
    location: 'Bunder Road, Bhatkal (Near Govt & Welfare Hospitals)',
    pricePerNight: 2500,
    rating: 4.7,
    image: LOCAL_IMAGES.resortBeach,
    features: ['Quiet Environment', 'Lift Access', 'Wheelchair Friendly', 'Organic Meal Delivery', 'AC Suite'],
    phone: '+91 98801 23457',
  },
  {
    id: 'res-3',
    name: 'Kodialbay Eco Beach Resort',
    location: 'Tengingundi Beach, Bhatkal',
    pricePerNight: 3800,
    rating: 4.9,
    image: LOCAL_IMAGES.resortNature,
    features: ['Private Beach Cottage', 'AC Suites', 'Homemade Diet Kitchen', 'Doctor on Call'],
    phone: '+91 98801 23458',
  },
  {
    id: 'res-4',
    name: 'Netrani Island View Resort',
    location: 'Mundalli Coastal Highway, Bhatkal',
    pricePerNight: 4200,
    rating: 4.9,
    image: LOCAL_IMAGES.resortBeach,
    features: ['Luxury Villa', 'Ample Parking', 'Caretaker Support', 'Air-Conditioned', 'Pure Veg Dining'],
    phone: '+91 98801 23459',
  },
  {
    id: 'res-5',
    name: 'Pinehill Valley Nature Resort',
    location: 'Grote Ghat Road, Bhatkal Outer',
    pricePerNight: 2800,
    rating: 4.6,
    image: LOCAL_IMAGES.resortNature,
    features: ['Lush Green Surroundings', 'Peaceful Rest Ward', 'Self-Cooking Option', '24/7 Security'],
    phone: '+91 98801 23460',
  },
];

// Data for Rental Cars
const CARS = [
  {
    id: 'car-1',
    name: 'Innova Crysta AC (7-Seater)',
    type: 'Spacious Premium MPV',
    pricePerDay: 2800,
    seats: 7,
    image: LOCAL_IMAGES.carSuv,
    perks: ['Reclining Captain Seats', 'Smooth Suspension for Patients', 'Chauffeur / Self Drive'],
  },
  {
    id: 'car-2',
    name: 'Swift Dzire AC',
    type: 'Comfort Sedan',
    pricePerDay: 1500,
    seats: 5,
    image: LOCAL_IMAGES.carSedan,
    perks: ['Economical City Drive', 'Fuel Efficient', 'Clean Sanitized Cabin'],
  },
  {
    id: 'car-3',
    name: 'Ertiga AC (7-Seater)',
    type: 'Family MPV',
    pricePerDay: 2200,
    seats: 7,
    image: LOCAL_IMAGES.carSuv,
    perks: ['Luggage Space', 'Dual Air Conditioning', 'Hospital Drop Ready'],
  },
  {
    id: 'car-4',
    name: 'Mahindra XUV700 AC',
    type: 'Luxury SUV',
    pricePerDay: 3500,
    seats: 7,
    image: LOCAL_IMAGES.carSuv,
    perks: ['Extra Comfort', 'Advanced Safety ABS/Airbags', 'Outstation Highway Travel'],
  },
];

// Data for Mangalore Hospitals
const MANGALORE_HOSPITALS = [
  {
    id: 'mng-1',
    name: 'AJ Hospital & Research Centre',
    location: 'NH-66, Kuntikan, Mangalore',
    specialties: ['Cardiology', 'Oncology', 'Neurology', 'Gastroenterology'],
    rating: 4.9,
    image: LOCAL_IMAGES.hospitalMangalore,
    phone: '+91 824 222 5555',
  },
  {
    id: 'mng-2',
    name: 'KMC Hospital Mangalore',
    location: 'Ambedkar Circle / Jyothi, Mangalore',
    specialties: ['Pediatrics', 'Orthopedics', 'Nephrology', 'Emergency Care'],
    rating: 4.9,
    image: LOCAL_IMAGES.hospitalMangalore,
    phone: '+91 824 244 5858',
  },
  {
    id: 'mng-3',
    name: 'Father Muller Charitable Hospital',
    location: 'Kankanady, Mangalore',
    specialties: ['General Surgery', 'Obstetrics', 'Dermatology', 'Psychiatry'],
    rating: 4.8,
    image: LOCAL_IMAGES.hospitalMangalore,
    phone: '+91 824 223 8000',
  },
  {
    id: 'mng-4',
    name: 'Yenepoya Specialty Hospital',
    location: 'Kodialbail, Mangalore',
    specialties: ['Urology', 'Organ Transplant', 'Radiology', 'ENT'],
    rating: 4.7,
    image: LOCAL_IMAGES.hospitalMangalore,
    phone: '+91 824 249 6800',
  },
];

// Data for Mangalore Taxi Service
const TAXI_RATES = [
  {
    type: 'Standard Sedan AC (Swift Dzire / Etios)',
    bhatkalToMangalorePrice: 2800,
    duration: '2.5 Hours (140 km)',
    notes: 'Door-to-door pickup from Bhatkal hospital or home direct to Mangalore OPD.',
  },
  {
    type: 'Spacious SUV AC (Innova / Ertiga)',
    bhatkalToMangalorePrice: 3800,
    duration: '2.5 Hours (140 km)',
    notes: 'Ideal for patient + 4 family members with heavy luggage.',
  },
  {
    type: 'Medical AC Van (Stretcher Support)',
    bhatkalToMangalorePrice: 4500,
    duration: '2.5 Hours',
    notes: 'Equipped with reclining bed/stretcher & oxygen support on request.',
  },
];

export const MoreScreen: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'resorts' | 'cars' | 'hospitals' | 'taxi'>('resorts');
  
  // Modals state
  const [bookingModal, setBookingModal] = useState<{ open: boolean; title: string; price: string }>({ open: false, title: '', price: '' });
  const [patientName, setPatientName] = useState('');
  const [phoneInput, setPhoneInput] = useState('');
  const [bookingSuccess, setBookingSuccess] = useState(false);

  const handleBookingSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setBookingSuccess(true);
    setTimeout(() => {
      setBookingSuccess(false);
      setBookingModal({ open: false, title: '', price: '' });
      setPatientName('');
      setPhoneInput('');
    }, 2500);
  };

  return (
    <div id="more-hub-screen" className="pb-28 bg-brand-cream min-h-screen">
      
      {/* Header Banner */}
      <div className="bg-brand-green-dark text-white p-5 rounded-b-3xl shadow-lg border-b border-brand-green-medium/30">
        <span className="text-[10px] font-black uppercase tracking-widest bg-white/20 text-emerald-100 px-2.5 py-1 rounded-full inline-block mb-1">
          Bhatkal &amp; Coastal Karnataka Services
        </span>
        <h1 className="font-display text-2xl font-black tracking-tight flex items-center gap-2">
          <span>More Travel &amp; Healthcare Hub</span>
        </h1>
        <p className="text-xs text-emerald-100/90 mt-1 leading-relaxed">
          Book local family resort stays, rent patient-friendly vehicles, schedule appointments at top Mangalore hospitals, or arrange 24/7 taxi dispatch.
        </p>

        {/* 4 Category Switcher Pills */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mt-4 pt-2">
          <button
            onClick={() => setActiveTab('resorts')}
            className={`py-2.5 px-3 rounded-2xl text-xs font-bold transition flex items-center justify-center gap-1.5 cursor-pointer ${
              activeTab === 'resorts'
                ? 'bg-amber-400 text-slate-950 shadow-md font-black'
                : 'bg-white/10 text-white hover:bg-white/20'
            }`}
          >
            <Building2 className="w-4 h-4 flex-shrink-0" />
            <span className="truncate">Resorts (5)</span>
          </button>

          <button
            onClick={() => setActiveTab('cars')}
            className={`py-2.5 px-3 rounded-2xl text-xs font-bold transition flex items-center justify-center gap-1.5 cursor-pointer ${
              activeTab === 'cars'
                ? 'bg-amber-400 text-slate-950 shadow-md font-black'
                : 'bg-white/10 text-white hover:bg-white/20'
            }`}
          >
            <Car className="w-4 h-4 flex-shrink-0" />
            <span className="truncate">Car Rental</span>
          </button>

          <button
            onClick={() => setActiveTab('hospitals')}
            className={`py-2.5 px-3 rounded-2xl text-xs font-bold transition flex items-center justify-center gap-1.5 cursor-pointer ${
              activeTab === 'hospitals'
                ? 'bg-amber-400 text-slate-950 shadow-md font-black'
                : 'bg-white/10 text-white hover:bg-white/20'
            }`}
          >
            <HospitalIcon className="w-4 h-4 flex-shrink-0" />
            <span className="truncate">Mangalore OPD</span>
          </button>

          <button
            onClick={() => setActiveTab('taxi')}
            className={`py-2.5 px-3 rounded-2xl text-xs font-bold transition flex items-center justify-center gap-1.5 cursor-pointer ${
              activeTab === 'taxi'
                ? 'bg-amber-400 text-slate-950 shadow-md font-black'
                : 'bg-white/10 text-white hover:bg-white/20'
            }`}
          >
            <CarFront className="w-4 h-4 flex-shrink-0" />
            <span className="truncate">Mangalore Taxi</span>
          </button>
        </div>
      </div>

      <div className="max-w-xl mx-auto px-4 mt-5 space-y-6">

        {/* ================================================== */}
        {/* SECTION 1: RESORTS FOR RENT (5 RESORTS) */}
        {/* ================================================== */}
        {activeTab === 'resorts' && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="font-display text-lg font-black text-brand-green-dark tracking-tight">
                  Resorts for Rent in &amp; around Bhatkal
                </h2>
                <p className="text-xs text-brand-light">
                  5 peaceful resort options for family members staying near hospital wards.
                </p>
              </div>
              <span className="bg-brand-green-light text-brand-green-dark text-[10px] font-black px-2.5 py-1 rounded-full">
                5 Available
              </span>
            </div>

            <div className="space-y-3.5">
              {RESORTS.map((resort) => (
                <div key={resort.id} className="bg-white rounded-3xl p-4 shadow-sm border border-brand-green-light/30 flex flex-col sm:flex-row gap-4 items-center">
                  <img 
                    src={resort.image} 
                    alt={resort.name} 
                    className="w-full sm:w-32 h-28 object-cover rounded-2xl border border-gray-100 flex-shrink-0"
                  />
                  <div className="flex-1 min-w-0 space-y-1.5 w-full">
                    <div className="flex justify-between items-start gap-2">
                      <h3 className="font-display text-sm font-black text-brand-dark leading-tight">{resort.name}</h3>
                      <div className="flex items-center gap-1 text-xs font-bold text-amber-500 bg-amber-50 px-2 py-0.5 rounded-md flex-shrink-0">
                        <Star className="w-3.5 h-3.5 fill-amber-500" />
                        <span>{resort.rating}</span>
                      </div>
                    </div>

                    <p className="text-[11px] text-brand-light flex items-center gap-1">
                      <MapPin className="w-3 h-3 text-brand-green-dark flex-shrink-0" />
                      <span className="truncate">{resort.location}</span>
                    </p>

                    <div className="flex flex-wrap gap-1 pt-1">
                      {resort.features.map((feat, idx) => (
                        <span key={idx} className="text-[9px] font-bold bg-brand-cream text-brand-green-dark px-2 py-0.5 rounded-full border border-brand-green-light/40">
                          ✓ {feat}
                        </span>
                      ))}
                    </div>

                    <div className="flex items-center justify-between pt-2 border-t border-gray-100 mt-2">
                      <div>
                        <span className="font-display text-base font-black text-brand-green-dark">₹{resort.pricePerNight}</span>
                        <span className="text-[10px] text-brand-light"> / night</span>
                      </div>

                      <div className="flex gap-2">
                        <a 
                          href={`tel:${resort.phone}`}
                          className="bg-brand-green-light text-brand-green-dark p-2 rounded-xl text-xs font-bold hover:bg-brand-green-light/80 transition"
                          title="Call Resort"
                        >
                          <Phone className="w-3.5 h-3.5" />
                        </a>
                        <button
                          onClick={() => setBookingModal({ open: true, title: resort.name, price: `₹${resort.pricePerNight}/night` })}
                          className="bg-brand-green-dark text-white px-3.5 py-1.5 rounded-xl text-xs font-bold hover:bg-brand-green-dark/90 transition shadow-sm cursor-pointer"
                        >
                          Book Stay
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ================================================== */}
        {/* SECTION 2: CAR FOR RENT */}
        {/* ================================================== */}
        {activeTab === 'cars' && (
          <div className="space-y-4">
            <div>
              <h2 className="font-display text-lg font-black text-brand-green-dark tracking-tight">
                Car for Rent (Self-Drive &amp; Chauffeur)
              </h2>
              <p className="text-xs text-brand-light">
                Clean, sanitized cars for patient transport, OPD visits &amp; family errands.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
              {CARS.map((car) => (
                <div key={car.id} className="bg-white rounded-3xl p-4 shadow-sm border border-brand-green-light/30 flex flex-col justify-between space-y-3">
                  <div className="space-y-2">
                    <img 
                      src={car.image} 
                      alt={car.name} 
                      className="w-full h-28 object-contain bg-brand-cream rounded-2xl p-2 border border-gray-100"
                    />
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-display text-sm font-black text-brand-dark">{car.name}</h3>
                        <span className="text-[10px] font-bold text-brand-light">{car.type} • {car.seats} Seats</span>
                      </div>
                      <span className="font-display text-base font-black text-brand-green-dark">₹{car.pricePerDay}<span className="text-[10px] text-brand-light font-normal">/day</span></span>
                    </div>

                    <ul className="space-y-1 pt-1">
                      {car.perks.map((perk, i) => (
                        <li key={i} className="text-[10px] font-medium text-brand-dark flex items-center gap-1.5">
                          <CheckCircle className="w-3 h-3 text-brand-green-medium flex-shrink-0" />
                          <span>{perk}</span>
                        </li>
                      ))}
                    </ul>
                  </div>

                  <button
                    onClick={() => setBookingModal({ open: true, title: car.name, price: `₹${car.pricePerDay}/day` })}
                    className="w-full bg-brand-green-dark hover:bg-brand-green-dark/90 text-white text-xs font-bold py-2.5 rounded-xl transition shadow-sm cursor-pointer uppercase tracking-wider"
                  >
                    Reserve Car Now
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ================================================== */}
        {/* SECTION 3: MANGALORE HOSPITAL BOOKING */}
        {/* ================================================== */}
        {activeTab === 'hospitals' && (
          <div className="space-y-4">
            <div>
              <h2 className="font-display text-lg font-black text-brand-green-dark tracking-tight">
                Booking of Hospital in Mangalore
              </h2>
              <p className="text-xs text-brand-light">
                Direct OPD consultation slots, specialist doctor appointments &amp; bed reservations.
              </p>
            </div>

            <div className="space-y-3.5">
              {MANGALORE_HOSPITALS.map((hosp) => (
                <div key={hosp.id} className="bg-white rounded-3xl p-4 shadow-sm border border-brand-green-light/30 flex flex-col sm:flex-row gap-4 items-center">
                  <img 
                    src={hosp.image} 
                    alt={hosp.name} 
                    className="w-full sm:w-32 h-28 object-contain bg-slate-50 p-1 rounded-2xl border border-gray-100 flex-shrink-0"
                  />
                  <div className="flex-1 min-w-0 space-y-1.5 w-full">
                    <div className="flex justify-between items-start gap-2">
                      <h3 className="font-display text-sm font-black text-brand-dark">{hosp.name}</h3>
                      <span className="text-xs font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-md flex-shrink-0">
                        ⭐ {hosp.rating}
                      </span>
                    </div>

                    <p className="text-[11px] text-brand-light flex items-center gap-1">
                      <MapPin className="w-3 h-3 text-brand-green-dark flex-shrink-0" />
                      <span>{hosp.location}</span>
                    </p>

                    <div className="flex flex-wrap gap-1 pt-1">
                      {hosp.specialties.map((spec, idx) => (
                        <span key={idx} className="text-[9px] font-bold bg-blue-50 text-blue-800 px-2 py-0.5 rounded-full border border-blue-100">
                          {spec}
                        </span>
                      ))}
                    </div>

                    <div className="flex items-center justify-between pt-2 border-t border-gray-100 mt-2">
                      <span className="text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-1 rounded-md">
                        ✓ Verified OPD Partner
                      </span>

                      <button
                        onClick={() => setBookingModal({ open: true, title: `OPD Consultation: ${hosp.name}`, price: '₹300 Doctor Fee' })}
                        className="bg-brand-green-dark text-white px-3.5 py-1.5 rounded-xl text-xs font-bold hover:bg-brand-green-dark/90 transition shadow-sm cursor-pointer"
                      >
                        Book Appointment
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* ================================================== */}
        {/* SECTION 4: TAXI SERVICE TO MANGALORE */}
        {/* ================================================== */}
        {activeTab === 'taxi' && (
          <div className="space-y-4">
            <div>
              <h2 className="font-display text-lg font-black text-brand-green-dark tracking-tight">
                Taxi Service to Mangalore (Bhatkal &rarr; Mangalore)
              </h2>
              <p className="text-xs text-brand-light">
                24/7 express door-to-door hospital cab &amp; emergency transport (140 km / 2.5 hrs).
              </p>
            </div>

            {/* Taxi Rates Cards */}
            <div className="space-y-3">
              {TAXI_RATES.map((rate, i) => (
                <div key={i} className="bg-white rounded-3xl p-4 shadow-sm border border-brand-green-light/30 flex flex-col sm:flex-row items-center justify-between gap-3">
                  <div className="space-y-1 w-full sm:w-auto">
                    <span className="text-[10px] font-black uppercase tracking-wider text-amber-700 bg-amber-50 px-2.5 py-0.5 rounded-full">
                      Fixed Hospital Fare
                    </span>
                    <h3 className="font-display text-sm font-black text-brand-dark mt-1">{rate.type}</h3>
                    <p className="text-[11px] text-brand-light leading-snug max-w-sm">{rate.notes}</p>
                    <span className="text-[10px] font-bold text-brand-green-dark flex items-center gap-1 mt-1">
                      <Clock className="w-3 h-3" /> Duration: {rate.duration}
                    </span>
                  </div>

                  <div className="text-right flex sm:flex-col items-center sm:items-end justify-between w-full sm:w-auto pt-2 sm:pt-0 border-t sm:border-0 border-gray-100 flex-shrink-0">
                    <div>
                      <span className="font-display text-xl font-black text-brand-green-dark">₹{rate.bhatkalToMangalorePrice}</span>
                      <span className="text-[10px] font-medium text-brand-light block">Flat One-Way</span>
                    </div>
                    <button
                      onClick={() => setBookingModal({ open: true, title: `Mangalore Taxi: ${rate.type}`, price: `₹${rate.bhatkalToMangalorePrice}` })}
                      className="bg-amber-500 hover:bg-amber-400 text-slate-950 px-4 py-2 rounded-xl text-xs font-black transition shadow-sm cursor-pointer mt-2"
                    >
                      Dispatch Cab
                    </button>
                  </div>
                </div>
              ))}
            </div>

            {/* Emergency Hotline Box */}
            <div className="bg-gradient-to-r from-red-600 to-rose-700 text-white rounded-3xl p-4 shadow-md flex items-center justify-between gap-3">
              <div className="space-y-1">
                <span className="text-[10px] font-black uppercase tracking-wider bg-white/20 px-2 py-0.5 rounded-full">
                  24/7 Emergency Dispatch
                </span>
                <h4 className="font-display text-sm font-black">Need Urgent Mangalore Ambulance / Taxi?</h4>
                <p className="text-[11px] text-rose-100">Immediate driver pickup from any ward or doorstep in Bhatkal.</p>
              </div>
              <a 
                href="tel:+918884070557"
                className="bg-white text-rose-700 font-black text-xs px-4 py-3 rounded-2xl shadow hover:bg-rose-50 transition flex items-center gap-1.5 flex-shrink-0"
              >
                <Phone className="w-4 h-4 fill-rose-700" />
                <span>Call Hotline</span>
              </a>
            </div>
          </div>
        )}

      </div>

      {/* ================================================== */}
      {/* INSTANT BOOKING MODAL */}
      {/* ================================================== */}
      {bookingModal.open && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-3xl p-6 max-w-sm w-full shadow-2xl border border-gray-100 animate-fade-in text-brand-dark space-y-4">
            
            {bookingSuccess ? (
              <div className="text-center py-6 space-y-3">
                <div className="w-14 h-14 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto">
                  <CheckCircle className="w-8 h-8" />
                </div>
                <h3 className="font-display text-lg font-black text-brand-green-dark">Booking Dispatched!</h3>
                <p className="text-xs text-brand-light">
                  Your request for <strong>{bookingModal.title}</strong> has been logged. Our service representative will call you immediately on <strong>+91 {phoneInput || '8884070557'}</strong>.
                </p>
              </div>
            ) : (
              <>
                <div className="flex justify-between items-start border-b border-gray-100 pb-3">
                  <div>
                    <span className="text-[10px] font-black uppercase tracking-wider text-brand-orange bg-amber-50 px-2 py-0.5 rounded-md">
                      Instant Reservation
                    </span>
                    <h3 className="font-display text-base font-black text-brand-green-dark mt-1">
                      {bookingModal.title}
                    </h3>
                  </div>
                  <button 
                    onClick={() => setBookingModal({ open: false, title: '', price: '' })}
                    className="text-gray-400 hover:text-gray-600 font-bold"
                  >
                    ✕
                  </button>
                </div>

                <div className="bg-brand-cream p-3 rounded-2xl border border-brand-green-light/30 text-xs flex justify-between items-center">
                  <span className="font-semibold text-brand-dark">Service Price:</span>
                  <span className="font-black text-brand-green-dark text-sm">{bookingModal.price}</span>
                </div>

                <form onSubmit={handleBookingSubmit} className="space-y-3">
                  <div>
                    <label className="text-[10px] font-bold uppercase text-brand-light block mb-1">Your Name / Guest Name</label>
                    <input 
                      type="text" 
                      required
                      placeholder="e.g. Mohammed Ashhad"
                      value={patientName}
                      onChange={(e) => setPatientName(e.target.value)}
                      className="w-full p-3 bg-brand-cream rounded-xl text-xs font-semibold focus:bg-white focus:ring-2 focus:ring-brand-green-light border-transparent"
                    />
                  </div>

                  <div>
                    <label className="text-[10px] font-bold uppercase text-brand-light block mb-1">Mobile Phone Number</label>
                    <input 
                      type="tel" 
                      required
                      placeholder="10 digit mobile number"
                      value={phoneInput}
                      onChange={(e) => setPhoneInput(e.target.value)}
                      className="w-full p-3 bg-brand-cream rounded-xl text-xs font-semibold focus:bg-white focus:ring-2 focus:ring-brand-green-light border-transparent"
                    />
                  </div>

                  <div className="pt-2 flex gap-2">
                    <button
                      type="button"
                      onClick={() => setBookingModal({ open: false, title: '', price: '' })}
                      className="w-1/3 py-2.5 bg-gray-100 hover:bg-gray-200 text-brand-light text-xs font-bold rounded-xl transition cursor-pointer"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="w-2/3 py-2.5 bg-brand-green-dark hover:bg-brand-green-dark/90 text-white text-xs font-bold rounded-xl transition shadow cursor-pointer uppercase tracking-wider"
                    >
                      Confirm Booking
                    </button>
                  </div>
                </form>
              </>
            )}

          </div>
        </div>
      )}

    </div>
  );
};
