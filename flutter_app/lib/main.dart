import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';
import 'package:cura_meal/screens/meal_dashboard_screen.dart';
import 'package:cura_meal/screens/search_tab_screen.dart';
import 'package:cura_meal/screens/care_pack_tab_screen.dart';
import 'package:cura_meal/screens/history_tab_screen.dart';
import 'package:cura_meal/screens/favorites_tab_screen.dart';
import 'package:cura_meal/screens/settings_tab_screen.dart';
import 'package:cura_meal/screens/clinical_checkin_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.loadFromPrefs();
  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const CuraMealApp(),
    ),
  );
}

class CuraMealApp extends StatelessWidget {
  const CuraMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return MaterialApp(
      title: 'Cura Meal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF4CAF50),
          background: const Color(0xFFFFFDF7),
        ),
        fontFamily: 'Inter',
        cardTheme: const CardTheme(
          elevation: 1,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        ),
      ),
      home: const AppLaunchSplashScreen(),
    );
  }
}

class AppLaunchSplashScreen extends StatefulWidget {
  const AppLaunchSplashScreen({super.key});

  @override
  State<AppLaunchSplashScreen> createState() => _AppLaunchSplashScreenState();
}

class _AppLaunchSplashScreenState extends State<AppLaunchSplashScreen> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashLayoutOnly();
    }
    return const OnboardingOrDashboardDirector();
  }
}

class SplashLayoutOnly extends StatelessWidget {
  const SplashLayoutOnly({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFBF7), Color(0xFFF0FDFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnimatedLogo(),
                const SizedBox(height: 24),
                const Text(
                  'Cura Meal',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'CLINICAL NUTRITION. SERVED WARM.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Partner hospital logos (Moved near the logo/title)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PARTNERED WITH 5 PREMIER HOSPITALS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _PartnerLogo(name: 'Welfare', initials: 'WF', color: Color(0xFF059669)),
                          _PartnerLogo(name: 'Shams Noor', initials: 'SN', color: Color(0xFF0EA5E9)),
                          _PartnerLogo(name: 'Lifecare', initials: 'LC', color: Color(0xFFF43F5E)),
                          _PartnerLogo(name: 'Asiya', initials: 'AS', color: Color(0xFF8B5CF6)),
                          _PartnerLogo(name: 'Government', initials: 'GH', color: Color(0xFF64748B)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_controller);

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.05, end: -0.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: -0.05, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            'assets/logo.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class OnboardingOrDashboardDirector extends StatelessWidget {
  const OnboardingOrDashboardDirector({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    if (!state.onboardingCompleted && state.currentUser == null) {
      return const OnboardingLoginScreen();
    }
    return const AppMainDashboardContainer();
  }
}

class OnboardingLoginScreen extends StatefulWidget {
  const OnboardingLoginScreen({super.key});

  @override
  State<OnboardingLoginScreen> createState() => _OnboardingLoginScreenState();
}

enum LoginFlowStep { splash, onboarding, login, verifyOtp, admissionForm }

class OnboardingPageData {
  final String title;
  final String description;
  final String image;
  final String tag;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.image,
    required this.tag,
  });
}

final List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    title: 'Healthy meals made fresh every day.',
    description: 'Our certified hospital-grade chefs curate low-sodium, nutrient-dense ingredients tailored for recovery and wellness.',
    image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600',
    tag: 'Freshly Prepared',
  ),
  OnboardingPageData(
    title: 'Delivered directly to your hospital room.',
    description: 'Zero contact, sealed insulation containers delivered directly to your bed ward, matching strict hospital timings.',
    image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=600',
    tag: 'Ward Service',
  ),
  OnboardingPageData(
    title: 'Choose your meal and recover better.',
    description: 'Customize calories, restrict salt, adjust spice, or omit onions/garlic to match your clinical requirements.',
    image: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&q=80&w=600',
    tag: 'Custom Nutrition',
  ),
];

class _OnboardingLoginScreenState extends State<OnboardingLoginScreen> {
  bool _hasShownSplash = false;
  bool _hasShownOnboarding = false;

  late LoginFlowStep _currentStep;

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _wardController = TextEditingController();
  final _roomController = TextEditingController();
  final _patientNotesController = TextEditingController();

  final _employeeNameController = TextEditingController();
  final _deptController = TextEditingController();
  final _employeeIdController = TextEditingController();

  UserRole _selectedRole = UserRole.Patient;
  String? _selectedHospitalId;
  String _selectedDiagnosis = 'General Recovery';
  final _formKey = GlobalKey<FormState>();

