import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class NotificationsLogScreen extends StatefulWidget {
  const NotificationsLogScreen({super.key});

  @override
  State<NotificationsLogScreen> createState() => _NotificationsLogScreenState();
}

class _NotificationsLogScreenState extends State<NotificationsLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).markNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritional Alerts & Activity', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: state.notifications.isEmpty
          ? const Center(child: Text('No notifications received yet.'))
          : ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final n = state.notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2E7D32).withOpacity(0.12),
                    child: const Icon(Icons.notifications, color: Color(0xFF2E7D32)),
                  ),
                  title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(n.message, style: const TextStyle(fontSize: 11)),
                  trailing: Text(n.time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
    );
  }
}
