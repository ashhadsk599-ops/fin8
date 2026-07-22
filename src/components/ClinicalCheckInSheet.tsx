import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { HOSPITALS } from '../data';
import { X, Smartphone, Check, ShieldAlert, Sparkles, MapPin, Award, Send, ArrowLeft } from 'lucide-react';

interface ClinicalCheckInSheetProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  subtitle?: string;
  onComplete?: () => void;
}

export const ClinicalCheckInSheet: React.FC<ClinicalCheckInSheetProps> = ({
  isOpen,
  onClose,
  title = "Bedside Registration",
  subtitle = "Configure your bedside coordinates & dietary condition for safe meal delivery.",
  onComplete
}) => {
  const { 
    user, 
    selectedHospital, 
    selectHospital, 
    setPatientDetails, 
    setEmployeeDetails, 
    loginWithPhone,
    setUserRole
  } = useApp();

  const [slide, setSlide] = useState<1 | 2>(1);
  const [role, setRole] = useState<'Patient' | 'Hospital Staff'>('Patient');
  const [selectedHospitalId, setSelectedHospitalId] = useState<string>(selectedHospital?.id || HOSPITALS[0].id);
  const [patientName, setPatientName] = useState(user?.patientDetails?.patientName || '');
  const [roomNo, setRoomNo] = useState(user?.patientDetails?.roomNumber || 'G-102');
  const [illness, setIllness] = useState(user?.patientDetails?.diagnosis || 'Diabetic & Low Sugar');
  const [phoneNumber, setPhoneNumber] = useState(user?.phone && user.phone !== 'Guest' ? user.phone : '');
  const [formError, setFormError] = useState('');

  // Staff details
  const [employeeName, setEmployeeName] = useState(user?.employeeDetails?.employeeName || '');
  const [department, setDepartment] = useState(user?.employeeDetails?.department || 'Ward Staff');

  // Slide 2 OTP
  const [otpCode, setOtpCode] = useState('');
  const [otpError, setOtpError] = useState('');
  const [loading, setLoading] = useState(false);

  const illnessOptions = [
    'Diabetic & Low Sugar',
    'Hypertension (Low Salt)',
    'Post-Surgery Recovery (Soft Diet)',
    'Kidney Care (Low Protein)',
    'Gastric & Low Spice',
    'General Recovery & Wellness'
  ];

  if (!isOpen) return null;

  const handleNextSlide = (e: React.FormEvent) => {
    e.preventDefault();
    if (!phoneNumber || phoneNumber.length < 10) {
      setFormError('Please enter a valid 10-digit mobile number');
      return;
    }
    if (role === 'Patient' && !roomNo.trim()) {
      setFormError('Please enter your room or ward number');
      return;
    }
    setFormError('');
    setSlide(2);
  };

  const handleVerifyOtpAndComplete = (e: React.FormEvent) => {
    e.preventDefault();
    if (otpCode !== '123456' && otpCode !== '551010' && otpCode.length !== 6) {
      setOtpError('Please enter the 6-digit test code (use 551010 or 123456)');
      return;
    }
    setOtpError('');
    setLoading(true);

    setTimeout(() => {
      setLoading(false);

      const matchedHosp = HOSPITALS.find(h => h.id === selectedHospitalId) || HOSPITALS[0];
      selectHospital(matchedHosp);
      loginWithPhone(phoneNumber);

      if (role === 'Patient') {
        setUserRole('Patient');
        setPatientDetails({
          patientName: patientName.trim() || 'Admitted Patient',
          roomNumber: roomNo.trim() || 'G-102',
          ward: 'General Ward',
          diagnosis: illness,
          attendingDoctor: 'Dr. Abdul'
        });
      } else {
        setUserRole('Employee');
        setEmployeeDetails({
          employeeName: employeeName.trim() || 'Hospital Staff',
          employeeId: 'EMP-' + Math.floor(1000 + Math.random() * 9000),
          department: department.trim() || 'Ward Management'
        });
      }

      if (onComplete) onComplete();
      onClose();
    }, 800);
  };

  return (
    <div className="fixed inset-0 bg-brand-dark/60 backdrop-blur-md z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 animate-fade-in">
      <div className="bg-brand-cream w-full max-w-md rounded-t-3xl sm:rounded-3xl shadow-2xl border-t sm:border border-brand-green-light/20 overflow-hidden flex flex-col max-h-[92vh] animate-slide-up">
        
        {/* Banner Header */}
        <div className="bg-brand-green-dark p-5 text-white relative">
          <div className="absolute top-0 right-0 w-32 h-32 bg-brand-green-medium/20 rounded-bl-full pointer-events-none" />
          
          <button 
            onClick={onClose}
            className="absolute top-4 right-4 bg-white/10 hover:bg-white/20 p-2 rounded-full text-white transition cursor-pointer"
          >
            <X className="w-4 h-4" />
          </button>

          <div className="flex items-center gap-2 mb-1.5">
            <span className="text-[9px] uppercase font-extrabold tracking-widest text-brand-orange bg-brand-orange/15 px-2.5 py-0.5 rounded-full inline-block">
              🩺 Slide {slide}/2
            </span>
          </div>

          <h3 className="text-lg font-black tracking-tight flex items-center gap-2">
            <Smartphone className="w-4.5 h-4.5 text-brand-orange" /> 
            {slide === 1 ? title : 'Verify Mobile OTP'}
          </h3>
          <p className="text-xs text-white/85 mt-1">
            {slide === 1 ? subtitle : `Enter the 6-digit simulation code sent to +91 ${phoneNumber}`}
          </p>
        </div>

        {/* Scrollable Form Panel */}
        <div className="p-5 overflow-y-auto no-scrollbar space-y-4 flex-1">
          
          {slide === 1 ? (
            <form onSubmit={handleNextSlide} className="space-y-4">
              
              {/* Role selector tabs */}
              <div className="grid grid-cols-2 gap-2 bg-white/80 p-1.5 rounded-2xl border border-gray-100">
                <button
                  type="button"
                  onClick={() => setRole('Patient')}
                  className={`py-2 rounded-xl text-xs font-bold transition cursor-pointer text-center ${
                    role === 'Patient' ? 'bg-brand-green-dark text-white shadow' : 'text-brand-light'
                  }`}
                >
                  🤒 Patient / Attendant
                </button>
                <button
                  type="button"
                  onClick={() => setRole('Hospital Staff')}
                  className={`py-2 rounded-xl text-xs font-bold transition cursor-pointer text-center ${
                    role === 'Hospital Staff' ? 'bg-brand-green-dark text-white shadow' : 'text-brand-light'
                  }`}
                >
                  🩺 Hospital Staff
                </button>
              </div>

              <div className="bg-white p-4 rounded-2xl border border-brand-green-light/20 space-y-3.5">
                
                {/* Hospital Selection */}
                <div>
                  <label className="block text-[10px] font-bold text-brand-green-dark uppercase tracking-wider mb-1 flex items-center gap-1">
                    <MapPin className="w-3.5 h-3.5 text-brand-orange" /> Admitted Hospital Location
                  </label>
                  <select
                    value={selectedHospitalId}
                    onChange={(e) => setSelectedHospitalId(e.target.value)}
                    className="block w-full py-2.5 px-3 border border-gray-200 rounded-xl bg-gray-50 text-xs font-bold focus:bg-white text-brand-dark focus:ring-1 focus:ring-brand-green-medium transition"
                  >
                    {HOSPITALS.map((hosp) => (
                      <option key={hosp.id} value={hosp.id}>{hosp.name}</option>
                    ))}
                  </select>
                </div>

                {role === 'Patient' ? (
                  <>
                    <div>
                      <label className="block text-[10px] font-bold text-brand-green-dark uppercase tracking-wider mb-1">
                        Patient Full Name
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. Zainab Fatima"
                        value={patientName}
                        onChange={(e) => setPatientName(e.target.value)}
                        className="block w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white text-xs font-semibold transition"
                      />
                    </div>

                    <div>
                      <label className="block text-[10px] font-bold text-brand-green-dark uppercase tracking-wider mb-1">
                        Room / Ward No. (e.g. G-102)
                      </label>
                      <input
                        type="text"
                        required
                        placeholder="e.g. Bed 4, Ward A"
                        value={roomNo}
                        onChange={(e) => setRoomNo(e.target.value)}
                        className="block w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white text-xs font-semibold transition"
                      />
                    </div>

                    <div>
                      <label className="block text-[10px] font-bold text-brand-green-dark uppercase tracking-wider mb-1">
                        Illness / Dietary Condition
                      </label>
                      <select
                        value={illness}
                        onChange={(e) => setIllness(e.target.value)}
                        className="block w-full py-2.5 px-3 border border-gray-200 rounded-xl bg-gray-50 text-xs font-semibold focus:bg-white text-brand-dark transition"
                      >
                        {illnessOptions.map((opt, i) => (
                          <option key={i} value={opt}>{opt}</option>
                        ))}
                      </select>
                    </div>
                  </>
                ) : (
                  <>
                    <div>
                      <label className="block text-[10px] font-bold text-brand-green-dark uppercase tracking-wider mb-1">
                        Staff Full Name
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. Dr. Aditya Naik"
                        value={employeeName}
                        onChange={(e) => setEmployeeName(e.target.value)}
                        className="block w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white text-xs font-semibold transition"
                      />
                    </div>

                    <div>
                      <label className="block text-[10px] font-bold text-brand-green-dark uppercase tracking-wider mb-1">
                        Department / Ward
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. ICU Duty Nurse"
                        value={department}
                        onChange={(e) => setDepartment(e.target.value)}
                        className="block w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white text-xs font-semibold transition"
                      />
                    </div>
                  </>
                )}

                {/* Mobile Phone Number */}
                <div>
                  <label className="block text-[10px] font-bold text-brand-green-dark uppercase tracking-wider mb-1">
                    Mobile Phone Number
                  </label>
                  <div className="relative">
                    <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-xs font-bold text-brand-green-medium">+91</span>
                    <input
                      type="tel"
                      required
                      maxLength={10}
                      placeholder="Enter 10-digit phone number"
                      value={phoneNumber}
                      onChange={(e) => {
                        const val = e.target.value.replace(/\D/g, '');
                        setPhoneNumber(val);
                        if (val.length === 10) setFormError('');
                      }}
                      className="block w-full pl-12 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white text-xs font-semibold transition"
                    />
                  </div>
                </div>

                {formError && (
                  <p className="text-[10px] text-brand-error font-semibold flex items-center gap-1">
                    <ShieldAlert className="w-3.5 h-3.5" /> {formError}
                  </p>
                )}
              </div>

              <button
                type="submit"
                className="w-full bg-brand-green-dark hover:bg-brand-green-dark/95 text-white font-bold text-xs py-3.5 rounded-xl shadow transition flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <span>Next: Verify Mobile OTP</span>
                <Send className="w-3.5 h-3.5 text-brand-orange" />
              </button>
            </form>
          ) : (
            <form onSubmit={handleVerifyOtpAndComplete} className="space-y-4">
              <div className="bg-white p-4 rounded-2xl border border-brand-green-light/25 space-y-3">
                <div className="bg-brand-green-light/30 border border-brand-green-medium/20 rounded-xl p-3 text-center text-xs text-brand-green-dark">
                  Verification SMS code sent to <strong className="font-semibold">+91 {phoneNumber}</strong>
                </div>

                <div>
                  <label className="block text-[10px] font-bold text-brand-green-dark uppercase tracking-wider mb-2">
                    Enter 6-Digit OTP Code
                  </label>
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
                    className="block w-full tracking-[0.4em] text-center py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white text-sm font-bold transition"
                  />
                  {otpError && (
                    <p className="text-[10px] text-brand-error font-semibold mt-1 flex items-center gap-1">
                      <ShieldAlert className="w-3.5 h-3.5" /> {otpError}
                    </p>
                  )}
                </div>

                <div className="flex justify-between items-center px-1">
                  <button 
                    type="button" 
                    onClick={() => setSlide(1)}
                    className="text-[10px] font-bold text-brand-green-dark hover:underline cursor-pointer flex items-center gap-0.5"
                  >
                    <ArrowLeft className="w-3 h-3" /> Change Number
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-brand-orange hover:bg-brand-orange/95 text-white font-bold text-xs py-3.5 rounded-xl shadow transition flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-50"
              >
                {loading ? (
                  <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                ) : (
                  <>
                    <Award className="w-4 h-4 text-white" />
                    <span>Verify OTP & Complete Check-In</span>
                  </>
                )}
              </button>
            </form>
          )}

        </div>

        {/* Sterile compliance footer */}
        <div className="p-3.5 bg-white border-t border-gray-100 flex items-center justify-between text-[9px] text-brand-light">
          <span className="flex items-center gap-1"><Sparkles className="w-3.5 h-3.5 text-brand-orange" /> Double-sanitized hospital delivery coordinate zone</span>
          <span className="font-bold text-brand-green-dark">Secured ✓</span>
        </div>

      </div>
    </div>
  );
};
