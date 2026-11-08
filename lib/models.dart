class Flood {
  final int? id;
  final String areaName, location, startTime, endTime; // time: 'YYYY-MM-DD HH:mm'
  final int expectedDepthEm;
  Flood({
    this.id,
    required this.areaName,
    required this.location,
    required this.expectedDepthEm,
    required this.startTime,
    required this.endTime,
  });

  // Task 5: level luôn được tính lại từ depth (khi Add, Update và Load)
  String get alertLevel => levelOf(expectedDepthEm);

  factory Flood.fromMap(Map<String, dynamic> m) => Flood(
    id: m['id'],
    areaName: m['area_name'],
    location: m['location'],
    expectedDepthEm: m['expected_depth_em'],
    startTime: m['start_time'],
    endTime: m['end_time'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'area_name': areaName,
    'location': location,
    'expected_depth_em': expectedDepthEm,
    'start_time': startTime,
    'end_time': endTime,
    'alert_level': alertLevel,
  };
}

/// 1–19 Low, 20–49 Moderate, >= 50 High
String levelOf(int depth) => depth >= 50
    ? 'High'
    : depth >= 20
    ? 'Moderate'
    : 'Low';

/// DateTime -> 'YYYY-MM-DD HH:mm' (chuỗi cùng định dạng so sánh được theo thứ tự chữ cái)
String fmt(DateTime d) {
  String p(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${p(d.month)}-${p(d.day)} ${p(d.hour)}:${p(d.minute)}';
}

/// Parse đúng định dạng 'YYYY-MM-DD HH:mm', sai thì trả null.
DateTime? parseTime(String s) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$').hasMatch(s)) return null;
  final d = DateTime.tryParse(s);
  return (d == null || fmt(d) != s) ? null : d; // loại 2026-02-30, 25:00...
}

/// Task 4: còn hiệu lực = End Time >= phút hiện tại (giờ local)
bool isCurrentOrUpcoming(Flood f, DateTime now) => f.endTime.compareTo(fmt(now)) >= 0;
