import 'package:flutter/material.dart';

import '../db.dart';
import '../models.dart';
import '../widgets/flood_card.dart';

/// Dùng chung cho Add (flood == null) và Update (flood != null).
/// Pop trả về 'saved' | 'deleted'; back không lưu thì trả null.
class AddFloodScreen extends StatefulWidget {
  final Flood? flood;
  const AddFloodScreen({super.key, this.flood});
  @override
  State<AddFloodScreen> createState() => _AddFloodScreenState();
}

class _AddFloodScreenState extends State<AddFloodScreen> {
  final _form = GlobalKey<FormState>();
  final _areaName = TextEditingController();
  final _location = TextEditingController();
  final _depth = TextEditingController();
  final _startTime = TextEditingController();
  final _endTime = TextEditingController();

  bool get _isEdit => widget.flood != null;

  @override
  void initState() {
    super.initState();
    final a = widget.flood; // prefill khi Update
    if (a == null) return;
    _areaName.text = a.areaName;
    _location.text = a.location;
    _depth.text = '${a.expectedDepthEm}';
    _startTime.text = a.startTime;
    _endTime.text = a.endTime;
  }

  @override
  void dispose() {
    for (final c in [_areaName, _location, _depth, _startTime, _endTime]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String name) =>
      v == null || v.trim().isEmpty ? '$name is required' : null;

  // Chọn ngày rồi giờ => 'YYYY-MM-DD HH:mm'
  Future<void> _pickTime(TextEditingController ctrl) async {
    final init = parseTime(ctrl.text) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(init));
    if (time == null) return;
    ctrl.text = fmt(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  String? _timeValidator(String? v, String name) {
    final r = _required(v, name);
    if (r != null) return r;
    return parseTime(v!.trim()) == null ? '$name must be YYYY-MM-DD HH:mm' : null;
  }

  String? _endValidator(String? v) {
    final r = _timeValidator(v, 'End Time');
    if (r != null) return r;
    final s = parseTime(_startTime.text.trim());
    if (s != null && !parseTime(v!.trim())!.isAfter(s)) return 'End Time must be after Start Time';
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final a = Flood(
      id: widget.flood?.id,
      areaName: _areaName.text.trim(),
      location: _location.text.trim(),
      expectedDepthEm: int.parse(_depth.text.trim()),
      startTime: _startTime.text.trim(),
      endTime: _endTime.text.trim(),
    );
    _isEdit ? await updateFlood(a) : await addFlood(a);
    if (mounted) Navigator.pop(context, 'saved');
  }

  Future<void> _delete() async {
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
    await deleteFlood(widget.flood!.id!);
    if (mounted) Navigator.pop(context, 'deleted');
  }

  Widget _gap(Widget w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w);

  @override
  Widget build(BuildContext context) {
    final depth = int.tryParse(_depth.text.trim());
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Update Warning' : 'Add Warning')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _gap(TextFormField(
                controller: _areaName,
                decoration: const InputDecoration(labelText: 'Area Name', border: OutlineInputBorder()),
                validator: (v) => _required(v, 'Area Name'),
              )),
              _gap(TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                validator: (v) => _required(v, 'Location'),
              )),
              _gap(TextFormField(
                controller: _depth,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}), // cập nhật Alert Level ngay
                decoration: const InputDecoration(labelText: 'Expected Depth (cm)', border: OutlineInputBorder()),
                validator: (v) {
                  final r = _required(v, 'Expected Depth');
                  if (r != null) return r;
                  final n = int.tryParse(v!.trim());
                  return (n == null || n <= 0) ? 'Expected Depth must be a positive integer' : null;
                },
              )),
              _gap(TextFormField(
                controller: _startTime,
                readOnly: true,
                onTap: () => _pickTime(_startTime),
                decoration: const InputDecoration(
                  labelText: 'Start Time (YYYY-MM-DD HH:mm)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                validator: (v) => _timeValidator(v, 'Start Time'),
              )),
              _gap(TextFormField(
                controller: _endTime,
                readOnly: true,
                onTap: () => _pickTime(_endTime),
                decoration: const InputDecoration(
                  labelText: 'End Time (YYYY-MM-DD HH:mm)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                validator: _endValidator,
              )),
              // Alert Level tự tính, không cho nhập
              _gap(InputDecorator(
                decoration: const InputDecoration(labelText: 'Alert Level (auto)', border: OutlineInputBorder()),
                child: depth == null || depth <= 0
                    ? const Text('—')
                    : Text(levelOf(depth),
                        style: TextStyle(fontWeight: FontWeight.bold, color: levelColor(levelOf(depth)))),
              )),
              const SizedBox(height: 8),
              FilledButton(onPressed: _save, child: Text(_isEdit ? 'Update' : 'Save')),
              if (_isEdit) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
              const SizedBox(height: 8),
              // Back without saving
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ],
          ),
        ),
      ),
    );
  }
}
