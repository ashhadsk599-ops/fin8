import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { HOSPITALS } from '../data';
import { auth } from '../firebase';
import { RecaptchaVerifier, signInWithPhoneNumber, ConfirmationResult } from 'firebase/auth';
import { 
  ChevronRight, Phone, Lock, Heart, ShieldAlert, Sparkles, UserCheck, 
  Hospital as HospitalIcon, BedDouble, Stethoscope, ArrowLeft, Mail, RefreshCw
} from 'lucide-react';
import { motion } from 'motion/react';

declare global {
  interface Window {
    recaptchaVerifier: any;
  }
}

export const SplashOnboardingLogin: React.FC = () => {
  const { 
    screen, navigateTo, loginAsGuest, user, cart,
    completeSignup, goBack, screenHistory
  } = useApp();

  // Splash Screen Timer
  useEffect(() => {
    if (screen === 'splash') {
      const timer = setTimeout(() => {
        if (!user) {
          loginAsGuest(false);
        }
        navigateTo('home');
      }, 2500);
      return () => clearTimeout(timer);
    }
  }, [screen, user, navigateTo, loginAsGuest]);

  // Sign Up 2-Slide States
  const [slide, setSlide] = useState<1 | 2>(1);
  
  // Slide 1 Form Fields
  const [role, setRole] = useState<'Patient' | 'Hospital Staff'>('Patient');
  const [fullName, setFullName] = useState('');
  const [selectedHospitalId, setSelectedHospitalId] = useState<string>(HOSPITALS[0].id);
  const [roomNo, setRoomNo] = useState('G-102');
  const [illness, setIllness] = useState('Diabetic & Low Sugar');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [email, setEmail] = useState('');
  const [formError, setFormError] = useState('');

  // Slide 2 Form Fields
  const [otpCode, setOtpCode] = useState('');
  const [generatedOtp, setGeneratedOtp] = useState('123456');
  const [confirmationResult, setConfirmationResult] = useState<ConfirmationResult | null>(null);
  const [firebaseSending, setFirebaseSending] = useState(false);
  const [resendTimer, setResendTimer] = useState(30);
  const [canResend, setCanResend] = useState(false);
  const [otpError, setOtpError] = useState('');
  const [loading, setLoading] = useState(false);
  const [agreeToTerms, setAgreeToTerms] = useState(true);
  const [showPrivacyModal, setShowPrivacyModal] = useState(false);

  // Timer countdown for Resend SMS
  useEffect(() => {
    let interval: any = null;
    if (slide === 2 && resendTimer > 0) {
      interval = setInterval(() => {
        setResendTimer(prev => {
          if (prev <= 1) {
            setCanResend(true);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [slide, resendTimer]);

  const handleSendOtp = async () => {
    setResendTimer(45);
    setCanResend(false);
    setOtpError('');
    setFirebaseSending(true);

    try {
      if (window.recaptchaVerifier) {
        try { window.recaptchaVerifier.clear(); } catch (e) {}
        window.recaptchaVerifier = null;
      }

      window.recaptchaVerifier = new RecaptchaVerifier(auth, 'recaptcha-container', {
        'size': 'invisible',
        'callback': () => {},
        'expired-callback': () => {
          try { window.recaptchaVerifier?.clear(); } catch (e) {}
          window.recaptchaVerifier = null;
        }
      });

      const cleanPhone = phoneNumber.replace(/\D/g, '');
      const formattedPhone = '+91' + cleanPhone;

      const confirmation = await signInWithPhoneNumber(auth, formattedPhone, window.recaptchaVerifier);
      setConfirmationResult(confirmation);
      setFirebaseSending(false);
    } catch (err: any) {
      console.error("Firebase Phone Auth error:", err);
      setFirebaseSending(false);
      setConfirmationResult(null);
      if (window.recaptchaVerifier) {
        try { window.recaptchaVerifier.clear(); } catch (e) {}
        window.recaptchaVerifier = null;
      }

      let errorMsg = 'Could not dispatch SMS. ';
      if (err?.code === 'auth/operation-not-allowed') {
        errorMsg = 'Firebase Phone Auth is disabled. Enable "Phone" in Firebase Console -> Authentication -> Sign-in method.';
      } else if (err?.code === 'auth/invalid-app-credential' || err?.code === 'auth/unauthorized-domain') {
        errorMsg = `Domain (${window.location.hostname}) is not in Firebase Authorized Domains. Add it in Firebase Console -> Authentication -> Settings -> Authorized Domains.`;
      } else if (err?.code === 'auth/invalid-phone-number') {
        errorMsg = 'Invalid phone number format. Please check the 10-digit mobile number.';
      } else if (err?.code === 'auth/quota-exceeded') {
        errorMsg = 'Daily SMS quota exceeded in Firebase. Please try again later or check Firebase billing.';
      } else if (err?.message) {
        errorMsg += err.message;
      } else {
        errorMsg += 'Please check your mobile connection or try again.';
      }
      setOtpError(errorMsg);
    }
  };

  // Illness choices list
  const illnessOptions = [
    'Diabetic & Low Sugar',
    'Hypertension (Low Salt)',
    'Post-Surgery Recovery (Soft Diet)',
    'Kidney Care (Low Protein)',
    'Gastric & Low Spice',
    'General Recovery & Wellness'
  ];

  const handleNextSlide = (e: React.FormEvent) => {
    e.preventDefault();
    if (!fullName.trim()) {
      setFormError('Please enter your full name');
      return;
    }
    const cleanPhone = phoneNumber.replace(/\D/g, '');
    if (cleanPhone.length !== 10 || !/^[6-9]\d{9}$/.test(cleanPhone)) {
      setFormError('Please enter a valid 10-digit Indian mobile number (e.g. 9876543210)');
      return;
    }
    if (!roomNo.trim()) {
      setFormError('Please enter your room or ward number');
      return;
    }
    setFormError('');

    setOtpCode('');
    setSlide(2);
    handleSendOtp();
  };

  const finishSignup = () => {
    setLoading(false);
    const matchedHosp = HOSPITALS.find(h => h.id === selectedHospitalId) || HOSPITALS[0];

    completeSignup({
      phone: phoneNumber,
      email: email.trim() || undefined,
      role: role === 'Patient' ? 'Patient' : 'Employee',
      hospital: matchedHosp,
      patientDetails: role === 'Patient' ? {
        patientName: fullName.trim() || 'Admitted Patient',
        roomNumber: roomNo,
        ward: 'General Ward',
        diagnosis: illness,
        attendingDoctor: 'Dr. Abdul'
      } : undefined,
      employeeDetails: role !== 'Patient' ? {
        employeeName: fullName.trim() || 'Hospital Staff',
        employeeId: 'EMP-' + Math.floor(1000 + Math.random() * 9000),
        department: 'Ward Management'
      } : undefined
    });

    if (cart && cart.length > 0) {
      navigateTo('cart');
    } else {
      navigateTo('home');
    }
  };

  const handleVerifyOtpAndComplete = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanCode = otpCode.trim();
    if (cleanCode.length !== 6) {
      setOtpError('Please enter the complete 6-digit SMS code sent to your phone');
      return;
    }
    setOtpError('');
    setLoading(true);

    if (confirmationResult) {
      try {
        await confirmationResult.confirm(cleanCode);
        finishSignup();
      } catch (err: any) {
        setLoading(false);
        console.error("Firebase OTP Verification Error:", err);
        if (err?.code === 'auth/invalid-verification-code') {
          setOtpError('Invalid OTP code. Please enter the 6-digit code received via SMS.');
        } else if (err?.code === 'auth/code-expired') {
          setOtpError('The OTP code has expired. Please click "Resend SMS OTP" to request a new code.');
        } else {
          setOtpError('Verification failed. Please re-enter the 6-digit SMS code or request a new code.');
        }
      }
    } else {
      setLoading(false);
      setOtpError('No SMS verification session found. Please click "Resend SMS OTP" to dispatch a new code.');
    }
  };

  // Render Splash Screen
  if (screen === 'splash') {
    return (
      <div id="splash-screen" className="fixed inset-0 flex flex-col items-center justify-center bg-gradient-to-b from-brand-cream to-brand-green-light select-none overflow-y-auto z-50 py-8 px-4">
        <div className="relative flex flex-col items-center p-6 text-center animate-fade-in max-w-md mx-auto">
          <motion.div 
            animate={{ scale: [1, 1.05, 1] }}
            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
            className="relative flex items-center justify-center w-28 h-28 bg-white rounded-full shadow-lg border border-brand-green-light/40 mb-5 p-1 overflow-hidden"
          >
            <img src="/logo.png?v=5" className="w-full h-full rounded-full object-contain" referrerPolicy="no-referrer" alt="Cura Meal Logo" />
            <div className="absolute -inset-1 rounded-full border-2 border-brand-green-medium opacity-25 animate-ping pointer-events-none" />
          </motion.div>
          
          <h1 className="text-4xl font-black tracking-tight text-brand-green-dark mb-1">
            Cura Meal
          </h1>
          <p className="text-xs font-semibold tracking-widest text-brand-green-medium uppercase mb-5">
            Clinical Nutrition. Served Warm.
          </p>

          <div className="w-full bg-white/80 backdrop-blur-md p-4 rounded-3xl border border-white shadow-md mb-5">
            <p className="text-[10px] font-black tracking-wider text-brand-green-dark uppercase mb-3 text-center">
              Partnered with 5 Premier Hospitals
            </p>
            <div className="grid grid-cols-5 gap-1.5 justify-center">
              {[
                { name: 'Welfare', initials: 'WF', color: 'bg-emerald-600' },
                { name: 'Shams Noor', initials: 'SN', color: 'bg-sky-500' },
                { name: 'Lifecare', initials: 'LC', color: 'bg-rose-500' },
                { name: 'Asiya', initials: 'AS', color: 'bg-purple-500' },
                { name: 'Government', initials: 'GH', color: 'bg-slate-500' },
              ].map((hosp, i) => (
                <div key={i} className="flex flex-col items-center gap-1.5 bg-brand-cream/45 p-1.5 rounded-xl border border-brand-green-light/10 transition-all hover:scale-105">
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-[10px] text-white ${hosp.color} shadow-md`}>
                    {hosp.initials}
                  </div>
                  <span className="text-[8px] font-black text-brand-green-dark text-center leading-tight truncate w-full">
                    {hosp.name}
                  </span>
                </div>
              ))}
            </div>
          </div>
          
          <div className="w-12 h-1 bg-brand-orange rounded-full animate-pulse mb-5" />
          
          <p className="text-sm font-medium text-brand-light max-w-xs leading-relaxed mb-6">
            Double-Sanitized Bedside Meals Delivered in Hot Containers
          </p>
        </div>
        
        <div className="mt-8 text-center text-[10px] text-brand-light/70 font-semibold uppercase tracking-wider">
          Dietary Delivery Network • Bhatkal, KA
        </div>
      </div>
    );
  }

  // Render 2-Slide Sign Up / Login Screen
  return (
    <div id="signup-screen" className="min-h-screen bg-brand-cream text-brand-dark flex flex-col justify-between px-4 sm:px-6 py-6 relative">
      
      {/* Firebase Invisible Recaptcha Container */}
      <div id="recaptcha-container"></div>

      {/* Header */}
      <div className="flex items-center justify-between max-w-md mx-auto w-full">
        <div className="flex items-center gap-2">
          {screenHistory.length > 1 && (
            <button onClick={goBack} className="p-1 text-brand-dark hover:text-brand-green-dark cursor-pointer mr-1">
              <ArrowLeft className="w-5 h-5" />
            </button>
          )}
          <img src="/logo.png?v=5" className="w-6 h-6 rounded-md object-contain" referrerPolicy="no-referrer" alt="Cura Meal" />
          <span className="font-display font-black text-brand-green-dark text-xl tracking-tight">Cura Meal</span>
        </div>

        {/* Slide Step indicator pills */}
        <div className="flex items-center gap-1.5 bg-white px-3 py-1 rounded-full border border-brand-green-light/30 shadow-xs">
          <span className={`w-2.5 h-2.5 rounded-full transition-all ${slide === 1 ? 'bg-brand-green-dark scale-110' : 'bg-gray-200'}`} />
          <span className={`w-2.5 h-2.5 rounded-full transition-all ${slide === 2 ? 'bg-brand-green-dark scale-110' : 'bg-gray-200'}`} />
          <span className="text-[10px] font-bold text-brand-light ml-1">Slide {slide}/2</span>
        </div>
      </div>

      <div className="max-w-md mx-auto w-full my-auto py-4">
        
        {/* Card Title Header */}
        <div className="text-center mb-5">
          <h2 className="font-display text-2xl font-black text-brand-green-dark tracking-tight">
            {slide === 1 ? 'Bedside Registration' : 'Verify Mobile OTP'}
          </h2>
          <p className="text-xs text-brand-light mt-1">
            {slide === 1 
              ? 'Configure your bedside coordinates & dietary condition for safe meal delivery.'
              : `Enter verification code sent to +91 ${phoneNumber}`}
          </p>
        </div>

        {/* Sign Up Form Box */}
        <div className="bg-white rounded-3xl p-5 shadow-xl border border-brand-green-light/30 space-y-4">
          
          {/* SLIDE 1: Profile & Bedside Coordinates */}
          {slide === 1 ? (
            <form onSubmit={handleNextSlide} className="space-y-4">
              
              {/* Role Option: Patient vs Hospital Staff */}
              <div>
                <label className="block text-[11px] font-black text-brand-green-dark uppercase tracking-wider mb-1.5">
                  1. Select Role
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setRole('Patient')}
                    className={`p-3 rounded-2xl border text-center font-bold text-xs transition flex flex-col items-center gap-1 cursor-pointer ${
                      role === 'Patient'
                        ? 'bg-brand-green-light/30 border-brand-green-medium text-brand-green-dark shadow-sm'
                        : 'bg-brand-cream/50 border-gray-100 text-brand-dark hover:bg-gray-100'
                    }`}
                  >
                    <BedDouble className="w-5 h-5 text-brand-green-dark" />
                    <span>Patient</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setRole('Hospital Staff')}
                    className={`p-3 rounded-2xl border text-center font-bold text-xs transition flex flex-col items-center gap-1 cursor-pointer ${
                      role === 'Hospital Staff'
                        ? 'bg-brand-green-light/30 border-brand-green-medium text-brand-green-dark shadow-sm'
                        : 'bg-brand-cream/50 border-gray-100 text-brand-dark hover:bg-gray-100'
                    }`}
                  >
                    <Stethoscope className="w-5 h-5 text-brand-orange" />
                    <span>Hospital Staff</span>
                  </button>
                </div>
              </div>

              {/* Full Name */}
              <div>
                <label className="block text-[11px] font-black text-brand-green-dark uppercase tracking-wider mb-1">
                  2. Full Name ({role === 'Patient' ? 'Patient Name' : 'Staff Name'})
                </label>
                <input
                  type="text"
                  required
                  placeholder={role === 'Patient' ? 'e.g. Mohammed Ashhad' : 'e.g. Nurse Sarah'}
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-xs font-bold text-brand-dark focus:bg-white focus:ring-2 focus:ring-brand-green-medium transition"
                />
              </div>

              {/* Hospital Address / Selector */}
              <div>
                <label className="block text-[11px] font-black text-brand-green-dark uppercase tracking-wider mb-1">
                  3. Hospital Address / Hospital Name
                </label>
                <div className="relative">
                  <HospitalIcon className="w-4 h-4 text-brand-green-medium absolute left-3 top-3 pointer-events-none" />
                  <select
                    value={selectedHospitalId}
                    onChange={(e) => setSelectedHospitalId(e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-xs font-bold text-brand-dark focus:bg-white focus:ring-2 focus:ring-brand-green-medium transition cursor-pointer"
                  >
                    {HOSPITALS.map((hosp) => (
                      <option key={hosp.id} value={hosp.id}>
                        {hosp.name} ({hosp.location})
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Room / Bed Number */}
              <div>
                <label className="block text-[11px] font-black text-brand-green-dark uppercase tracking-wider mb-1">
                  4. Room / Bed Number
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Room G-102, Ward B"
                  value={roomNo}
                  onChange={(e) => setRoomNo(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-xs font-bold text-brand-dark focus:bg-white focus:ring-2 focus:ring-brand-green-medium transition"
                />
              </div>

              {/* Illness / Diet Condition options */}
              <div>
                <label className="block text-[11px] font-black text-brand-green-dark uppercase tracking-wider mb-1">
                  5. Clinical Condition / Dietary Need
                </label>
                <select
                  value={illness}
                  onChange={(e) => setIllness(e.target.value)}
                  className="w-full px-3.5 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-xs font-bold text-brand-dark focus:bg-white focus:ring-2 focus:ring-brand-green-medium transition cursor-pointer"
                >
                  {illnessOptions.map((opt, i) => (
                    <option key={i} value={opt}>
                      {opt}
                    </option>
                  ))}
                </select>
              </div>

              {/* Mobile Phone Number */}
              <div>
                <label className="block text-[11px] font-black text-brand-green-dark uppercase tracking-wider mb-1">
                  6. Mobile Phone Number
                </label>
                <div className="relative">
                  <Phone className="w-4 h-4 text-brand-green-medium absolute left-3 top-3 pointer-events-none" />
                  <input
                    type="tel"
                    required
                    maxLength={10}
                    placeholder="Enter 10-digit mobile number"
                    value={phoneNumber}
                    onChange={(e) => {
                      const val = e.target.value.replace(/\D/g, '');
                      setPhoneNumber(val);
                      if (val.length === 10) setFormError('');
                    }}
                    className="w-full pl-9 pr-3 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-xs font-bold text-brand-dark focus:bg-white focus:ring-2 focus:ring-brand-green-medium transition"
                  />
                </div>
              </div>

              {/* Email Address (Optional for Digital Receipts) */}
              <div>
                <label className="block text-[11px] font-black text-brand-green-dark uppercase tracking-wider mb-1">
                  7. Email Address <span className="text-[10px] text-brand-light font-medium">(Optional for Digital Receipts)</span>
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-brand-green-medium absolute left-3 top-3 pointer-events-none" />
                  <input
                    type="email"
                    placeholder="e.g. user@gmail.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-xs font-bold text-brand-dark focus:bg-white focus:ring-2 focus:ring-brand-green-medium transition"
                  />
                </div>
              </div>

              {/* Privacy Policy & Terms Agreement Checkbox */}
              <div className="flex items-start gap-2 bg-brand-cream/60 p-3 rounded-2xl border border-brand-green-light/30">
                <input
                  type="checkbox"
                  id="agreeToTermsWeb"
                  required
                  checked={agreeToTerms}
                  onChange={(e) => setAgreeToTerms(e.target.checked)}
                  className="mt-0.5 rounded text-brand-green-dark focus:ring-brand-green-medium cursor-pointer"
                />
                <label htmlFor="agreeToTermsWeb" className="text-[11px] text-brand-light leading-snug cursor-pointer select-none">
                  I accept the{' '}
                  <button
                    type="button"
                    onClick={() => setShowPrivacyModal(true)}
                    className="font-bold text-brand-green-dark hover:underline inline-flex items-center gap-0.5"
                  >
                    Privacy Policy & Clinical Terms
                  </button>
                  {' '}for bedside meal delivery service.
                </label>
              </div>

              {formError && (
                <p className="text-xs text-brand-error font-semibold flex items-center gap-1">
                  <ShieldAlert className="w-3.5 h-3.5" /> {formError}
                </p>
              )}

              {/* Slide 1 Next Button */}
              <button
                type="submit"
                className="w-full bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-extrabold text-sm py-3.5 rounded-xl shadow-md transition flex items-center justify-center gap-2 cursor-pointer mt-2"
              >
                <span>Send Mobile SMS OTP</span>
                <ChevronRight className="w-4 h-4" />
              </button>

            </form>
          ) : (
            /* SLIDE 2: OTP Verification */
            <form onSubmit={handleVerifyOtpAndComplete} className="space-y-4">
              
              {/* Phone SMS Status Banner */}
              <div className="bg-emerald-50 border border-emerald-200/80 rounded-2xl p-4 text-center text-xs text-emerald-950 space-y-2 shadow-xs">
                <div className="flex items-center justify-center gap-1.5 text-emerald-800 font-extrabold">
                  <Phone className="w-4 h-4 text-emerald-600 animate-pulse" />
                  <span>SMS Code Dispatched</span>
                </div>
                <p className="text-xs text-emerald-900 font-medium">
                  Sent to: <strong className="font-black text-emerald-950">+91 {phoneNumber}</strong>
                </p>
                <p className="text-[11px] text-emerald-700/90 font-medium">
                  Please enter the 6-digit SMS verification code received on your mobile phone.
                </p>
              </div>

              <div>
                <label className="block text-xs font-extrabold text-brand-green-dark uppercase tracking-wider mb-2">
                  Enter 6-Digit OTP Code
                </label>
                <div className="relative">
                  <Lock className="w-5 h-5 text-brand-green-medium absolute left-3 top-3.5 pointer-events-none" />
                  <input
                    type="text"
                    required
                    maxLength={6}
                    placeholder="• • • • • •"
                    value={otpCode}
                    onChange={(e) => {
                      const val = e.target.value.replace(/\D/g, '');
                      setOtpCode(val);
                      if (val.length === 6) setOtpError('');
                    }}
                    className="w-full pl-10 pr-3 py-3.5 text-center tracking-[0.5em] border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:ring-2 focus:ring-brand-green-medium text-base font-black transition"
                  />
                </div>
                {otpError && (
                  <p className="text-xs text-brand-error font-semibold mt-1.5 flex items-center gap-1">
                    <ShieldAlert className="w-3.5 h-3.5" /> {otpError}
                  </p>
                )}
              </div>

              <div className="flex items-center justify-between text-xs px-1 pt-1">
                <button
                  type="button"
                  onClick={() => setSlide(1)}
                  className="font-bold text-brand-green-dark hover:underline flex items-center gap-1 cursor-pointer"
                >
                  <ArrowLeft className="w-3.5 h-3.5" /> Edit Mobile No.
                </button>

                <button
                  type="button"
                  disabled={!canResend}
                  onClick={handleSendOtp}
                  className={`font-black flex items-center gap-1 transition ${canResend ? 'text-brand-orange hover:underline cursor-pointer' : 'text-gray-400 cursor-not-allowed'}`}
                >
                  {canResend ? 'Resend SMS OTP' : `Resend in ${resendTimer}s`}
                </button>
              </div>

              {/* Verify & Enter App Button */}
              <button
                type="submit"
                disabled={loading}
                className="w-full bg-brand-orange hover:bg-brand-orange/95 text-white font-black text-sm py-3.5 rounded-xl shadow-md transition flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50 mt-2"
              >
                {loading ? (
                  <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                ) : (
                  <>
                    <UserCheck className="w-4 h-4" />
                    <span>Confirm & Enter App</span>
                  </>
                )}
              </button>

            </form>
          )}

          {/* Divider */}
          <div className="relative my-4 text-center">
            <span className="absolute inset-x-0 top-1/2 -translate-y-1/2 border-t border-gray-100" />
            <span className="relative bg-white px-3 text-[10px] text-brand-light font-bold uppercase tracking-wider">
              Or
            </span>
          </div>

          {/* Quick Skip Guest Entry */}
          <button
            type="button"
            onClick={() => loginAsGuest(true)}
            className="w-full bg-brand-cream border border-brand-green-medium/25 hover:bg-brand-green-light/20 text-brand-green-dark font-bold text-xs py-2.5 rounded-xl transition flex items-center justify-center gap-2 cursor-pointer"
          >
            <Sparkles className="w-4 h-4 text-brand-orange fill-brand-orange/20" />
            <span>Continue as Guest</span>
          </button>

        </div>
      </div>

      <div className="text-center max-w-xs mx-auto text-[10px] text-brand-light/70 font-semibold uppercase tracking-wider">
        Double-Sanitized Bedside Delivery • Bhatkal
      </div>

      {/* Privacy Policy & Terms Modal */}
      {showPrivacyModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-3xl p-6 max-w-md w-full shadow-2xl border border-brand-green-light/30 text-brand-dark animate-fade-in max-h-[80vh] flex flex-col">
            <div className="flex justify-between items-center pb-3 border-b border-gray-100">
              <h3 className="text-sm font-black text-brand-green-dark uppercase tracking-wider flex items-center gap-2">
                🔒 Privacy Policy & Clinical Terms
              </h3>
              <button
                onClick={() => setShowPrivacyModal(false)}
                className="text-gray-400 hover:text-brand-dark font-bold text-base cursor-pointer"
              >
                ✕
              </button>
            </div>
            
            <div className="overflow-y-auto py-4 space-y-3 text-xs text-brand-light leading-relaxed">
              <p className="font-semibold text-brand-dark">
                Welcome to Cura Meal. We prioritize patient confidentiality, medical diet compliance, and secure bedside delivery.
              </p>

              <div>
                <h4 className="font-bold text-brand-green-dark">1. Patient Data & Bed Coordinates</h4>
                <p>
                  Your hospital name, ward, room number, and dietary restrictions are strictly used by licensed kitchen nutritionists and delivery team to prepare and fulfill clinical meals safely.
                </p>
              </div>

              <div>
                <h4 className="font-bold text-brand-green-dark">2. Mobile OTP Verification</h4>
                <p>
                  Mobile phone numbers are used solely for identity verification and order status updates via SMS dispatch.
                </p>
              </div>

              <div>
                <h4 className="font-bold text-brand-green-dark">3. Hygiene & Sterile Protocols</h4>
                <p>
                  All meals are prepared in double-sanitized kitchen zones adhering to Bhatkal hospital dietary standards.
                </p>
              </div>

              <div>
                <h4 className="font-bold text-brand-green-dark">4. Privacy Protection</h4>
                <p>
                  We do not sell, rent, or share personal health data or mobile numbers with third-party advertising services.
                </p>
              </div>
            </div>

            <div className="pt-3 border-t border-gray-100 flex justify-end">
              <button
                onClick={() => {
                  setAgreeToTerms(true);
                  setShowPrivacyModal(false);
                }}
                className="bg-brand-green-dark hover:bg-brand-green-dark/90 text-white font-extrabold text-xs px-5 py-2.5 rounded-xl transition cursor-pointer"
              >
                Accept & Close
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};
