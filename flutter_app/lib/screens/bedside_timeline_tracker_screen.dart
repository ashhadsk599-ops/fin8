import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class BedsideTimelineTrackerScreen extends StatelessWidget {
  const BedsideTimelineTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final order = state.activeOrder;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bedside Delivery Timeline', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: order == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timeline_outlined, size: 72, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('No active bedside tracking active.', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Your clinical meal tracking timeline will automatically show up here once you confirm order dispatch.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active order billing header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order Number:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Destination:'),
                            Text('${state.selectedHospital?.name}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bed Space:'),
                            Text(
                              state.currentUser?.role == UserRole.Patient
                                  ? '${state.currentUser?.patientDetails?.ward}, ${state.currentUser?.patientDetails?.roomNumber}'
                                  : 'Staff - ${state.currentUser?.employeeDetails?.department}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Real-Time Live Bedside Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  // STEP 1: RECEIVED
                  _buildTimelineStep(
                    title: 'Clinical Order Approved',
                    subtitle: 'Directives checked. Nutritional composition synced with diet notes.',
                    icon: Icons.check_circle,
                    isCompleted: order.status.index >= OrderStatus.Received.index,
                    isActive: order.status == OrderStatus.Received,
                  ),

                  // STEP 2: PREPARING
                  _buildTimelineStep(
                    title: 'Kitchen Customized Cooking',
                    subtitle: 'Salt restrictions and allergen directives checked. Double sealing...',
                    icon: Icons.soup_kitchen,
                    isCompleted: order.status.index >= OrderStatus.Preparing.index,
                    isActive: order.status == OrderStatus.Preparing,
                  ),

                  // STEP 3: OUT FOR DELIVERY
                  _buildTimelineStep(
                    title: 'Courier Bedside Ascent',
                    subtitle: 'Executive is carrying insulated warm container directly to your bed.',
                    icon: Icons.directions_bike,
                    isCompleted: order.status.index >= OrderStatus.OutForDelivery.index,
                    isActive: order.status == OrderStatus.OutForDelivery,
                  ),

                  // STEP 4: DELIVERED
                  _buildTimelineStep(
                    title: 'Bedside Handover Complete',
                    subtitle: 'Nutritional meal successfully verified and received bedside.',
                    icon: Icons.room_service,
                    isCompleted: order.status.index >= OrderStatus.Delivered.index,
                    isActive: order.status == OrderStatus.Delivered,
                    isLast: true,
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Simulation auto-advances stages to let you view bedside tracking details...',
                      style: TextStyle(fontSize: 10, color: Colors.grey[400], fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    final color = isActive
        ? const Color(0xFF2E7D32)
        : isCompleted
            ? Colors.green[700]
            : Colors.grey[400];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2E7D32) : color?.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color ?? Colors.grey, width: 2),
              ),
              child: Icon(icon, color: isActive ? Colors.white : color, size: 22),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 55,
                color: isCompleted ? Colors.green[700] : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF2E7D32) : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                if (isActive) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(4)),
                    child: const Text('LIVE ACTIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
          ),
        )
      ],
    );
  }
}
