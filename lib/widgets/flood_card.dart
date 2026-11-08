import 'package:flutter/material.dart';

import '../models.dart';

Color levelColor(String level) => switch (level) {
  'High' => Colors.red,
  'Moderate' => Colors.orange,
  _ => Colors.green,
};

/// Thẻ cảnh báo dùng cho Home và Current & Upcoming.
class FloodCard extends StatelessWidget {
  final Flood flood;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  const FloodCard({super.key, required this.flood, required this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = levelColor(flood.alertLevel);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap, // chạm item => màn Update
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.water_drop, color: color),
        ),
        title: Text(flood.areaName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.place, size: 14),
              const SizedBox(width: 4),
              Expanded(child: Text(flood.location)),
            ]),
            Text('Depth: ${flood.expectedDepthEm} cm'),
            Text('${flood.startTime}  →  ${flood.endTime}'),
          ],
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Text(flood.alertLevel,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            if (onDelete != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
