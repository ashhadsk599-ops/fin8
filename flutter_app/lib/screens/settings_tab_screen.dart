import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';
import 'package:cura_meal/screens/admin_portal_screen.dart';
import 'package:cura_meal/screens/clinical_checkin_sheet.dart';

class SettingsTabScreen extends StatefulWidget {
  const SettingsTabScreen({super.key});

  @override
  State<SettingsTabScreen> createState() => _SettingsTabScreenState();
}

class _SettingsTabScreenState extends State<SettingsTabScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final selectedLanguage = state.selectedLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: Text(state.translate('Preferences'), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Profile Card Section
          _buildProfileCard(context, state),
          const SizedBox(height: 16),

          // Push notifications toggle
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              activeColor: const Color(0xFF2E7D32),
              title: Text(state.translate('Push Notifications'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(state.translate('Admitted status alarms: Pings when sterile container leaves kitchen.'), style: const TextStyle(fontSize: 11)),
              value: state.notificationsEnabled,
              onChanged: (val) {
                state.setNotificationsEnabled(val);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Language Setting
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 8),
                      Text(state.translate('Language Settings'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['English', 'Kannada', 'Urdu'].map((lang) {
                      final isSelected = selectedLanguage == lang;
                      return InkWell(
                        onTap: () {
                          state.setSelectedLanguage(lang);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF2E7D32).withOpacity(0.3),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Text(
                            lang,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.translate('Bhatkal healthcare units support English, local Kannada, and Urdu diets.'),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hospital Admin Portal Card Button
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.admin_panel_settings, color: Color(0xFF2E7D32)),
              ),
              title: Text(
                state.translate('Hospital Admin Portal'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: Text(
                state.translate('Accept bedside orders, monitor diet coordinates & track preparation.'),
                style: const TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF2E7D32)),
              onTap: () {
                _showAdminPasswordDialog(context, state);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Compliance & Info Card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.translate('Compliance & Health Info'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32))),
                  const SizedBox(height: 16),
                  
                  _buildComplianceRow(
                    Icons.security,
                    state.translate('Sterilized Kitchen Security'),
                    state.translate('Cura Meal operates in high-efficiency hospital zones. Delivery staff undergo double temperature checks.'),
                  ),
                  const Divider(height: 24),
                  _buildComplianceRow(
                    Icons.description_outlined,
                    state.translate('Guest Terms & Privacy'),
                    state.translate('We maintain strict adherence to hospital privacy rules. Bedside coordinates are wiped from records upon delivery confirmation. Tap to view full Privacy Policy & Clinical Terms.'),
                    onTap: () => _showPrivacyPolicyDialog(context, state),
                  ),
                  const Divider(height: 24),
                  _buildComplianceRow(
                    Icons.help_outline,
                    state.translate('Dial Bedside Emergency Help'),
                    state.translate('If you face severe food intolerance or need urgent medical attention, please inform your ward nurse or ring the bedside assistance alarm immediately.'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign Out Action Card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFFFEBEE))),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: Text(
                state.translate('Sign Out'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
              ),
              subtitle: Text(
                state.translate('Sign out of your active bedside session on this device.'),
                style: const TextStyle(fontSize: 11),
              ),
              onTap: () {
                state.logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminPasswordDialog(BuildContext context, AppState state) {
    final TextEditingController passwordController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFDF7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    state.translate('Admin Verification'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.translate('Please enter the security password to open the Hospital Admin Portal (Try "admin123").'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: state.translate('Enter Password'),
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                      ),
                      errorText: errorMessage != null ? state.translate(errorMessage!) : null,
                      errorStyle: const TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    state.translate('Cancel'),
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text == 'admin123') {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminPortalScreen()),
                      );
                    } else {
                      setState(() {
                        errorMessage = 'Incorrect password! Please try again.';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    state.translate('Verify'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFDF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(state.translate('Privacy Policy & Patient Consent')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.translate('Privacy Policy & Data Protection'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 8),
                Text(
                  state.translate('Cura Meal is fully committed to protecting your clinical and personal data. This Privacy Policy outlines how we gather, store, and utilize your information to keep you safe and ensure compliant hospital-grade meal delivery.'),
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  state.translate('1. Information Collection & Purpose'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 4),
                Text(
                  '• ${state.translate('Patient Coordinates')}: ${state.translate('Room number, ward, and hospital name are used solely to deliver sterilized meals directly to your bedside.')}\n'
                  '• ${state.translate('Clinical Dietary Details')}: ${state.translate('Your diagnosis, food allergies, and doctor-prescribed diets are processed locally to filter out dangerous ingredients.')}\n'
                  '• ${state.translate('Contact Data')}: ${state.translate('Phone number is used for one-time OTP verification and delivery coordinates tracking.')}',
                  style: const TextStyle(fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  state.translate('2. Google Play Developer Content Policy Compliance'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 4),
                Text(
                  '• ${state.translate('Transparency')}: ${state.translate('No data is shared with third-party advertisers or sold to secondary services.')}\n'
                  '• ${state.translate('User Rights')}: ${state.translate('You can request immediate deletion of your active bedside profile at any time.')}\n'
                  '• ${state.translate('Security')}: ${state.translate('All communications are encrypted using secure protocols.')}',
                  style: const TextStyle(fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 12),
                Text(
                  state.translate('3. Medical Disclaimer & Risk Mitigation'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 4),
                Text(
                  state.translate('Cura Meal works as a kitchen delivery service. While meals are prepared based on standard clinical diet cards, always consult your on-duty clinical nurse or treating physician before changing your dietary regimen.'),
                  style: const TextStyle(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              state.translate('CLOSE'),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(IconData icon, String title, String desc, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      decoration: onTap != null ? TextDecoration.underline : null,
                      color: onTap != null ? const Color(0xFF2E7D32) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppState state) {
    final user = state.currentUser;
    final isGuest = user == null || user.phone == 'Guest';

    String name = 'Guest Recipient';
    String phone = 'Guest Access';
    String roleStr = 'Recovery Guest';
    
    if (user != null) {
      roleStr = user.role == UserRole.Patient ? 'Recovery Guest' : 'Hospital Employee';
      phone = user.phone == 'Guest' ? 'Guest Access' : user.phone;
      if (user.role == UserRole.Patient) {
        name = user.patientDetails?.patientName ?? 'Guest Recipient';
      } else {
        name = user.employeeDetails?.employeeName ?? 'Staff Member';
      }
    }

    final String hospitalName = STAT_HOSPITALS.firstWhere(
      (h) => h.id == (user?.selectedHospitalId ?? state.guestHospitalId),
      orElse: () => STAT_HOSPITALS[0],
    ).name;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                  child: const Icon(Icons.person, color: Color(0xFF2E7D32), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleStr.toUpperCase(),
                    style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFFFF9800)),
                  ),
                ),
              ],
            ),
            if (!isGuest && user != null && user.role == UserRole.Patient && user.patientDetails != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileDetailRow(Icons.local_hospital, 'Hospital Unit', hospitalName),
                    const SizedBox(height: 6),
                    _buildProfileDetailRow(Icons.bedroom_parent, 'Ward & Floor', user.patientDetails!.ward),
                    const SizedBox(height: 6),
                    _buildProfileDetailRow(Icons.vpn_key, 'Room & Bed No', 'Room ${user.patientDetails!.roomNumber}'),
                    const SizedBox(height: 6),
                    _buildProfileDetailRow(Icons.healing, 'Dietary Category', user.patientDetails!.diagnosis),
                    if (user.patientDetails!.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildProfileDetailRow(Icons.notes, 'Kitchen Notes', '"${user.patientDetails!.notes}"'),
                    ],
                  ],
                ),
              )
            ] else if (!isGuest && user != null && user.role == UserRole.Employee && user.employeeDetails != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileDetailRow(Icons.local_hospital, 'Hospital Unit', hospitalName),
                    const SizedBox(height: 6),
                    _buildProfileDetailRow(Icons.badge, 'Department', user.employeeDetails!.department),
                    const SizedBox(height: 6),
                    _buildProfileDetailRow(Icons.assignment_ind, 'Staff ID No', user.employeeDetails!.employeeId),
                  ],
                ),
              )
            ] else ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You are currently using the app with a temporary guest profile. To unlock tailored clinical nutrition:',
                      style: TextStyle(fontSize: 10, color: Colors.black87, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => ClinicalCheckInSheet(
                            onComplete: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bedside clinical profile linked successfully!'),
                                  backgroundColor: Color(0xFF2E7D32),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'REGISTER BEDSIDE PROFILE →',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFFF9800)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 10, color: Colors.black87, height: 1.3),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                TextSpan(text: value, style: const TextStyle(color: Color(0xFF334155))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