  int _onboardingPage = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false;
  bool _agreeToPrivacyPolicy = false;
  String? _phoneError;
  String? _otpError;
  String _tempPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    if (!_hasShownSplash) {
      _currentStep = LoginFlowStep.splash;
      _hasShownSplash = true;
      _startSplashTimer();
    } else if (!_hasShownOnboarding) {
      _currentStep = LoginFlowStep.onboarding;
    } else {
      _currentStep = LoginFlowStep.login;
    }
  }

  void _startSplashTimer() {
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _currentStep = LoginFlowStep.onboarding;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _patientNameController.dispose();
    _wardController.dispose();
    _roomController.dispose();
    _patientNotesController.dispose();
    _employeeNameController.dispose();
    _deptController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  void _sendOtpCode() {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() {
        _phoneError = 'Please enter a valid 10-digit phone number';
      });
      return;
    }
    setState(() {
      _phoneError = null;
      _isLoading = true;
    });
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _tempPhoneNumber = phone;
          _currentStep = LoginFlowStep.verifyOtp;
        });
      }
    });
  }

  void _verifyOtpCode() {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() {
        _otpError = 'Please enter the 6-digit verification code';
      });
      return;
    }
    setState(() {
      _otpError = null;
      _isLoading = true;
    });
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = LoginFlowStep.admissionForm;
        });
      }
    });
  }

  void _submitDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToPrivacyPolicy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must agree to the Privacy Policy & Clinical Terms'),
            backgroundColor: Color(0xFFC2410C),
          ),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });

      PatientDetails? pDetails;
      EmployeeDetails? eDetails;

      if (_selectedRole == UserRole.Patient) {
        pDetails = PatientDetails(
          roomNumber: _roomController.text,
          ward: _wardController.text,
          patientName: _patientNameController.text,
          notes: _patientNotesController.text,
          diagnosis: _selectedDiagnosis,
        );
      } else {
        eDetails = EmployeeDetails(
          employeeName: _employeeNameController.text,
          department: _deptController.text,
          employeeId: _employeeIdController.text,
        );
      }

      final profile = UserProfile(
        phone: _phoneController.text,
        role: _selectedRole,
        selectedHospitalId: _selectedHospitalId!,
        patientDetails: pDetails,
        employeeDetails: eDetails,
      );

      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          final state = Provider.of<AppState>(context, listen: false);
          state.loginUser(profile);
          state.completeOnboarding();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case LoginFlowStep.splash:
        return _buildSplashView();
      case LoginFlowStep.onboarding:
        return _buildOnboardingView();
      case LoginFlowStep.login:
        return _buildLoginView();
      case LoginFlowStep.verifyOtp:
        return _buildOtpView();
      case LoginFlowStep.admissionForm:
        return _buildAdmissionFormView();
    }
  }

  Widget _buildSplashView() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFBF7), Color(0xFFF0FDFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnimatedLogo(),
                const SizedBox(height: 24),
                const Text(
                  'Cura Meal',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'CLINICAL NUTRITION. SERVED WARM.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Partner hospital logos (Moved near the logo/title)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PARTNERED WITH 5 PREMIER HOSPITALS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E7D32),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _PartnerLogo(name: 'Welfare', initials: 'WF', color: Color(0xFF059669)),
                          _PartnerLogo(name: 'Shams Noor', initials: 'SN', color: Color(0xFF0EA5E9)),
                          _PartnerLogo(name: 'Lifecare', initials: 'LC', color: Color(0xFFF43F5E)),
                          _PartnerLogo(name: 'Asiya', initials: 'AS', color: Color(0xFF8B5CF6)),
                          _PartnerLogo(name: 'Government', initials: 'GH', color: Color(0xFF64748B)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingView() {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.translate('Cura Meal'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      final guestProfile = UserProfile(
                        phone: 'Guest',
                        role: UserRole.Patient,
                        selectedHospitalId: STAT_HOSPITALS[0].id,
                        patientDetails: PatientDetails(
                          roomNumber: 'G-10',
                          ward: 'General',
                          patientName: 'Recovery Guest',
                          notes: 'No specific notes',
                          diagnosis: 'General Recovery',
                        ),
                      );
                      state.loginUser(guestProfile);
                      state.completeOnboarding();
                    },
                    child: Text(
                      state.translate('Skip'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card 1: Active Page
                    Expanded(
                      child: _buildOnboardingCard(
                        context,
                        state,
                        onboardingPages[_onboardingPage],
                        isActive: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Card 2: Next Preview Page
                    Expanded(
                      child: _buildOnboardingCard(
                        context,
                        state,
                        onboardingPages[(_onboardingPage + 1) % onboardingPages.length],
                        isActive: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_onboardingPage > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _onboardingPage--;
                        });
                      },
                      child: Text(
                        state.translate('Back'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Row(
                    children: List.generate(
                      onboardingPages.length,
                      (idx) => Container(
                        width: _onboardingPage == idx ? 18 : 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: _onboardingPage == idx ? const Color(0xFF2E7D32) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_onboardingPage < onboardingPages.length - 1) {
                        setState(() {
                          _onboardingPage++;
                        });
                      } else {
                        final guestProfile = UserProfile(
                          phone: 'Guest',
                          role: UserRole.Patient,
                          selectedHospitalId: STAT_HOSPITALS[0].id,
                          patientDetails: PatientDetails(
                            roomNumber: 'G-10',
                            ward: 'General',
                            patientName: 'Recovery Guest',
                            notes: 'No specific notes',
                            diagnosis: 'General Recovery',
                          ),
                        );
                        state.loginUser(guestProfile);
                        state.completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Icon(
                      _onboardingPage < onboardingPages.length - 1
                          ? Icons.arrow_forward
                          : Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingCard(BuildContext context, AppState state, OnboardingPageData page, {required bool isActive}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive 
              ? const Color(0xFF2E7D32).withOpacity(0.15) 
              : const Color(0xFF2E7D32).withOpacity(0.06),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(isActive ? 0.06 : 0.03),
            blurRadius: isActive ? 12 : 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image block
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      page.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state.translate(page.tag),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            state.translate(page.title),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isActive ? const Color(0xFF2E7D32) : const Color(0xFF2E7D32).withOpacity(0.8),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // Description
          Expanded(
            flex: 4,
            child: Text(
              state.translate(page.description),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Status Badge at bottom
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isActive 
                  ? const Color(0xFF2E7D32).withOpacity(0.08) 
                  : const Color(0xFFFF9800).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isActive ? state.translate('Active Step') : state.translate('Coming Up'),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF2E7D32) : const Color(0xFFFF9800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginView() {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  state.translate('Verify Bedside Identity'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  state.translate('Synchronize with Bhatkal hospital ward database.'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: state.translate('Enter 10-digit mobile number'),
                  prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: _phoneError != null ? state.translate(_phoneError!) : null,
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtpCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(state.translate('Send Verification OTP'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  final guestProfile = UserProfile(
                    phone: 'Guest',
                    role: UserRole.Patient,
                    selectedHospitalId: STAT_HOSPITALS[0].id,
                    patientDetails: PatientDetails(
                      roomNumber: 'G-10',
                      ward: 'General',
                      patientName: 'Recovery Guest',
                      notes: 'No specific notes',
                      diagnosis: 'General Recovery',
                    ),
                  );
                  state.loginUser(guestProfile);
                  state.completeOnboarding();
                },
                child: Text(state.translate('Explore Menu as Guest'), style: const TextStyle(color: Color(0xFF2E7D32))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpView() {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  state.translate('Enter Security OTP'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  state.translate('Code sent to +91') + ' $_tempPhoneNumber',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Demo: Enter 123456 to verify simulation',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: state.translate('Enter 6-digit OTP'),
                  prefixIcon: const Icon(Icons.security, color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: _otpError != null ? state.translate(_otpError!) : null,
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep = LoginFlowStep.login;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(state.translate('Back')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtpCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(state.translate('Verify Code'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdmissionFormView() {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: Text(state.translate('Clinical Ward Registration'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.translate('YOUR CLINICAL ROLE'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text(state.translate('RECOVERY GUEST / ATTENDANT'))),
                      selected: _selectedRole == UserRole.Patient,
                      onSelected: (val) {
                        if (val) setState(() => _selectedRole = UserRole.Patient);
                      },
                      selectedColor: const Color(0xFFF0FDFA),
                      checkmarkColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color: _selectedRole == UserRole.Patient ? const Color(0xFF2E7D32) : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text(state.translate('HOSPITAL STAFF'))),
                      selected: _selectedRole == UserRole.Employee,
                      onSelected: (val) {
                        if (val) setState(() => _selectedRole = UserRole.Employee);
                      },
                      selectedColor: const Color(0xFFF0FDFA),
                      checkmarkColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color: _selectedRole == UserRole.Employee ? const Color(0xFF2E7D32) : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                state.translate('SELECT HEALTHCARE CENTRE'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedHospitalId,
                hint: const Text('Choose your hospital', style: TextStyle(fontSize: 13, color: Colors.grey)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (val) => val == null ? 'Please select a hospital' : null,
                items: STAT_HOSPITALS.map((h) {
                  return DropdownMenuItem<String>(
                    value: h.id,
                    child: Text(h.name, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedHospitalId = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedRole == UserRole.Patient) ...[
                Text(
                  state.translate('RECOVERY GUEST FULL NAME'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _patientNameController,
                  decoration: InputDecoration(
                    hintText: state.translate('Enter recovery guest name'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? state.translate('Please enter guest name') : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('WARD/UNIT'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _wardController,
                            decoration: InputDecoration(
                              hintText: 'e.g. ICU, General',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? state.translate('Required') : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('ROOM/BED NO'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _roomController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Bed 12-A',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? state.translate('Required') : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.translate('ADMISSION REASON / DIAGNOSIS'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedDiagnosis,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  items: STAT_DIAGNOSES.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(state.translate(d), style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDiagnosis = val);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  state.translate('CLINICAL DIETARY PREFERENCE/NOTES (OPTIONAL)'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _patientNotesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: state.translate('e.g. Diabetic menu, No salt in dal, soft food only'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ] else ...[
                Text(
                  state.translate('EMPLOYEE NAME'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _employeeNameController,
                  decoration: InputDecoration(
                    hintText: state.translate('Enter staff/employee name'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? state.translate('Please enter employee name') : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('DEPARTMENT'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _deptController,
                            decoration: InputDecoration(
                              hintText: 'e.g. ER, Cardiology',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? state.translate('Required') : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('STAFF ID / ID NO'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _employeeIdController,
                            decoration: InputDecoration(
                              hintText: 'e.g. EMP-99831',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? state.translate('Required') : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToPrivacyPolicy,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (val) {
                        setState(() {
                          _agreeToPrivacyPolicy = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showPrivacyPolicyDialog(context),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.4),
                          children: [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Privacy Policy & Clinical Terms',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: ' (specifically Google user safety standards for hospital bedsides & double-sanitized kitchen processing).',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(state.translate('Save Clinical Profile & Complete'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy & Patient Consent'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Privacy Policy & Data Protection',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Cura Meal is fully committed to protecting your clinical and personal data. This Privacy Policy outlines how we gather, store, and utilize your information to keep you safe and ensure compliant hospital-grade meal delivery.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Information Collection & Purpose',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '• Patient Coordinates: Room number, ward, and hospital name are used solely to deliver sterilized meals directly to your bedside.\n'
                  '• Clinical Dietary Details: Your diagnosis, food allergies, and doctor-prescribed diets are processed locally to filter out dangerous ingredients (e.g. sodium restriction for hypertension).\n'
                  '• Contact Data: Phone number is used for one-time OTP verification and delivery coordinates tracking.',
                  style: TextStyle(fontSize: 11, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '2. Google Play Developer Content Policy Compliance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '• Transparency: No data is shared with third-party advertisers or sold to secondary services.\n'
                  '• User Rights: You can request immediate deletion of your active bedside profile at any time through the preferences config.\n'
                  '• Security: All communications are encrypted using secure protocols to safeguard sensitive healthcare and nursing credentials.',
                  style: TextStyle(fontSize: 11, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '3. Medical Disclaimer & Risk Mitigation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Cura Meal works as a kitchen delivery service. While meals are prepared based on standard clinical diet cards, always consult your on-duty clinical nurse or treating physician before changing your dietary regimen.',
                  style: TextStyle(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}

class AppMainDashboardContainer extends StatefulWidget {
  const AppMainDashboardContainer({super.key});

  @override
  State<AppMainDashboardContainer> createState() => _AppMainDashboardContainerState();
}

class _AppMainDashboardContainerState extends State<AppMainDashboardContainer> {
  int _currentIndex = 0;
  Timer? _checkInTimer;

  final List<Widget> _tabs = [
    const MealDashboardScreen(),
    const SearchTabScreen(),
    const CarePackTabScreen(),
    const HistoryTabScreen(),
    const SettingsTabScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startCheckInTimer();
  }

  void _startCheckInTimer() {
    _checkInTimer = Timer(const Duration(minutes: 2), () {
      if (mounted) {
        final state = Provider.of<AppState>(context, listen: false);
        final isGuest = state.currentUser == null || state.currentUser?.phone == 'Guest';
        if (isGuest) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => ClinicalCheckInSheet(
              title: "Link Your Clinical Ward Profile",
              subtitle: "Pre-link your hospital bed space to enable lightning-fast kitchen delivery coordination.",
              onComplete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clinical profile pre-linked & saved!'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              },
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _checkInTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey[500],
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home, key: Key('nav-home-tab')),
            label: state.translate('Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search, key: Key('nav-search-tab')),
            label: state.translate('Search'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite, key: Key('nav-carepack-tab')),
            label: state.translate('Care Pack'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag, key: Key('nav-orders-tab')),
            label: state.translate('Orders'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings, key: Key('nav-settings-tab')),
            label: state.translate('Settings'),
          ),
        ],
      ),
    );
  }
}

class _PartnerLogo extends StatelessWidget {
  final String name;
  final String initials;
  final Color color;

  const _PartnerLogo({
    required this.name,
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A1E),
          ),
        ),
      ],
    );
  }
}
