import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.Received:
        return const Color(0xFFF59E0B); // Amber/Yellow
      case OrderStatus.Preparing:
        return const Color(0xFF3B82F6); // Blue
      case OrderStatus.OutForDelivery:
        return const Color(0xFF6366F1); // Indigo
      case OrderStatus.Delivered:
        return const Color(0xFF10B981); // Emerald Green
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.Received:
        return 'Received';
      case OrderStatus.Preparing:
        return 'Preparing';
      case OrderStatus.OutForDelivery:
        return 'Out For Delivery';
      case OrderStatus.Delivered:
        return 'Delivered';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final orders = state.adminOrders;

    // Statistics
    final double totalRevenue = orders.fold(0.0, (sum, o) => sum + o.grandTotal);
    final int receivedCount = orders.where((o) => o.status == OrderStatus.Received).length;
    final int preparingCount = orders.where((o) => o.status == OrderStatus.Preparing || o.status == OrderStatus.OutForDelivery).length;
    final int completedCount = orders.where((o) => o.status == OrderStatus.Delivered).length;

    // Filtered orders for tab 1
    final filteredOrders = orders.where((o) {
      if (_selectedStatusFilter == 'All') return true;
      if (_selectedStatusFilter == 'Received') return o.status == OrderStatus.Received;
      if (_selectedStatusFilter == 'Preparing') return o.status == OrderStatus.Preparing;
      if (_selectedStatusFilter == 'Out For Delivery') return o.status == OrderStatus.OutForDelivery;
      if (_selectedStatusFilter == 'Delivered') return o.status == OrderStatus.Delivered;
      return true;
    }).toList();

    // Derive unique guest directory list from orders history
    final List<Map<String, String>> guestDirectory = [];
    final Set<String> uniqueGuestNames = {};
    for (final o in orders) {
      final name = o.patientName ?? "Admitted Guest";
      if (!uniqueGuestNames.contains(name)) {
        uniqueGuestNames.add(name);
        guestDirectory.add({
          'name': name,
          'ward': o.patientWard ?? "General Ward",
          'room': o.patientRoom ?? "G-10",
          'diagnosis': o.patientDiagnosis ?? "General Recovery Care",
          'lastOrder': o.orderNumber,
          'time': '${o.createdAt.hour.toString().padLeft(2, '0')}:${o.createdAt.minute.toString().padLeft(2, '0')}',
        });
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate Navy
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Slate Blue-Gray
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield, color: Color(0xFFF59E0B), size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KITCHEN ADMIN SETUP',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Clinical Sterilization & Inpatient Despatch',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Back to App',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats Summary Widget
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                _buildStatItem('REVENUE', '₹${totalRevenue.toStringAsFixed(0)}', const Color(0xFF10B981)),
                const SizedBox(width: 6),
                _buildStatItem('RECEIVED', '$receivedCount', const Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                _buildStatItem('PREPARING', '$preparingCount', const Color(0xFF3B82F6)),
                const SizedBox(width: 6),
                _buildStatItem('COMPLETED', '$completedCount', const Color(0xFF10B981)),
              ],
            ),
          ),

          // Custom Dark Mode Tab Bar
          Container(
            color: const Color(0xFF1E293B),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFF59E0B),
              indicatorWeight: 3,
              labelColor: const Color(0xFFF59E0B),
              unselectedLabelColor: Colors.grey.shade400,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              tabs: const [
                Tab(
                  icon: Icon(Icons.receipt_long, size: 18),
                  text: 'ORDERS PLACED',
                ),
                Tab(
                  icon: Icon(Icons.people_outline, size: 18),
                  text: 'GUEST DIRECTORY',
                ),
                Tab(
                  icon: Icon(Icons.settings, size: 18),
                  text: 'SETUP SETTINGS',
                ),
              ],
            ),
          ),

          // Tab content area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Orders Placed
                _buildOrdersTab(context, state, filteredOrders, orders),

                // Tab 2: Guest Directory
                _buildGuestDirectoryTab(guestDirectory),

                // Tab 3: Setup Settings
                _buildSetupSettingsTab(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 0.5),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context, AppState state, List<ActiveOrder> filteredOrders, List<ActiveOrder> allOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Custom horizontal filter scroll
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Received', 'Preparing', 'Out For Delivery', 'Delivered'].map((filter) {
              final isSelected = _selectedStatusFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    filter.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFF59E0B),
                  backgroundColor: const Color(0xFF1E293B),
                  checkmarkColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF334155),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatusFilter = filter;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Orders list
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey.shade600),
                      const SizedBox(height: 12),
                      Text(
                        'No kitchen orders found under "$_selectedStatusFilter"',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: filteredOrders.length,
                  itemBuilder: (ctx, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(context, state, order);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, AppState state, ActiveOrder order) {
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER: ${order.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Placed: ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')} | ${order.hospitalName}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF334155)),

          // Guest & Location Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    Text(
                      'Recovery Guest: ${order.patientName ?? "Admitted Guest"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Room: ${order.patientRoom ?? "G-10"}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                      Text(
                        'Ward: ${order.patientWard ?? "General"}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                      Text(
                        'Focus: ${order.patientDiagnosis ?? "General Recovery"}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF334155)),

          // Items List
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ITEMS ORDERED:',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.quantity}x ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF59E0B)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.meal.name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Prep: ${item.customization.summary}',
                                style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${(item.meal.price * item.quantity).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grand Total (with Tax & Delivery):',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                    ),
                    Text(
                      '₹${order.grandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF334155)),

          // Accept & Update Actions
          if (order.status != OrderStatus.Delivered)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButtons(context, state, order),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppState state, ActiveOrder order) {
    if (order.status == OrderStatus.Received) {
      return ElevatedButton.icon(
        onPressed: () {
          state.updateAdminOrderStatus(order.id, OrderStatus.Preparing);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ${order.orderNumber} accepted! Preparation in progress.'),
              backgroundColor: const Color(0xFF3B82F6),
            ),
          );
        },
        icon: const Icon(Icons.check_circle_outline, size: 14),
        label: const Text('Accept & Prepare'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (order.status == OrderStatus.Preparing) {
      return ElevatedButton.icon(
        onPressed: () {
          state.updateAdminOrderStatus(order.id, OrderStatus.OutForDelivery);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ${order.orderNumber} dispatched for delivery!'),
              backgroundColor: const Color(0xFF6366F1),
            ),
          );
        },
        icon: const Icon(Icons.delivery_dining, size: 14),
        label: const Text('Dispatch Order'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (order.status == OrderStatus.OutForDelivery) {
      return ElevatedButton.icon(
        onPressed: () {
          state.updateAdminOrderStatus(order.id, OrderStatus.Delivered);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ${order.orderNumber} confirmed as delivered!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
        icon: const Icon(Icons.done_all, size: 14),
        label: const Text('Confirm Delivery'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGuestDirectoryTab(List<Map<String, String>> guestDirectory) {
    if (guestDirectory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey.shade600),
              const SizedBox(height: 12),
              const Text(
                'No admitted guests registered yet.',
                style: TextStyle(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'When orders are placed, details will auto-populate here.',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: guestDirectory.length,
      itemBuilder: (ctx, index) {
        final guest = guestDirectory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hotel_outlined, color: Color(0xFFF59E0B), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${guest['ward']} | Room ${guest['room']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dietary Focus: ${guest['diagnosis']}',
                      style: const TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Last Ref: ${guest['lastOrder']}',
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      guest['time']!,
                      style: const TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSetupSettingsTab(BuildContext context, AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSettingsHeader('Sterilization Control Logs'),
          _buildLogItem('Kitchen Entry Temperature Checks', 'PASSED 36.4°C', Icons.thermostat),
          _buildLogItem('UV-C Tray Box Sanitize Loop', 'COMPLETED 90s', Icons.wb_sunny_outlined),
          _buildLogItem('Double-Induction Thermal Seal', 'ACTIVE 180°C', Icons.security),
          const SizedBox(height: 16),
          _buildSettingsHeader('System Quick Controls'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.flash_on, color: Color(0xFFF59E0B)),
                  title: const Text('Simulate Fast Notification Loop', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Forces instant order pipeline step updates for testing.', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      state.simulateTimelineTick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Simulated timeline transition ticked manually!'),
                          backgroundColor: Color(0xFFF59E0B),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: const Text('TICK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Divider(color: Color(0xFF334155)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.refresh, color: Colors.white70),
                  title: const Text('Reset All Simulated History', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Clears out the entire admin history and order cache.', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  trailing: TextButton(
                    onPressed: () {
                      state.clearOrderHistory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All order history cleared!'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                    child: const Text('CLEAR', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B), letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildLogItem(String title, String status, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
