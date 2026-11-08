import 'package:flutter/material.dart';

import '../db.dart';
import '../models.dart';
import '../widgets/flood_card.dart';
import 'add_screen.dart';

/// Task 4: Current & Upcoming = End Time >= phút hiện tại (local).
class CurrentScreen extends StatefulWidget {
  const CurrentScreen({super.key});
  @override
  State<CurrentScreen> createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen> {
  List<Flood> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final list = (await getFloods()).where((f) => isCurrentOrUpcoming(f, now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    if (mounted) setState(() => _items = list);
  }

  @override
  Widget build(BuildContext context) {
    final high = _items.where((f) => f.alertLevel == 'High').length;
    return Scaffold(
      // AppBar tự có nút Back => Navigator.pop về Home
      appBar: AppBar(title: const Text('Current & Upcoming')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _stat('Warnings', _items.length, Colors.teal)),
                const SizedBox(width: 12),
                Expanded(child: _stat('High level', high, Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No current or upcoming warnings'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, i) => FloodCard(
                      flood: _items[i],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddFloodScreen(flood: _items[i])),
                        );
                        _load();
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int n, Color c) => Card(
    color: c.withValues(alpha: 0.1),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text('$n', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: c)),
          Text(label),
        ],
      ),
    ),
  );
}
