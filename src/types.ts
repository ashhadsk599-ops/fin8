export interface Hospital {
  id: string;
  name: string;
  image: string;
  location: string;
  rating: number;
}

export type UserRole = 'Patient' | 'Employee';

export interface PatientDetails {
  roomNumber: string;
  ward: string;
  patientName: string;
  notes?: string;
  diagnosis?: string;
}

export interface EmployeeDetails {
  employeeName: string;
  department: string;
  employeeId: string;
}

export interface User {
  phone: string;
  email?: string;
  role: UserRole;
  selectedHospitalId: string;
  patientDetails?: PatientDetails;
  employeeDetails?: EmployeeDetails;
}

export type MealCategory = 'Breakfast' | 'Soup' | 'Lunch' | 'Juice' | 'Snacks' | 'Grocery';

export interface Nutrition {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  prepTimeMinutes: number;
}

export interface Review {
  id: string;
  userName: string;
  rating: number;
  comment: string;
  date: string;
}

export interface Meal {
  id: string;
  name: string;
  image: string;
  price: number;
  rating: number;
  calories: number;
  protein: number;
  category: MealCategory;
  isVeg: boolean;
  isPopular?: boolean;
  isHealthySpecial?: boolean;
  description: string;
  ingredients: string[];
  nutrition: Nutrition;
  reviews: Review[];
  isDoctorRecommended?: boolean;
  clinicalTags?: string[];
  clinicalDiagnosisSuggestion?: string;
}

export interface MealCustomization {
  extraRice: boolean;
  extraCurry: boolean;
  saltPreference: 'Normal' | 'No Salt' | 'Less Salt';
  spicePreference: 'Normal' | 'Less Spice' | 'More Spice';
  noOnion: boolean;
  noGarlic: boolean;
  extraSalad: boolean;
  extraCurd: boolean;
  specialInstructions: string;
  addonEggBanana?: boolean;
}

export interface CartItem {
  id: string; // unique cart item id (mealId + hash of customization)
  meal: Meal;
  quantity: number;
  customization: MealCustomization;
}

export interface Offer {
  id: string;
  code: string;
  title: string;
  description: string;
  discountPercentage: number;
  minOrderValue: number;
}

export type OrderStatus = 'Received' | 'Preparing' | 'Out for Delivery' | 'Delivered';

export interface Order {
  id: string;
  orderNumber: string;
  items: CartItem[];
  hospitalId: string;
  hospitalName: string;
  userRole: UserRole;
  patientDetails?: PatientDetails;
  employeeDetails?: EmployeeDetails;
  subtotal: number;
  deliveryCharge: number;
  gst: number;
  discount: number;
  grandTotal: number;
  paymentMethod: 'Cash' | 'UPI' | 'Card';
  status: OrderStatus;
  createdAt: string;
  estimatedDeliveryMinutes: number;
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  time: string;
  isRead: boolean;
}
