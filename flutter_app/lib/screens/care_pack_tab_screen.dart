import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class CarePackTabScreen extends StatefulWidget {
  const CarePackTabScreen({super.key});

  @override
  State<CarePackTabScreen> createState() => _CarePackTabScreenState();
}

class _CarePackTabScreenState extends State<CarePackTabScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lovedOneNameController = TextEditingController();
  final _wardController = TextEditingController();
  final _roomController = TextEditingController();
  String _selectedHospitalId = STAT_HOSPITALS[0].id;
  String _errorText = '';
  bool _isSuccess = false;

  @override
  void dispose() {
    _lovedOneNameController.dispose();
    _wardController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _handleSubmit(AppState state) {
    setState(() {
      _errorText = '';
    });

    final name = _lovedOneNameController.text.trim();
    final ward = _wardController.text.trim();
    final room = _roomController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorText = "Please enter your loved one's name";
      });
      return;
    }
    if (_selectedHospitalId.isEmpty) {
      setState(() {
        _errorText = "Please choose your hospital location";
      });
      return;
    }
    if (ward.isEmpty) {
      setState(() {
        _errorText = 'Please enter a ward number';
      });
      return;
    }
    if (room.isEmpty) {
      setState(() {
        _errorText = 'Please enter a room number';
      });
      return;
    }

    state.sendCarePack(
      lovedOneName: name,
      hospitalId: _selectedHospitalId,
      ward: ward,
      roomNumber: room,
    );

    setState(() {
      _isSuccess = true;
    });

    // Clear input fields
    _lovedOneNameController.clear();
    _wardController.clear();
    _roomController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    if (_isSuccess) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFDF7),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state.translate('Care Pack Configured!'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.translate(
                    'Bedspace details have been safely linked. Choose nutritious diets and premium caregiver essentials to send now!',
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF777777),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSuccess = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      state.translate('Configure Another Pack'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: Text(
          state.translate('Send a Care Pack'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header description block
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              state.translate('HOSPITAL SUPPORT FLOW'),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.translate('Nourish a Loved One'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Included pack details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list_alt, color: Color(0xFFFF9800), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          state.translate('What is Included in the Care Pack'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    _buildIncludedItem(
                      '🛏️',
                      state.translate('Overnight Caregiver Comfort Pack'),
                      state.translate(
                        'Premium orthopedic memory foam neck pillow, warm flannel blanket, 100% blackout eyeshade, and clinical earplugs for sound sleep on ward recliners.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildIncludedItem(
                      '🍲',
                      state.translate('Steaming Hot Diets & Lunch Plates'),
                      state.translate(
                        'Low-sodium, non-greasy breakfast (Khichdi or high-fiber Upma) and custom-balanced protein lunch plates tailored for nursing environments.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildIncludedItem(
                      '🥤',
                      state.translate('Cold-Pressed Nourishing Juices'),
                      state.translate(
                        '100% raw tender coconut water and iron-rich beetroot detox juices to double hydration and maintain strong caregiver immunity.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildIncludedItem(
                      '🧴',
                      state.translate('Sanitization & Hygiene Shield'),
                      state.translate(
                        'Instant medical-grade hand sanitizer (70% alcohol-based) and sterile antibacterial wet wipes for bedside safety and infection control.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_errorText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFEBAA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Color(0xFFFF9800), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.translate(_errorText),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF856404),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Bedside form fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFFF9800), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          state.translate('Bedside Handoff Details'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Loved one's name
                    Text(
                      state.translate("LOVED ONE'S FULL NAME"),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _lovedOneNameController,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1B1B1B)),
                      decoration: InputDecoration(
                        hintText: state.translate('e.g. Rayan Ahmed'),
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFFDF7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hospital location drop down
                    Text(
                      state.translate('HOSPITAL LOCATION'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedHospitalId,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1B1B1B)),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: STAT_HOSPITALS.map((h) {
                        return DropdownMenuItem<String>(
                          value: h.id,
                          child: Text(
                            '${h.name} (${h.location})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedHospitalId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ward & Room grid
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.translate('WARD NUMBER'),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _wardController,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF1B1B1B)),
                                decoration: InputDecoration(
                                  hintText: state.translate('e.g. Ward 4B'),
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFFFDF7),
                                ),
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
                                state.translate('ROOM / BED NUMBER'),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _roomController,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF1B1B1B)),
                                decoration: InputDecoration(
                                  hintText: state.translate('e.g. Bed 102'),
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFFFDF7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8F5E9)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFFFF9800), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.translate(
                                'Our clinical food delivery agent will transport the items inside hospital gates directly to the specified bedside safely.',
                              ),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleSubmit(state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.favorite, size: 16),
                        label: Text(
                          state.translate('SELECT DIETS & ESSENTIALS'),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncludedItem(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
