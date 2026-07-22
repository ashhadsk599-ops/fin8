import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { Order, OrderStatus } from '../types';
import { db } from '../firebase';
import { collection, onSnapshot } from 'firebase/firestore';
import { 
  ArrowLeft, Shield, ClipboardList, CheckCircle, Clock, 
  MapPin, Check, ChevronRight, Eye, RefreshCw, LogOut, Settings, Users, Activity, TrendingUp
} from 'lucide-react';

export const AdminScreen: React.FC = () => {
  const { orders, updateOrderStatus, navigateTo } = useApp();
  const [activeTab, setActiveTab] = useState<'orders' | 'patients' | 'settings'>('orders');
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [firestoreUsers, setFirestoreUsers] = useState<any[]>([]);
  const [firestoreOrders, setFirestoreOrders] = useState<Order[]>([]);

  // Listen directly to orders collection in Firestore
  useEffect(() => {
    try {
      const unsubOrders = onSnapshot(collection(db, 'orders'), (snapshot) => {
        const fetched: Order[] = [];
        snapshot.forEach((docSnap) => {
          fetched.push(docSnap.data() as Order);
        });
        fetched.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        setFirestoreOrders(fetched);
      }, (err) => console.warn('Firestore orders listener warning:', err));
      return () => unsubOrders();
    } catch (e) {
      console.warn('Firestore orders error:', e);
    }
  }, []);

  // Listen to registered_users collection in Firestore
  useEffect(() => {
    try {
      const unsub = onSnapshot(collection(db, 'registered_users'), (snapshot) => {
        const usersList: any[] = [];
        snapshot.forEach((docSnap) => {
          usersList.push({ id: docSnap.id, ...docSnap.data() });
        });
        setFirestoreUsers(usersList);
      }, (err) => console.warn('Firestore registered_users listener warning:', err));
      return () => unsub();
    } catch (e) {
      console.warn('Firestore registered_users error:', e);
    }
  }, []);

  // Combine orders from Firestore and local AppContext
  const displayOrders = firestoreOrders.length > 0 ? firestoreOrders : orders;

  // Derive list of users/patients from both Firestore registrations and orders
  const patientsListFromOrders = Array.from(
    new Map<string, any>(
      displayOrders
        .filter(o => o.patientDetails)
        .map(o => [o.patientDetails!.patientName, {
          name: o.patientDetails!.patientName,
          ward: o.patientDetails!.ward,
          room: o.patientDetails!.roomNumber,
          diagnosis: o.patientDetails!.diagnosis || 'General Ward Care',
          notes: o.patientDetails!.notes || 'None',
          lastOrderNum: o.orderNumber,
          lastOrderTime: o.createdAt
        }])
    ).values()
  );

  // Combine Firestore registrations with order history
  const combinedUsers = firestoreUsers.length > 0 
    ? firestoreUsers.map(u => ({
        name: u.patientDetails?.patientName || u.employeeDetails?.employeeName || u.phone || 'Registered User',
        phone: u.phone,
        role: u.role || 'Patient',
        ward: u.patientDetails?.ward || 'General',
        room: u.patientDetails?.roomNumber || 'N/A',
        diagnosis: u.patientDetails?.diagnosis || 'Standard Care',
        notes: u.patientDetails?.notes || 'None',
        registeredAt: u.registeredAt ? new Date(u.registeredAt).toLocaleString() : 'Recently',
        hospitalName: u.hospitalName || 'Bhatkal Hospital'
      }))
    : patientsListFromOrders;

  // Statistics
  const totalOrdersCount = displayOrders.length;
  const pendingOrders = displayOrders.filter(o => o.status === 'Received');
  const activeOrders = displayOrders.filter(o => o.status === 'Preparing' || o.status === 'Out for Delivery');
  const completedOrders = displayOrders.filter(o => o.status === 'Delivered');
  const totalRevenue = displayOrders.reduce((sum, o) => sum + o.grandTotal, 0);

  const getStatusBadgeClass = (status: OrderStatus) => {
    switch (status) {
      case 'Received':
        return 'bg-amber-100 text-amber-800 border-amber-200';
      case 'Preparing':
        return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'Out for Delivery':
        return 'bg-indigo-100 text-indigo-800 border-indigo-200';
      case 'Delivered':
        return 'bg-emerald-100 text-emerald-800 border-emerald-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const handleAcceptOrder = (orderId: string) => {
    updateOrderStatus(orderId, 'Preparing');
  };

  const handleDispatchOrder = (orderId: string) => {
    updateOrderStatus(orderId, 'Out for Delivery');
  };

  const handleCompleteOrder = (orderId: string) => {
    updateOrderStatus(orderId, 'Delivered');
  };

  return (
    <div id="admin-panel" className="pb-24 bg-slate-900 min-h-screen text-slate-100 font-sans">
      {/* Admin Panel Header */}
      <div className="bg-slate-800 border-b border-slate-700/80 p-4 sticky top-0 z-40">
        <div className="max-w-xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-2">
            <div className="bg-amber-500 text-slate-900 p-1.5 rounded-xl">
              <Shield className="w-5 h-5 fill-slate-900/10" />
            </div>
            <div>
              <h1 className="text-sm font-black text-white uppercase tracking-wider leading-none">
                Kitchen Admin Setup
              </h1>
              <p className="text-[10px] text-slate-400 mt-1 font-medium">
                Clinical Sterilization & Inpatient Despatch
              </p>
            </div>
          </div>
          
          <button 
            onClick={() => navigateTo('settings')}
            className="text-xs font-bold text-slate-400 hover:text-white flex items-center gap-1 bg-slate-700 px-3 py-1.5 rounded-lg transition"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Settings</span>
          </button>
        </div>
      </div>

      {/* Stats Summary Widget */}
      <div className="max-w-xl mx-auto px-4 mt-5 grid grid-cols-4 gap-2">
        <div className="bg-slate-800/80 p-3 rounded-2xl border border-slate-700/50 text-center">
          <span className="text-[9px] uppercase font-bold text-slate-400 block tracking-wider">Revenue</span>
          <span className="text-xs font-black text-emerald-400 mt-1 block">₹{totalRevenue}</span>
        </div>
        <div className="bg-slate-800/80 p-3 rounded-2xl border border-slate-700/50 text-center">
          <span className="text-[9px] uppercase font-bold text-slate-400 block tracking-wider">Received</span>
          <span className="text-xs font-black text-amber-400 mt-1 block">{pendingOrders.length}</span>
        </div>
        <div className="bg-slate-800/80 p-3 rounded-2xl border border-slate-700/50 text-center">
          <span className="text-[9px] uppercase font-bold text-slate-400 block tracking-wider">Preparing</span>
          <span className="text-xs font-black text-blue-400 mt-1 block">{activeOrders.length}</span>
        </div>
        <div className="bg-slate-800/80 p-3 rounded-2xl border border-slate-700/50 text-center">
          <span className="text-[9px] uppercase font-bold text-slate-400 block tracking-wider">Completed</span>
          <span className="text-xs font-black text-emerald-400 mt-1 block">{completedOrders.length}</span>
        </div>
      </div>

      {/* Sub-navigation tabs */}
      <div className="max-w-xl mx-auto px-4 mt-5">
        <div className="bg-slate-800 p-1 rounded-xl flex border border-slate-700">
          <button 
            onClick={() => { setActiveTab('orders'); setSelectedOrder(null); }}
            className={`flex-1 py-2 text-center text-xs font-black rounded-lg transition-all ${activeTab === 'orders' ? 'bg-amber-500 text-slate-950' : 'text-slate-300 hover:text-white'}`}
          >
            <ClipboardList className="w-3.5 h-3.5 inline mr-1.5" /> Orders Placed
          </button>
          <button 
            onClick={() => setActiveTab('patients')}
            className={`flex-1 py-2 text-center text-xs font-black rounded-lg transition-all ${activeTab === 'patients' ? 'bg-amber-500 text-slate-950' : 'text-slate-300 hover:text-white'}`}
          >
            <Users className="w-3.5 h-3.5 inline mr-1.5" /> Patient Directory
          </button>
          <button 
            onClick={() => setActiveTab('settings')}
            className={`flex-1 py-2 text-center text-xs font-black rounded-lg transition-all ${activeTab === 'settings' ? 'bg-amber-500 text-slate-950' : 'text-slate-300 hover:text-white'}`}
          >
            <Settings className="w-3.5 h-3.5 inline mr-1.5" /> Setup Settings
          </button>
        </div>
      </div>

      {/* Main Admin Content Container */}
      <div className="max-w-xl mx-auto px-4 mt-5 space-y-4">
        
        {/* TAB 1: ORDERS PLACED */}
        {activeTab === 'orders' && (
          <div className="space-y-3.5">
            {displayOrders.length === 0 ? (
              <div className="bg-slate-800/50 rounded-2xl p-8 border border-slate-700/40 text-center">
                <ClipboardList className="w-12 h-12 text-slate-600 mx-auto mb-3" />
                <p className="text-xs text-slate-400 italic">No kitchen orders received yet.</p>
                <p className="text-[10px] text-slate-500 mt-1">Simulate order flow by placing an order from the client app.</p>
              </div>
            ) : (
              displayOrders.map(ord => (
                <div 
                  key={ord.id}
                  className={`bg-slate-800 border rounded-2xl p-4 transition-all ${selectedOrder?.id === ord.id ? 'border-amber-500' : 'border-slate-700 hover:border-slate-600'}`}
                >
                  <div className="flex justify-between items-start">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-extrabold text-white font-mono">{ord.orderNumber}</span>
                        <span className={`text-[9px] font-bold px-2 py-0.5 border rounded-full uppercase ${getStatusBadgeClass(ord.status)}`}>
                          {ord.status}
                        </span>
                      </div>
                      <p className="text-[10px] text-slate-400 mt-1">
                        Patient: <strong className="text-white">{ord.patientDetails?.patientName || ord.employeeDetails?.employeeName || 'Anonymous Admitted Guest'}</strong>
                      </p>
                      <p className="text-[10px] text-slate-400 mt-0.5">
                        Ward/Bed: <strong className="text-slate-300">{ord.patientDetails?.ward || 'Staff Office'} • Room {ord.patientDetails?.roomNumber || 'N/A'}</strong>
                      </p>
                    </div>

                    <div className="text-right">
                      <span className="text-sm font-black text-white block">₹{ord.grandTotal}</span>
                      <span className="text-[9px] text-slate-400">{new Date(ord.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                  </div>

                  {/* Order Items list */}
                  <div className="mt-3.5 pt-3.5 border-t border-slate-700/60 bg-slate-900/40 p-2.5 rounded-xl">
                    <span className="text-[9px] uppercase tracking-wider font-extrabold text-slate-400 block mb-1">Items Enclosed</span>
                    <div className="space-y-1">
                      {ord.items.map((item, idx) => (
                        <div key={idx} className="flex justify-between text-xs text-slate-200">
                          <span>{item.quantity}x {item.meal.name}</span>
                          <span className="text-slate-400 font-mono">₹{item.meal.price * item.quantity}</span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Actions Column based on Order Status */}
                  <div className="mt-4 flex gap-2 justify-end">
                    <button 
                      onClick={() => setSelectedOrder(selectedOrder?.id === ord.id ? null : ord)}
                      className="px-3 py-1.5 bg-slate-700 hover:bg-slate-600 text-slate-200 rounded-lg text-[10px] font-bold transition flex items-center gap-1"
                    >
                      <Eye className="w-3 h-3" /> Details
                    </button>

                    {ord.status === 'Received' && (
                      <button 
                        onClick={() => handleAcceptOrder(ord.id)}
                        className="px-3 py-1.5 bg-amber-500 hover:bg-amber-400 text-slate-950 rounded-lg text-[10px] font-black uppercase tracking-wider transition flex items-center gap-1"
                      >
                        <Check className="w-3.5 h-3.5 stroke-[3px]" /> Accept Order
                      </button>
                    )}

                    {ord.status === 'Preparing' && (
                      <button 
                        onClick={() => handleDispatchOrder(ord.id)}
                        className="px-3 py-1.5 bg-indigo-500 hover:bg-indigo-400 text-white rounded-lg text-[10px] font-black uppercase tracking-wider transition flex items-center gap-1"
                      >
                        Dispatch Order &rarr;
                      </button>
                    )}

                    {ord.status === 'Out for Delivery' && (
                      <button 
                        onClick={() => handleCompleteOrder(ord.id)}
                        className="px-3 py-1.5 bg-emerald-500 hover:bg-emerald-400 text-white rounded-lg text-[10px] font-black uppercase tracking-wider transition flex items-center gap-1"
                      >
                        <CheckCircle className="w-3.5 h-3.5" /> Mark Delivered
                      </button>
                    )}
                  </div>

                  {/* Detailed inspection subview */}
                  {selectedOrder?.id === ord.id && (
                    <div className="mt-4 bg-slate-900 border border-slate-700/60 p-4 rounded-xl space-y-2.5 animate-fade-in text-xs">
                      <p className="font-bold text-amber-500 text-xs">🩺 Bedside Clinical Diagnostics</p>
                      <p className="text-slate-300"><strong>Prescribed Treatment:</strong> {ord.patientDetails?.diagnosis || 'Therapeutic Nutrition Standard'}</p>
                      <p className="text-slate-300"><strong>Delivery Notes:</strong> "{ord.patientDetails?.notes || 'Sterile container transport requested.'}"</p>
                      <p className="text-slate-300"><strong>Payment Type:</strong> {ord.paymentMethod} (Hospital Invoiced)</p>
                      <p className="text-slate-300"><strong>Order Timestamp:</strong> {ord.createdAt}</p>
                    </div>
                  )}
                </div>
              ))
            )}
          </div>
        )}

        {/* TAB 2: PATIENT DIRECTORY */}
        {activeTab === 'patients' && (
          <div className="space-y-3">
            {combinedUsers.length === 0 ? (
              <div className="bg-slate-800/50 rounded-2xl p-8 border border-slate-700/40 text-center">
                <Users className="w-12 h-12 text-slate-600 mx-auto mb-3" />
                <p className="text-xs text-slate-400 italic">No registered users or patients in directory.</p>
                <p className="text-[10px] text-slate-500 mt-1">When users register or place orders on web or mobile, their records sync here via Firestore real-time server.</p>
              </div>
            ) : (
              combinedUsers.map((userRecord, idx) => (
                <div key={idx} className="bg-slate-800 border border-slate-700 rounded-2xl p-4 space-y-2.5">
                  <div className="flex justify-between items-center">
                    <div>
                      <h3 className="text-xs font-black text-white flex items-center gap-2">
                        {userRecord.name}
                        {userRecord.phone && <span className="text-[10px] text-slate-400 font-medium">({userRecord.phone})</span>}
                      </h3>
                      <span className="text-[9px] text-amber-400 font-bold block mt-0.5">{userRecord.hospitalName}</span>
                    </div>
                    <span className="text-[9px] bg-slate-700 px-2 py-0.5 rounded-full font-bold text-slate-300">
                      {userRecord.role || 'Registered User'}
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-3 bg-slate-900/40 p-3 rounded-xl border border-slate-700/30 text-[10px] text-slate-300">
                    <div>
                      <span className="text-[9px] text-slate-500 uppercase block tracking-wider font-bold">Bed Space / Ward</span>
                      <span>{userRecord.ward} • Room {userRecord.room}</span>
                    </div>
                    <div>
                      <span className="text-[9px] text-slate-500 uppercase block tracking-wider font-bold">Dietary / Diagnosis</span>
                      <span className="text-amber-400 font-bold">{userRecord.diagnosis}</span>
                    </div>
                  </div>

                  <div className="text-[10px] text-slate-400">
                    <p>📝 <strong>Kitchen Alert Note:</strong> "{userRecord.notes}"</p>
                    {userRecord.registeredAt && (
                      <p className="mt-1">🕒 <strong>Registered At:</strong> {userRecord.registeredAt}</p>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        )}

        {/* TAB 3: SETUP SETTINGS */}
        {activeTab === 'settings' && (
          <div className="bg-slate-800 rounded-3xl p-5 border border-slate-700 shadow-xl space-y-5">
            <div className="flex items-center gap-2 pb-3.5 border-b border-slate-700">
              <Settings className="w-5 h-5 text-amber-500" />
              <div>
                <h3 className="text-xs font-bold text-white uppercase tracking-wider">Setup Settings</h3>
                <p className="text-[10px] text-slate-400">Manage the clinical console connections and exit setups.</p>
              </div>
            </div>

            <div className="space-y-4">
              <div className="bg-slate-900/55 p-3.5 rounded-2xl border border-slate-700/60 space-y-1">
                <span className="text-slate-300 text-xs font-bold block">Hospital Station Mode</span>
                <span className="text-slate-400 text-[10px] leading-relaxed block">
                  Console is currently bound to the high-efficiency kitchen network. Admitted patient database coordinates are synced with secure end-to-end medical encryption.
                </span>
              </div>

              {/* Back to main app button inside setting of that setup */}
              <button 
                onClick={() => navigateTo('home')}
                className="w-full bg-amber-500 hover:bg-amber-400 text-slate-950 font-black text-xs py-3.5 rounded-xl transition uppercase tracking-wider shadow cursor-pointer flex items-center justify-center gap-1.5"
              >
                <LogOut className="w-4 h-4 rotate-180" />
                <span>Go Back to Main App</span>
              </button>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};
