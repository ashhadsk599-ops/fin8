import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class HospitalPortalScreen extends StatelessWidget {
  const HospitalPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final currentHosp = state.selectedHospital;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Bhatkal Hospital Guide', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Your Check-in Medical Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (currentHosp != null) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Image.network(currentHosp.image, height: 160, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        title: Text(currentHosp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(currentHosp.location),
                        trailing: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              Text('${currentHosp.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
            const SizedBox(height: 20),
            const Text('Other Medical Care Facilities near Bhatkal, KA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ...STAT_HOSPITALS.where((h) => h.id != currentHosp?.id).map((h) {
              return Card(
                color: Colors.white,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(h.image, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  title: Text(h.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text(h.location, style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showCheckinConfirmDialog(context, h);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showCheckinConfirmDialog(BuildContext context, Hospital h) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Hospital Connection?'),
          content: Text('Would you like to register your active bedside room or staff ID check-in with ${h.name}? This resets your clinical state.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
            TextButton(
              onPressed: () {
                Provider.of<AppState>(context, listen: false).logout();
                Navigator.pop(ctx, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Signed out of previous hospital. Please check-in to ${h.name}')),
                );
              },
              child: const Text('PROCEED'),
            ),
          ],
        );
      },
    );
  }
}
