import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cura_meal/models/models.dart';
import 'package:cura_meal/state/app_state.dart';

class BedsideLiveLocationMap extends StatefulWidget {
  final OrderStatus status;
  const BedsideLiveLocationMap({super.key, required this.status});

  @override
  State<BedsideLiveLocationMap> createState() => _BedsideLiveLocationMapState();
}

class _BedsideLiveLocationMapState extends State<BedsideLiveLocationMap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final user = state.currentUser;
    final ward = user?.patientDetails?.ward ?? 'Emergency Ward';
    final room = user?.patientDetails?.roomNumber ?? 'Room B-12';

    double targetProgress;
    String statusDesc;
    switch (widget.status) {
      case OrderStatus.Received:
        targetProgress = 0.15;
        statusDesc = 'Meal sanitised & certified by dietary head.';
        break;
      case OrderStatus.Preparing:
        targetProgress = 0.45;
        statusDesc = 'Preparing diet with low-sodium clinical standards.';
        break;
      case OrderStatus.OutForDelivery:
        targetProgress = 0.75;
        statusDesc = 'Ward executive ascending to floor with warm box.';
        break;
      case OrderStatus.Delivered:
        targetProgress = 1.0;
        statusDesc = 'Meal delivered safely to bedside tray.';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.gps_fixed, color: Color(0xFF2E7D32), size: 16),
              const SizedBox(width: 6),
              const Text(
                'LIVE BEDSIDE GPS ROUTE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5, color: Color(0xFF334155)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)),
                    SizedBox(width: 4),
                    Text('LIVE TRACKING', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: MapGridPainter(progress: targetProgress),
                  ),
                ),
                // Kitchen Point
                const Positioned(
                  left: 10,
                  top: 45,
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFF2E7D32),
                        radius: 12,
                        child: Icon(Icons.soup_kitchen, size: 12, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text('Kitchen', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    ],
                  ),
                ),
                // Patient Bed Point
                Positioned(
                  right: 10,
                  top: 45,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF9800).withOpacity(0.5 * (1.0 - _controller.value)),
                                  blurRadius: 10.0 * _controller.value,
                                  spreadRadius: 8.0 * _controller.value,
                                )
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: const CircleAvatar(
                          backgroundColor: Color(0xFFFF9800),
                          radius: 12,
                          child: Icon(Icons.personal_injury, size: 12, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('$room ($ward)', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    ],
                  ),
                ),
                // Moving Courier Point
                AnimatedAlign(
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  alignment: Alignment(
                    -0.7 + (1.4 * targetProgress),
                    -0.1,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_bike, size: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      const Text('Courier', style: TextStyle(fontSize: 8, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Timeline: $statusDesc',
            style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nourishment Rep: Anand Bhatkal',
                style: TextStyle(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              Text(
                widget.status == OrderStatus.Delivered ? 'Arrived at Bed Space' : 'ETA: ~12 mins',
                style: const TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  final double progress;
  MapGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final paintProgress = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(32, size.height / 2);
    path.cubicTo(
      size.width * 0.3, size.height * 0.2,
      size.width * 0.6, size.height * 0.8,
      size.width - 32, size.height / 2,
    );

    canvas.drawPath(path, paintLine);

    if (path.computeMetrics().isNotEmpty) {
      final pathMetrics = path.computeMetrics().first;
      final extractPath = pathMetrics.extractPath(0, pathMetrics.length * progress);
      canvas.drawPath(extractPath, paintProgress);
    }
  }

  @override
  bool shouldRepaint(covariant MapGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
