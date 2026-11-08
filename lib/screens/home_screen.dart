import 'package:flutter/material.dart';

import '../db.dart';
import '../models.dart';
import '../widgets/flood_card.dart';
import 'add_screen.dart';
import 'current_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Flood> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await getFloods();
    if (mounted) setState(() => _items = list);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));

  // Mở màn Add/Update; kết quả 'saved' | 'deleted' | null (back không lưu)
  Future<void> _open([Flood? f]) async {
    final r = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => AddFloodScreen(flood: f)),
    );
    if (r == null) return;
    await _load(); // refresh ngay
    _snack(switch (r) {
      'deleted' => 'Warning deleted successfully',
      _ => f == null ? 'Warning added successfully' : 'Warning updated successfully',
    });
  }

  Future<void> _delete(Flood a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Warning'),
        content: const Text('Are you sure you want to delete this warning?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await deleteFlood(a.id!);
    await _load();
    _snack('Warning deleted successfully');
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey),
        const SizedBox(height: 8),
        const Text('No flood warnings yet'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _open(),
          icon: const Icon(Icons.add),
          label: const Text('Add Warning'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Watch', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // push sang Current & Upcoming (màn đó có nút Back để pop)
          IconButton(
            tooltip: 'Current & Upcoming',
            icon: const Icon(Icons.schedule),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrentScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Warning'),
        onPressed: () => _open(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/banner.png',
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => FloodCard(
                      flood: _items[i],
                      onTap: () => _open(_items[i]),
                      onDelete: () => _delete(_items[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
