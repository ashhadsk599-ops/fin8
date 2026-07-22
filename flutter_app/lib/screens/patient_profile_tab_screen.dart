import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class PatientProfileTabScreen extends StatelessWidget {
  const PatientProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final user = state.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hospital Ward Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Meta Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF2E7D32),
                    radius: 30,
                    child: Icon(Icons.health_and_safety, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.role == UserRole.Patient
                        ? '${user?.patientDetails?.patientName}'
                        : '${user?.employeeDetails?.employeeName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    user?.role == UserRole.Patient
                        ? 'Recovery Guest (Room: ${user?.patientDetails?.roomNumber})'
                        : 'Hospital Staff (ID: ${user?.employeeDetails?.employeeId})',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text('Phone Contact: +91 ${user?.phone}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FAVORITES SECTION
            const Text('Starred Nutritional Meals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (state.favorites.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No dietary options starred yet.', style: TextStyle(fontSize: 11, color: Colors.grey)),
              )
            else
              ...state.favorites.map((favId) {
                final m = STAT_MEALS.firstWhere((meal) => meal.id == favId);
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: Image.network(m.image, width: 40, height: 40, fit: BoxFit.cover),
                    title: Text(m.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text('₹${m.price} | ${m.category}', style: const TextStyle(fontSize: 11)),
                  ),
                );
              }),
            const SizedBox(height: 20),

            // PAST ORDERS ARCHIVE
            const Text('Bedside Meal Order History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (state.pastOrders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No previous nourishment requested in this session.', style: TextStyle(fontSize: 11, color: Colors.grey)),
              )
            else
              ...state.pastOrders.map((ord) {
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(ord.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('₹${ord.grandTotal.toStringAsFixed(2)} | Delivered successfully to Bed', style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              }),

            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                state.logout();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Sign-out Ward Check-in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
