import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { HOSPITALS } from '../data';
import { Hospital, UserRole } from '../types';
import { MapPin, Star, ArrowLeft, Heart, User, Briefcase, PlusCircle, PenTool, Clipboard, ArrowRight, ChevronRight } from 'lucide-react';

export const HospitalSelectionFlow: React.FC = () => {
  const { 
    screen, 
    selectedHospital, 
    selectHospital, 
    user, 
    setUserRole, 
    setPatientDetails, 
    setEmployeeDetails, 
    goBack 
  } = useApp();

  // Internal states
  const [roleStep, setRoleStep] = useState(false); // whether they selected hospital and now picking role
  
  // Patient details state
  const [patientName, setPatientName] = useState('');
  const [roomNumber, setRoomNumber] = useState('');
  const [ward, setWard] = useState('');
  const [notes, setNotes] = useState('');
  const [patientError, setPatientError] = useState('');

  // Employee details state
  const [employeeName, setEmployeeName] = useState('');
  const [department, setDepartment] = useState('');
  const [employeeId, setEmployeeId] = useState('');
  const [employeeError, setEmployeeError] = useState('');

  const handleSelectHospital = (hospital: Hospital) => {
    selectHospital(hospital);
    setRoleStep(true);
  };

  const handleRoleSelection = (role: UserRole) => {
    setUserRole(role);
  };

  const handlePatientSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!patientName.trim()) {
      setPatientError('Please enter the guest name');
      return;
    }
    if (!roomNumber.trim()) {
      setPatientError('Please enter a room number');
      return;
    }
    if (!ward.trim()) {
      setPatientError('Please enter the ward (e.g. General, ICU, Cardiac)');
      return;
    }
    
    setPatientError('');
    setPatientDetails({
      patientName: patientName.trim(),
      roomNumber: roomNumber.trim(),
      ward: ward.trim(),
      notes: notes.trim(),
    });
  };

  const handleEmployeeSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!employeeName.trim()) {
      setEmployeeError('Please enter employee name');
      return;
    }
    if (!department.trim()) {
      setEmployeeError('Please enter department name');
      return;
    }
    if (!employeeId.trim()) {
      setEmployeeError('Please enter Employee ID');
      return;
    }

    setEmployeeError('');
    setEmployeeDetails({
      employeeName: employeeName.trim(),
      department: department.trim(),
      employeeId: employeeId.trim(),
    });
  };

  const handleBack = () => {
    if (screen === 'patient-flow' || screen === 'employee-flow') {
      // Go back to picking role
      setRoleStep(true);
      setUserRole('Patient'); // default reset
      goBack(); // this will pop from history, but let's force screen state back:
      // wait, the goBack in context pops screens. Let's just goBack
    } else if (roleStep) {
      setRoleStep(false);
    } else {
      goBack();
    }
  };

  // Rendering screen 1: SELECT HOSPITAL
  if (screen === 'select-hospital' && !roleStep) {
    return (
      <div id="select-hospital-screen" className="min-h-screen bg-brand-cream text-brand-dark px-4 py-6 flex flex-col justify-between">
        {/* Header */}
        <div className="max-w-xl mx-auto w-full mb-6">
          <h2 className="text-2xl font-extrabold text-brand-green-dark tracking-tight">Select Your Hospital</h2>
          <p className="text-sm text-brand-light mt-1">
            Choose your current admitting or working healthcare facility.
          </p>
        </div>

        {/* Hospital Cards List */}
        <div className="max-w-xl mx-auto w-full flex-1 space-y-4">
          {HOSPITALS.map((hospital) => (
            <div 
              key={hospital.id}
              id={`hospital-card-${hospital.id}`}
              onClick={() => handleSelectHospital(hospital)}
              className="group relative flex flex-col sm:flex-row items-center gap-4 bg-white p-4 rounded-2xl border border-brand-green-light/30 shadow-md hover:shadow-xl transition duration-300 cursor-pointer overflow-hidden transform hover:-translate-y-0.5"
            >
              {/* Cover Image */}
              <div className="relative w-full sm:w-28 h-28 rounded-xl overflow-hidden flex-shrink-0">
                <img 
                  src={hospital.image} 
                  alt={hospital.name} 
                  className="w-full h-full object-cover group-hover:scale-105 transition duration-300"
                />
                <div className="absolute top-2 left-2 flex items-center gap-1 bg-white/95 px-2 py-0.5 rounded-full shadow text-[11px] font-bold text-brand-green-dark">
                  <Star className="w-3 h-3 text-brand-orange fill-brand-orange" />
                  <span>{hospital.rating}</span>
                </div>
              </div>

              {/* Information */}
              <div className="flex-1 text-center sm:text-left w-full">
                <h3 className="text-base font-bold text-brand-dark leading-snug group-hover:text-brand-green-dark transition">
                  {hospital.name}
                </h3>
                <div className="flex items-center justify-center sm:justify-start gap-1 text-brand-light text-xs mt-1.5">
                  <MapPin className="w-3.5 h-3.5 text-brand-orange" />
                  <span>{hospital.location}</span>
                </div>
                <p className="text-[11px] text-brand-green-medium font-medium mt-1">
                  ✓ Hot sterile room-delivery active
                </p>
              </div>

              {/* Action Button */}
              <div className="w-full sm:w-auto">
                <button 
                  id={`select-btn-${hospital.id}`}
                  className="w-full sm:w-auto bg-brand-green-light hover:bg-brand-green-dark text-brand-green-dark hover:text-white font-bold text-xs px-5 py-2.5 rounded-xl transition shadow-sm cursor-pointer"
                >
                  Select
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Info label */}
        <div className="text-center text-xs text-brand-light/70 max-w-sm mx-auto mt-6">
          Supporting critical nutrition across 5 primary bhatkal healing centers.
        </div>
      </div>
    );
  }

  // Rendering screen 2: ROLE CHOICE
  if (screen === 'select-hospital' && roleStep) {
    return (
      <div id="role-selection-screen" className="min-h-screen bg-brand-cream text-brand-dark px-6 py-8 flex flex-col justify-between">
        {/* Header */}
        <div className="max-w-md mx-auto w-full">
          <button 
            onClick={() => setRoleStep(false)}
            className="flex items-center gap-1 text-xs font-bold text-brand-green-dark hover:text-brand-orange transition cursor-pointer mb-6"
          >
            <ArrowLeft className="w-3.5 h-3.5" /> Back to hospitals
          </button>
          
          <div className="bg-brand-green-light/40 rounded-2xl p-4 border border-brand-green-medium/15 flex items-center gap-3.5 mb-6">
            <img src={selectedHospital?.image} alt={selectedHospital?.name} className="w-12 h-12 rounded-lg object-cover" />
            <div>
              <p className="text-[10px] uppercase font-bold text-brand-green-dark tracking-wider">Selected Facility</p>
              <h3 className="text-sm font-bold text-brand-dark leading-tight">{selectedHospital?.name}</h3>
            </div>
          </div>

          <h2 className="text-2xl font-extrabold text-brand-green-dark tracking-tight text-center">Who is this meal for?</h2>
          <p className="text-sm text-brand-light text-center mt-1">
            Specify your role to customize nutrition guidelines and ward checkouts.
          </p>
        </div>

        {/* Roles selection cards */}
        <div className="max-w-md mx-auto w-full space-y-4 my-auto py-6">
          {/* Patient Option */}
          <div 
            id="role-patient-card"
            onClick={() => handleRoleSelection('Patient')}
            className="group relative flex items-center gap-4 bg-white p-5 rounded-2xl border border-brand-green-light/30 shadow hover:shadow-lg transition cursor-pointer hover:bg-brand-green-light/5"
          >
            <div className="w-12 h-12 rounded-xl bg-brand-green-light text-brand-green-dark flex items-center justify-center font-bold">
              <User className="w-6 h-6 text-brand-green-dark" />
            </div>
            <div className="flex-1">
              <h3 className="text-base font-bold text-brand-dark leading-tight group-hover:text-brand-green-dark transition">
                Recovery Guest / Bedside
              </h3>
              <p className="text-xs text-brand-light mt-1">
                Order healing meals delivered directly to your bed space or ward unit.
              </p>
            </div>
            <ChevronRight className="w-5 h-5 text-brand-green-medium/50 group-hover:text-brand-green-dark transition" />
          </div>

          {/* Employee Option */}
          <div 
            id="role-employee-card"
            onClick={() => handleRoleSelection('Employee')}
            className="group relative flex items-center gap-4 bg-white p-5 rounded-2xl border border-brand-green-light/30 shadow hover:shadow-lg transition cursor-pointer hover:bg-brand-green-light/5"
          >
            <div className="w-12 h-12 rounded-xl bg-brand-orange/10 text-brand-orange flex items-center justify-center font-bold">
              <Briefcase className="w-6 h-6 text-brand-orange" />
            </div>
            <div className="flex-1">
              <h3 className="text-base font-bold text-brand-dark leading-tight group-hover:text-brand-orange transition">
                Hospital Staff / Caregiver
              </h3>
              <p className="text-xs text-brand-light mt-1">
                Meals for clinical staff, nursing, administrative, or caregivers.
              </p>
            </div>
            <ChevronRight className="w-5 h-5 text-brand-green-medium/50 group-hover:text-brand-orange transition" />
          </div>
        </div>

        <div className="text-center text-xs text-brand-light/70 max-w-sm mx-auto">
          Secure, sanitized cooking adhering strictly to global healthcare dietary systems.
        </div>
      </div>
    );
  }

  // Rendering screen 3: PATIENT INTAKE FLOW
  if (screen === 'patient-flow') {
    return (
      <div id="patient-flow-screen" className="min-h-screen bg-brand-cream text-brand-dark px-6 py-8 flex flex-col justify-between">
        {/* Header */}
        <div className="max-w-md mx-auto w-full mb-4">
          <button 
            onClick={handleBack}
            className="flex items-center gap-1 text-xs font-bold text-brand-green-dark hover:text-brand-orange transition cursor-pointer mb-6"
          >
            <ArrowLeft className="w-3.5 h-3.5" /> Back to role selection
          </button>

          <h2 className="text-2xl font-extrabold text-brand-green-dark tracking-tight">Recovery Guest Details</h2>
          <p className="text-sm text-brand-light mt-1">
            Provide your exact room location so delivery staff can find you instantly.
          </p>
        </div>

        {/* Intake Form */}
        <div className="max-w-md mx-auto w-full my-auto py-4 bg-white rounded-3xl p-6 shadow-xl border border-brand-green-light/30">
          <form onSubmit={handlePatientSubmit} className="space-y-4">
            {/* Patient Name */}
            <div>
              <label className="block text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-1.5">
                Guest Name
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <User className="h-4 w-4 text-brand-green-medium/70" />
                </div>
                <input
                  id="patient-name-input"
                  type="text"
                  required
                  placeholder="Enter full name of guest"
                  value={patientName}
                  onChange={(e) => setPatientName(e.target.value)}
                  className="block w-full pl-9 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:ring-2 focus:ring-brand-green-medium focus:border-transparent text-sm font-medium transition"
                />
              </div>
            </div>

            {/* Ward & Room Row */}
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-1.5">
                  Ward / Floor
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Clipboard className="h-4 w-4 text-brand-green-medium/70" />
                  </div>
                  <input
                    id="patient-ward-input"
                    type="text"
                    required
                    placeholder="e.g. Female General, ICU"
                    value={ward}
                    onChange={(e) => setWard(e.target.value)}
                    className="block w-full pl-9 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:ring-2 focus:ring-brand-green-medium focus:border-transparent text-sm font-medium transition"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-1.5">
                  Room / Bed No.
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <PlusCircle className="h-4 w-4 text-brand-green-medium/70" />
                  </div>
                  <input
                    id="patient-room-input"
                    type="text"
                    required
                    placeholder="e.g. Room 302, Bed B"
                    value={roomNumber}
                    onChange={(e) => setRoomNumber(e.target.value)}
                    className="block w-full pl-9 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:ring-2 focus:ring-brand-green-medium focus:border-transparent text-sm font-medium transition"
                  />
                </div>
              </div>
            </div>

            {/* Optional Notes */}
            <div>
              <label className="block text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-1.5">
                Special Delivery Notes (Optional)
              </label>
              <div className="relative">
                <textarea
                  id="patient-notes-input"
                  rows={2}
                  placeholder="e.g. Ask nurse before entry, ring outside bell..."
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  className="block w-full px-3.5 py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:ring-2 focus:ring-brand-green-medium focus:border-transparent text-sm font-medium transition resize-none"
                />
              </div>
            </div>

            {patientError && (
              <p className="text-xs text-brand-error font-medium mt-1 text-center">{patientError}</p>
            )}

            {/* Submit Button */}
            <button
              id="patient-details-submit-btn"
              type="submit"
              className="w-full mt-4 bg-brand-green-dark hover:bg-brand-green-dark/90 text-white font-semibold py-3.5 rounded-xl shadow-md transition flex items-center justify-center gap-2 cursor-pointer"
            >
              <span>Continue to Meals</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </form>
        </div>

        {/* Extra safe label */}
        <div className="text-center text-[11px] text-brand-light leading-relaxed max-w-sm mx-auto">
          Cura Meal maintains full compliance with Bhatkal Hospital privacy and dietary policies.
        </div>
      </div>
    );
  }

  // Rendering screen 4: EMPLOYEE INTAKE FLOW
  return (
    <div id="employee-flow-screen" className="min-h-screen bg-brand-cream text-brand-dark px-6 py-8 flex flex-col justify-between">
      {/* Header */}
      <div className="max-w-md mx-auto w-full mb-4">
        <button 
          onClick={handleBack}
          className="flex items-center gap-1 text-xs font-bold text-brand-green-dark hover:text-brand-orange transition cursor-pointer mb-6"
        >
          <ArrowLeft className="w-3.5 h-3.5" /> Back to role selection
        </button>

        <h2 className="text-2xl font-extrabold text-brand-orange tracking-tight">Employee Registration</h2>
        <p className="text-sm text-brand-light mt-1">
          Specify your department or cabin for easy meal drop-offs.
        </p>
      </div>

      {/* Intake Form */}
      <div className="max-w-md mx-auto w-full my-auto py-4 bg-white rounded-3xl p-6 shadow-xl border border-brand-green-light/30">
        <form onSubmit={handleEmployeeSubmit} className="space-y-4">
          {/* Employee Name */}
          <div>
            <label className="block text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-1.5">
              Employee Full Name
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <User className="h-4 w-4 text-brand-orange" />
              </div>
              <input
                id="employee-name-input"
                type="text"
                required
                placeholder="Enter your name"
                value={employeeName}
                onChange={(e) => setEmployeeName(e.target.value)}
                className="block w-full pl-9 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:ring-2 focus:ring-brand-orange focus:border-transparent text-sm font-medium transition"
              />
            </div>
          </div>

          {/* Department */}
          <div>
            <label className="block text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-1.5">
              Department / Section
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Briefcase className="h-4 w-4 text-brand-orange" />
              </div>
              <input
                id="employee-dept-input"
                type="text"
                required
                placeholder="e.g. Pediatrics, Pharmacy, ER"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                className="block w-full pl-9 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:ring-2 focus:ring-brand-orange focus:border-transparent text-sm font-medium transition"
              />
            </div>
          </div>

          {/* Employee ID */}
          <div>
            <label className="block text-xs font-bold text-brand-green-dark uppercase tracking-wider mb-1.5">
              Employee ID
            </label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <PenTool className="h-4 w-4 text-brand-orange" />
              </div>
              <input
                id="employee-id-input"
                type="text"
                required
                placeholder="e.g. EMP-9821"
                value={employeeId}
                onChange={(e) => setEmployeeId(e.target.value)}
                className="block w-full pl-9 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:ring-2 focus:ring-brand-orange focus:border-transparent text-sm font-medium transition"
              />
            </div>
          </div>

          {employeeError && (
            <p className="text-xs text-brand-error font-medium mt-1 text-center">{employeeError}</p>
          )}

          {/* Submit Button */}
          <button
            id="employee-details-submit-btn"
            type="submit"
            className="w-full mt-4 bg-brand-orange hover:bg-brand-orange/90 text-white font-semibold py-3.5 rounded-xl shadow-md transition flex items-center justify-center gap-2 cursor-pointer"
          >
            <span>Continue to Meals</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </form>
      </div>

      {/* Extra safety label */}
      <div className="text-center text-[11px] text-brand-light leading-relaxed max-w-sm mx-auto">
        Medical employee discount and quick drop-off options are applied upon validation.
      </div>
    </div>
  );
};
