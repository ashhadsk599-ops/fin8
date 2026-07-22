import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';
import 'package:cura_meal/screens/cart_and_checkout_screen.dart';
import 'package:cura_meal/widgets/bedside_location_map.dart';

class HistoryTabScreen extends StatelessWidget {
  const HistoryTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: const Text('Recovery Progress & History', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${state.cart.length}'),
              isLabelVisible: state.cart.isNotEmpty,
              child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2E7D32)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartAndCheckoutScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User profile info card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFF2E7D32),
                      radius: 24,
                      child: Icon(Icons.health_and_safety, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.role == UserRole.Patient
                                ? '${user?.patientDetails?.patientName}'
                                : (user?.role == UserRole.Employee ? '${user?.employeeDetails?.employeeName}' : 'Guest Recipient'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.role == UserRole.Patient
                                ? 'Recovery Guest (Room: ${user?.patientDetails?.roomNumber})'
                                : (user?.role == UserRole.Employee ? 'Hospital Staff (ID: ${user?.employeeDetails?.employeeId})' : 'Guest'),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Active order tracker
            if (state.activeOrder != null) ...[
              const Text(
                'LIVE BEDSIDE TRACKING',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Number: ${state.activeOrder!.orderNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.activeOrder!.status.toString().split('.').last,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildTrackerStep(
                        'Order Received & Sanitized',
                        'Kitchen confirmed receipt of dietary instructions.',
                        state.activeOrder!.status.index >= 0,
                        isFirst: true,
                      ),
                      _buildTrackerStep(
                        'Preparation Underway',
                        'Preparing sterilised diet with premium ingredients.',
                        state.activeOrder!.status.index >= 1,
                      ),
                      _buildTrackerStep(
                        'Out for Bedside Delivery',
                        'Sterile container dispatched to your ward.',
                        state.activeOrder!.status.index >= 2,
                      ),
                      _buildTrackerStep(
                        'Delivered & Confirmed',
                        'Placed safely on your bedside tray.',
                        state.activeOrder!.status.index >= 3,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BedsideLiveLocationMap(status: state.activeOrder!.status),
              const SizedBox(height: 16),
            ],

            // Past Orders
            const Text(
              'PAST NUTRITIONAL ORDERS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            if (state.pastOrders.isEmpty)
              const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No previous bedside meals requested in this session.',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...state.pastOrders.map((ord) {
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(ord.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('₹${ord.grandTotal.toStringAsFixed(2)} | Delivered successfully', style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerStep(String title, String desc, bool isDone, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF2E7D32) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isDone ? const Color(0xFF2E7D32) : Colors.grey[300],
              ),
          ],
        ),
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
                  color: isDone ? Colors.black87 : Colors.grey,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 10,
                  color: isDone ? Colors.black54 : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
