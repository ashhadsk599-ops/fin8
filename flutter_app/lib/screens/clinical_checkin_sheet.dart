import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class ClinicalCheckInSheet extends StatefulWidget {
  final VoidCallback onComplete;
  final String? title;
  final String? subtitle;

  const ClinicalCheckInSheet({
    super.key,
    required this.onComplete,
    this.title,
    this.subtitle,
  });

  @override
  State<ClinicalCheckInSheet> createState() => _ClinicalCheckInSheetState();
}

enum CheckInStep { phone, otp, details }

class _ClinicalCheckInSheetState extends State<ClinicalCheckInSheet> {
  CheckInStep _currentStep = CheckInStep.phone;
  bool _isLoading = false;

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
  String _selectedDiagnosis = STAT_DIAGNOSES[0];
  final _formKey = GlobalKey<FormState>();

  String? _phoneError;
  String? _otpError;
  String _tempPhoneNumber = '';
  bool _agreeToPrivacyPolicy = false;

  @override
  void dispose() {
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
    if (_selectedHospitalId == null) {
      setState(() {
        _phoneError = 'Please select a hospital';
      });
      return;
    }
    if (phone.length < 10) {
      setState(() {
        _phoneError = 'Please enter a valid 10-digit phone number';
      });
      return;
    }
    if (!_agreeToPrivacyPolicy) {
      setState(() {
        _phoneError = 'You must agree to the Privacy Policy & Clinical Terms';
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
          _currentStep = CheckInStep.otp;
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
          _currentStep = CheckInStep.details;
        });
      }
    });
  }

  void _submitDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      UserProfile profile;
      if (_selectedRole == UserRole.Patient) {
        profile = UserProfile(
          phone: _tempPhoneNumber,
          role: UserRole.Patient,
          selectedHospitalId: _selectedHospitalId!,
          patientDetails: PatientDetails(
            patientName: _patientNameController.text.trim(),
            ward: _wardController.text.trim(),
            roomNumber: _roomController.text.trim(),
            notes: _patientNotesController.text.trim(),
            diagnosis: _selectedDiagnosis,
          ),
        );
      } else {
        profile = UserProfile(
          phone: _tempPhoneNumber,
          role: UserRole.Employee,
          selectedHospitalId: _selectedHospitalId!,
          employeeDetails: EmployeeDetails(
            employeeName: _employeeNameController.text.trim(),
            department: _deptController.text.trim(),
            employeeId: _employeeIdController.text.trim(),
          ),
        );
      }

      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          final state = Provider.of<AppState>(context, listen: false);
          state.loginUser(profile);
          Navigator.pop(context);
          widget.onComplete();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.security, color: Color(0xFF2E7D32), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title ?? 'Clinical Bedside Check-In',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle ?? 'Link your active ward admission to place verified dietary orders.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildCurrentStepContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case CheckInStep.phone:
        return _buildPhoneStep();
      case CheckInStep.otp:
        return _buildOtpStep();
      case CheckInStep.details:
        return _buildDetailsStep();
    }
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'YOUR CLINICAL ROLE',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('RECOVERY GUEST / ATTENDANT')),
                selected: _selectedRole == UserRole.Patient,
                onSelected: (val) {
                  if (val) setState(() => _selectedRole = UserRole.Patient);
                },
                selectedColor: const Color(0xFFF0FDFA),
                checkmarkColor: const Color(0xFF2E7D32),
                labelStyle: TextStyle(
                  color: _selectedRole == UserRole.Patient ? const Color(0xFF2E7D32) : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('HOSPITAL STAFF')),
                selected: _selectedRole == UserRole.Employee,
                onSelected: (val) {
                  if (val) setState(() => _selectedRole = UserRole.Employee);
                },
                selectedColor: const Color(0xFFF0FDFA),
                checkmarkColor: const Color(0xFF2E7D32),
                labelStyle: TextStyle(
                  color: _selectedRole == UserRole.Employee ? const Color(0xFF2E7D32) : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'SELECT HEALTHCARE CENTRE',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedHospitalId,
          hint: const Text('Choose your hospital', style: TextStyle(fontSize: 14, color: Colors.grey)),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            fillColor: Colors.white,
            filled: true,
          ),
          items: STAT_HOSPITALS.map((h) {
            return DropdownMenuItem<String>(
              value: h.id,
              child: Text(h.name, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedHospitalId = val);
            }
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'MOBILE NUMBER',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Enter 10-digit mobile number',
            prefixIcon: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            errorText: _phoneError,
            fillColor: Colors.white,
            filled: true,
          ),
        ),
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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtpCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Send Verification OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'We have sent a 6-digit verification code to +91 $_tempPhoneNumber.',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please enter 123456 as the demo simulation verification code.',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
        ),
        const SizedBox(height: 16),
        const Text(
          '6-DIGIT OTP CODE',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Enter 6-digit code (123456)',
            prefixIcon: const Icon(Icons.lock_clock, color: Color(0xFF2E7D32)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            errorText: _otpError,
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = CheckInStep.phone),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtpCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verify & Continue', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedRole == UserRole.Patient) ...[
            const Text(
              'RECOVERY GUEST FULL NAME',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _patientNameController,
              decoration: InputDecoration(
                hintText: 'Enter recovery guest name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                fillColor: Colors.white,
                filled: true,
              ),
              validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter guest name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WARD/UNIT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _wardController,
                        decoration: InputDecoration(
                          hintText: 'e.g. General, ICU, B3',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ROOM/BED NO',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _roomController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Bed 402-A',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'ADMISSION REASON / DIAGNOSIS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
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
                  child: Text(d, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDiagnosis = val);
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'CLINICAL DIETARY PREFERENCE/NOTES (OPTIONAL)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _patientNotesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Diabetic menu, No salt in dal, soft food only',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ] else ...[
            const Text(
              'EMPLOYEE NAME',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _employeeNameController,
              decoration: InputDecoration(
                hintText: 'Enter staff/employee name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                fillColor: Colors.white,
                filled: true,
              ),
              validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter employee name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DEPARTMENT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _deptController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Cardiology, ER',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STAFF ID / ID NO',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 0.5),
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
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Clinical Profile & Complete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
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
